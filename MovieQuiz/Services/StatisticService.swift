//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 24.04.2024.
//

import Foundation

final class StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
}

// MARK: - StatisticServiceProtocol

extension StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let gamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return gamesCount
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
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
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let total = try? JSONDecoder().decode(Double.self, from: data) else {
                return 0
            }
            return total
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    /// Сохранение лучшего результата — с проверкой на то, что новый результат лучше сохранённого в UserDefaults
    /// - Parameters:
    ///   - count: Количество верных ответов
    ///   - amount: Количество вопросов
    func store(correct count: Int, total amount: Int) {
        let record = GameRecord(correct: count, total: amount, date: Date())
        
        if record.compare(with: bestGame) {
            bestGame = record
        }
        
        totalAccuracy = Double(count) / Double(amount) * 100
        gamesCount += 1
    }
}
