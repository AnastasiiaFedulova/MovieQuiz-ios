//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Anastasiia on 06.11.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewControllerProtocol?
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    var statisticServise: StatisticServiceProtocol? = StatisticService()
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(networkClient: NetworkClient()),
            delegate: self,
            controller: viewController
        )
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    
    func didFailToLoadData(with error: Error) {
           let message = error.localizedDescription
           viewController?.showNetworkError(message: message)
       }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func correctAnswersPlusOne() {
        correctAnswers += 1
    }
    func correctAnswersReset() {
        correctAnswers = 0
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
   func yesButtonClicked() {
        didAnswer(isYes: true)
    }
   func noButtonClicked() {
        didAnswer(isYes: false)
    }
    private func didAnswer(isYes: Bool) {
           guard let currentQuestion = currentQuestion else {
               return
           }
           
           let givenAnswer = isYes
           
           viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
       }
    func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        }
    
    func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
    
    func showNextQuestionOrResults() {
        
        if isLastQuestion() {
            if let statisticServise = statisticServise {
                let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
                statisticServise.store(result: gameResult)
                
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "dd.MM.yy HH:mm"
                
                let text = "Ваш результат: \(correctAnswers)/10 \n Количество сыгранных квизов: \(statisticServise.gamesCount) \n Рекорд: \(statisticServise.bestGame.correct )/\(statisticServise.bestGame.total) (\(dateFormater.string(from: statisticServise.bestGame.date))) \n Средняя точность: \(String(format: "%.2f", statisticServise.totalAccuracy)) %"
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                viewController?.show(quiz: viewModel)
            }
            
        } else {
            switchToNextQuestion()
            questionFactory!.requestNextQuestion()
        }
    }
    
}
