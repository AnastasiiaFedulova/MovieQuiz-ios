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
        
    }
}


extension StatisticService: StatisticServiceProtocol {
    
    private var correctAnswers: Int {
        get {
            storage.integer(forKey: "correctAnswers")
        }
        set {
            storage.set(newValue, forKey: "correctAnswers")
        }
    }
    private var countAnswers: Int {
        get {
            storage.integer(forKey: "countAnswers")
        }
        set {
            storage.set(newValue, forKey: "countAnswers")
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
            GameResult(correct: storage.integer(forKey: Keys.correct.rawValue), total:   storage.integer(forKey: "total"), date: storage.object(forKey: "date") as? Date ?? Date())
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: "total")
            storage.set(newValue.date, forKey: "date")
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
