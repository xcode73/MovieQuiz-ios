//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 17.04.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
} 
