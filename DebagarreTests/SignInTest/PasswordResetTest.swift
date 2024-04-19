//
//  PasswordResetTest.swift
//  DebagarreTests
//
//  Created by Mickaël Horn on 18/04/2024.
//

import XCTest
@testable import Debagarre

@MainActor
final class PasswordResetTest: XCTestCase {

    // MARK: - PROPERTIES
    private var sut: PasswordResetView.ViewModel!
    private var firebaseAuthService: MockFirebaseAuthService!

    // MARK: - SETUP
    override func setUp() {
        firebaseAuthService = MockFirebaseAuthService()
        sut = PasswordResetView.ViewModel(firebaseAuthService: firebaseAuthService)
    }
    
    // MARK: - TESTS
    func testGivenCorrectEmail_WhenResetingPassword_ThenPasswordIsReseted() async {
        sut.email = "test@test.com"
        
        await sut.resetPassword()

        XCTAssertEqual(sut.errorMessage, "")
        XCTAssertFalse(sut.showingAlert)
        XCTAssertFalse(sut.isEmailSentMessageHidden)
        XCTAssertTrue(sut.isSendEmailButtonEnabled)
    }

    func testGivenBadlyFormattedEmail_WhenResetingPassword_ThenBadlyFormattedErrorOccurs() async {
        sut.email = "test@test"

        await sut.resetPassword()

        XCTAssertEqual(sut.errorMessage, "Badly formatted email, please provide a correct one.")
        XCTAssertTrue(sut.showingAlert)
        XCTAssertTrue(sut.isEmailSentMessageHidden)
        XCTAssertTrue(sut.isSendEmailButtonEnabled)
    }

    func testGivenAFirebaseError_WhenResetingPassword_ThenFirebaseErrorMessageIsDisplayed() async {
        sut.email = "test@test.com"
        firebaseAuthService.error = FirebaseAuthService.FirebaseAuthServiceError.defaultError

        await sut.resetPassword()

        XCTAssertEqual(sut.errorMessage, "An error occured.")
        XCTAssertTrue(sut.showingAlert)
        XCTAssertTrue(sut.isEmailSentMessageHidden)
        XCTAssertTrue(sut.isSendEmailButtonEnabled)
    }

    func testGivenANonFirebaseError_WhenResetingPassword_ThenNonFirebaseErrorMessageIsDisplayed() async {
        sut.email = "test@test.com"
        firebaseAuthService.error = CustomError(errorDescription: "")

        await sut.resetPassword()

        XCTAssertEqual(sut.errorMessage, "Something went wrong, please retry.")
        XCTAssertTrue(sut.showingAlert)
        XCTAssertTrue(sut.isEmailSentMessageHidden)
        XCTAssertTrue(sut.isSendEmailButtonEnabled)
    }
}
