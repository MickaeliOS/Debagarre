//
//  SignInTest.swift
//  DébagarreTests
//
//  Created by Mickaël Horn on 06/03/2024.
//

import XCTest
@testable import Debagarre

@MainActor
final class SignInTest: XCTestCase {

    // MARK: - PROPERTIES
    private var sut: SignInView.ViewModel!
    private var firebaseAuthService: MockFirebaseAuthService!

    // MARK: - SETUP
    override func setUp() {
        firebaseAuthService = MockFirebaseAuthService()
        sut = SignInView.ViewModel(firebaseAuthService: firebaseAuthService)
    }

    // MARK: - PRIVATE FUNCTIONS
    private func setupUser(email: String = "mail@mail.com", password: String = "pmpmpmP0") {
        sut.email = email
        sut.password = password
    }

    // MARK: - TESTS
    func testGivenAnEmptyField_WhenSignInUser_ThenHasEmptyFieldErrorOccurs() async {
        setupUser(email: "")

        await sut.signIn()

        XCTAssertEqual(sut.errorMessage, "All fields must be filled.")
        XCTAssertTrue(sut.showingAlert)
    }

    func testGivenBadEmail_WhenSignInUser_ThenBadEmailErrorOccurs() async {
        setupUser(email: "mail@mail")

        await sut.signIn()

        XCTAssertEqual(sut.errorMessage, "Badly formatted email, please provide a correct one.")
        XCTAssertTrue(sut.showingAlert)
    }

    func testGivenRandomError_WhenSignInUser_ThenDefaultErrorOccurs() async {
        setupUser()
        firebaseAuthService.error = CustomError(errorDescription: "")

        await sut.signIn()

        XCTAssertEqual(sut.errorMessage, "Something went wrong, please try again.")
        XCTAssertTrue(firebaseAuthService.isSignInTriggered)
        XCTAssertTrue(sut.showingAlert)
    }

    func testGivenNoNetwork_WhenSignInUser_ThenNetworkErrorOccurs() async {
        setupUser()
        firebaseAuthService.error = FirebaseAuthService.FirebaseAuthServiceError.networkError

        await sut.signIn()

        XCTAssertEqual(sut.errorMessage, "Please verify your network.")
        XCTAssertTrue(sut.showingAlert)
    }

    func testGivenInvalidCredentials_WhenSignInUser_ThenInvalidCredentialsErrorOccurs() async {
        setupUser()
        firebaseAuthService.error = FirebaseAuthService.FirebaseAuthServiceError.invalidCredentials

        await sut.signIn()

        XCTAssertEqual(sut.errorMessage, "Incorrect email or password.")
        XCTAssertTrue(firebaseAuthService.isSignInTriggered)
        XCTAssertTrue(sut.showingAlert)
    }

    func testGivenCorrectEmailAndPassword_WhenSignInUser_ThenUserIsSignedIn() async {
        setupUser()

        await sut.signIn()

        XCTAssertTrue(sut.errorMessage.isReallyEmpty)
        XCTAssertFalse(sut.showingAlert)
    }
}
