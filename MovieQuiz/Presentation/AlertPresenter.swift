//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

/// Алерт презентер
final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
}

// MARK: - AlertPresenterProtocol
extension AlertPresenter: AlertPresenterProtocol {

    func resultAlert(model: QuizResultsViewModel) {
        
        guard let delegate = delegate else {
            return
        }
        
        let alertModel = AlertModel(
                    title: model.title,
                    message: model.text,
                    buttonText: model.buttonText,
                    completion: { [weak delegate] in
                        guard let vc = delegate as? MovieQuizViewController else { return }
                        vc.currentQuestionIndex = 0
                        vc.correctAnswers = 0
                        vc.questionFactory.requestNextQuestion()
                    }
                )
        
        delegate.showResultAlert(model: alertModel)
    }
}
