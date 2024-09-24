//
//  Model.swift
//  MovieQuiz
//
//  Created by Anastasiia on 22.09.2024.
//

import Foundation
import UIKit

// для состояния "Вопрос показан"
struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

// для состояния "Результат квиза"
struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

// для состояния "Резултат ответа"
struct QuizResultAnswerModel {
    let correctAnswer: Bool
}
