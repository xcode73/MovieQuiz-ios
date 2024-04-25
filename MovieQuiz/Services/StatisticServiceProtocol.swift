//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 24.04.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
