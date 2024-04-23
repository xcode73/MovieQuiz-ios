//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import Foundation

/// протокол для получения следующего вопроса
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
