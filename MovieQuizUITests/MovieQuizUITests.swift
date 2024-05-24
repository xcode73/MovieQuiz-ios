//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Nikolai Eremenko on 22.05.2024.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    private func chooseSystemTheme() {
        if app.alerts["Theme alert"].exists {
            let themeAlert = app.alerts["Theme alert"]
            XCTAssert(themeAlert.waitForExistence(timeout: 2))
            themeAlert.buttons["Yes"].tap()
        }
    }
    
    private func checkQuestionChange(button: String) {
        chooseSystemTheme()
        
        let firstPoster = app.images["Poster"]
        XCTAssert(firstPoster.waitForExistence(timeout: 2))
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons[button].tap()
        
        let secondPoster = app.images["Poster"]
        XCTAssert(secondPoster.waitForExistence(timeout: 2))
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssert(indexLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func answerButtonNoTapTenTimes() {
        for _ in 1...10 {
            let poster = app.images["Poster"]
            XCTAssert(poster.waitForExistence(timeout: 2))
            app.buttons["No"].tap()
            sleep(1)
        }
    }
    
    func testYesButton() {
        checkQuestionChange(button: "Yes")
    }
    
    func testNoButton() {
        checkQuestionChange(button: "No")
    }
    
    func testGameFinish() {
        chooseSystemTheme()
        
        answerButtonNoTapTenTimes()

        let alert = app.alerts["Game results"]
        XCTAssert(alert.waitForExistence(timeout: 2))
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        chooseSystemTheme()
        
        answerButtonNoTapTenTimes()
        
        let alert = app.alerts["Game results"]
        alert.buttons["button"].firstMatch.tap()
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
