//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 24.04.2024.
//

import Foundation

struct GameRecord: Codable {
    /// Количество правильных ответов
    let correct: Int
    /// Количество вопросов квиза
    let total: Int
    /// Дата завершения раунда
    let date: Date
    
    /// Сравнение рекордов исходя из количества правильных ответов
    /// - Parameter other: Прошлый лучший результат
    /// - Returns: true, если текущий результат лучше, false в противном случае
    func compare(with other: GameRecord) -> Bool {
        return correct > other.correct
    }
}
