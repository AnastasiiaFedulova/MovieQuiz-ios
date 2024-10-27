//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Anastasiia on 09.10.2024.
//

import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case bestGame
        case gameCount
        case total
        case date
        case correctAnswers
        case countAnswers
    }
}


extension StatisticService: StatisticServiceProtocol {
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    private var countAnswers: Int {
        get {
            storage.integer(forKey: Keys.countAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.countAnswers.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gameCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gameCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            GameResult(
                correct: storage.integer(forKey: Keys.correct.rawValue),
                total:   storage.integer(forKey: Keys.total.rawValue),
                date: storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            )
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        if gamesCount != 0 {
           return Double(Double(correctAnswers) / Double(gamesCount * 10)) * 100
        } else {
            return 100.00
        }
    }
    
    func store(result: GameResult) {
        gamesCount = gamesCount + 1
        correctAnswers += result.correct
        countAnswers += result.total
        
        if result.isBetterThan(bestGame) {
            bestGame = result
        }
    }
    
  
}
