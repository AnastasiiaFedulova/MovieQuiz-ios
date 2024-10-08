//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Anastasiia on 08.10.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
