//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 24.04.2024.
//

import Foundation

final class StatisticService {
    private let userDefaults = UserDefaults.standard
    private lazy var totalCorrectAnswers: Double = 0
    private lazy var totalQuestions: Double = 0
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
}

// MARK: - StatisticServiceProtocol

extension StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return GameRecord(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    /// Сохранение лучшего результата и средней точности в UserDefaults
    /// - Parameters:
    ///   - count: Количество верных ответов
    ///   - amount: Количество вопросов
    ///
    ///  Средняя точность в процентах, 
    ///  рассчитывающаяся как отношение правильно отвеченных вопросов за все игры
    ///  к общему количеству вопросов за все игры
    func store(correct count: Int, total amount: Int) {
        let currentGame = GameRecord(correct: count, total: amount, date: Date())
        
        if currentGame.compare(with: bestGame) {
            bestGame = currentGame
        }
        
        gamesCount += 1
        totalCorrectAnswers += Double(count)
        totalQuestions += Double(amount)
        totalAccuracy = totalCorrectAnswers / totalQuestions * 100
    }
}
