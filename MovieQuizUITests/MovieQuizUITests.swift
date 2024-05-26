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
        app.launchArguments = ["testing"]
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    private func waitWhileLoading() {
        let loadingView = app.otherElements["LoadingView"]
        for _ in 1...10 {
            if loadingView.exists {
                sleep(1)
            } else {
                break
            }
        }
    }
    
    private func checkQuestionChange(button: String) {
        
        func screenshotToData() -> Data {
            let poster = app.images["Poster"]
            let data = poster.screenshot().pngRepresentation
            return data
        }
        
        waitWhileLoading()
        
        let firstPosterData = screenshotToData()
        
        app.buttons[button].tap()
        waitWhileLoading()
        
        let secondPosterData = screenshotToData()

        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssert(indexLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func tapAnswerButtonNoTenTimes() {
        for _ in 1...10 {
            waitWhileLoading()
            app.buttons["No"].tap()
        }
    }
    
    func testYesButton() {
        checkQuestionChange(button: "Yes")
    }
    
    func testNoButton() {
        checkQuestionChange(button: "No")
    }
    
    func testGameFinish() {
        waitWhileLoading()
        tapAnswerButtonNoTenTimes()

        let alert = app.alerts["Game results"]
        // alert appears only in 0.8 seconds so don't remove sleep
        sleep(1)
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        waitWhileLoading()
        tapAnswerButtonNoTenTimes()
        
        let alert = app.alerts["Game results"]
        // alert appears only in 0.8 seconds so don't remove sleep
        sleep(1)
        alert.buttons["button"].firstMatch.tap()
        waitWhileLoading()
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
