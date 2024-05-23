//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 23.05.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    /// Конвертация модели вопроса во вью модель вопроса
    /// - Parameter model: модель вопроса
    /// - Returns: вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func updateQuestionIndex() {
        currentQuestionIndex += 1
    }
    
}
