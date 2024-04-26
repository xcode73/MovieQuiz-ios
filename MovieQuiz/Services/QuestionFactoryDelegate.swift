//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}