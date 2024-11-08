//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Anastasiia on 08.10.2024.
//

import Foundation


protocol QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error) 
}
