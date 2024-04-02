//
//  CreateAccountTests.swift
//  DébagarreTests
//
//  Created by Mickaël Horn on 06/03/2024.
//

import XCTest
@testable import Debagarre

@MainActor
final class CreateAccountTests: XCTestCase {

    // MARK: - PROPERTIES
    private var sut: CreateAccountView.ViewModel!
    private var firebaseAuthService: MockFirebaseAuthService!
    private var firestoreService: MockFirestoreService!

    // MARK: - SETUP
    override func setUp() {
        firebaseAuthService = MockFirebaseAuthService()
        firestoreService = MockFirestoreService()
        sut = CreateAccountView.ViewModel(firebaseAuthService: firebaseAuthService, firestoreService: firestoreService)
    }

    // MARK: - PRIVATE FUNCTIONS
    private func setupUser(email: String = "mail@mail.com",
                           password: String = "pmpmpmP0",
                           confirmPassword: String = "pmpmpmP0",
                           lastname: String = "lastName",
                           firstname: String = "firstname") {
        sut.email = email
        sut.password = password
        sut.confirmPassword = confirmPassword
    }

    // MARK: - FIREBASE AUTH TESTS
    func testGivenBadEmail_WhenCreatingAccount_ThenBadEmailErrorOccurs() async {
        setupUser(email: "mail@mail")

        await sut.createUser()

        XCTAssertFalse(firebaseAuthService.isCreateUserTriggered)
        XCTAssertTrue(sut.showingError)
        XCTAssertEqual(sut.errorMessage, "Badly formatted email, please provide a correct one.")
    }

    func testGivenBadConfirmationPassword_WhenCreatingAccount_ThenBadConfirmationPasswordErrorOccurs() async {
        setupUser(confirmPassword: "pmpmpmP00")

        await sut.createUser()

        XCTAssertFalse(firebaseAuthService.isCreateUserTriggered)
        XCTAssertTrue(sut.showingError)
        XCTAssertEqual(sut.errorMessage, "Passwords must be equals.")
    }

    func testGivenWeakPassword_WhenCreatingAccount_ThenWeakPasswordErrorOccurs() async {
        setupUser(password: "weakPassword")

        await sut.createUser()

        XCTAssertFalse(firebaseAuthService.isCreateUserTriggered)
        XCTAssertTrue(sut.showingError)
        XCTAssertEqual(sut.errorMessage, """
                Your password is too weak. It must be :
                - At least 7 characters long
                - At least one uppercase letter
                - At least one number
                """
        )
    }

    func testGivenAnEmptyField_WhenCreatingAccount_ThenEmptyFieldsErrorOccurs() async {
        setupUser(email: "")

        await sut.createUser()

        XCTAssertEqual(sut.errorMessage, "All fields must be filled.")
        XCTAssertFalse(firebaseAuthService.isCreateUserTriggered)
        XCTAssertTrue(sut.showingError)
    }

    func testGivenEmailAlreadyInUse_WhenCreatingAccount_ThenEmailAlreadyInUseErrorOccurs() async {
        setupUser()
        firebaseAuthService.error = FirebaseAuthService.FirebaseAuthServiceError.emailAlreadyInUse

        await sut.createUser()

        XCTAssertEqual(sut.errorMessage, "The email address is already in use by another account.")
        XCTAssertTrue(firebaseAuthService.isCreateUserTriggered)
        XCTAssertTrue(sut.showingError)
    }

    func testGivenNetworkError_WhenCreatingAccount_ThenNetworkErrorErrorOccurs() async {
        setupUser()
        firebaseAuthService.error = FirebaseAuthService.FirebaseAuthServiceError.networkError

        await sut.createUser()

        XCTAssertEqual(sut.errorMessage, "Please verify your network.")
        XCTAssertTrue(firebaseAuthService.isCreateUserTriggered)
        XCTAssertTrue(sut.showingError)
    }

    func testGivenDefaultError_WhenCreatingAccount_ThenDefaultErrorOccurs() async {
        setupUser()
        firebaseAuthService.error = FirebaseAuthService.FirebaseAuthServiceError.defaultError

        await sut.createUser()

        XCTAssertEqual(sut.errorMessage, "An error occured.")
        XCTAssertTrue(firebaseAuthService.isCreateUserTriggered)
        XCTAssertTrue(sut.showingError)
    }

    func testGivenCorrectFields_WhenCreatingAccount_ThenUserIsCreated() async {
        setupUser()

        await sut.createUser()

        XCTAssertTrue(sut.errorMessage.isReallyEmpty)
        XCTAssertTrue(firebaseAuthService.isCreateUserTriggered)
        XCTAssertFalse(sut.showingError)
        XCTAssertEqual(sut.userID, "userID123")
    }

    // MARK: - FIRESTORE AUTH TESTS
    func testGivenNoError_WhenSavingUser_ThenUserIsSaved() {
        setupUser()
        sut.saveUserInDatabase(userID: "userID123")

        XCTAssertTrue(sut.errorMessage.isReallyEmpty)
        XCTAssertTrue(firestoreService.isSaveUserInDatabaseTriggered)
        XCTAssertFalse(sut.showingError)
    }

    func testGivenSavingUserInDatabaseWithCannotSaveUserError_WhenSavingUser_ThenCannotSaveUserErrorOccurs() {
        setupUser()
        firestoreService.error = FirestoreService.FirestoreServiceError.cannotSaveUser

        sut.saveUserInDatabase(userID: "userID123")

        XCTAssertEqual(sut.errorMessage, "User could not be saved.")
        XCTAssertTrue(firestoreService.isSaveUserInDatabaseTriggered)
        XCTAssertTrue(sut.showingError)
    }

    func testGivenRandomError_WhenSavingUser_ThenDefaultErrorOccurs() {
        setupUser()
        firestoreService.error = CustomError(errorDescription: "")

        sut.saveUserInDatabase(userID: "userID123")

        XCTAssertEqual(sut.errorMessage, "Something went wrong, please try again.")
        XCTAssertTrue(firestoreService.isSaveUserInDatabaseTriggered)
        XCTAssertTrue(sut.showingError)
    }
}

