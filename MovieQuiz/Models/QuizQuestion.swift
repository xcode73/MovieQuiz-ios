//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 16.04.2024.
//

import Foundation

struct QuizQuestion {
    // строка с названием фильма,
    // совпадает с названием картинки афиши фильма в Assets
    let image: String
    // строка с вопросом о рейтинге фильма
    let text: String
    let correctAnswer: Bool
}
