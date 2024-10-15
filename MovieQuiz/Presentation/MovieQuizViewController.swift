import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticServis: StatisticServiceProtocol?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var noButton: UILabel!
    @IBOutlet private var yesButton: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        statisticServis = StatisticService()
        
        
        let questionFactory = QuestionFactory() // 2
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory    // 4

        
        questionFactory.requestNextQuestion() 
        
        
        }
    
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let returnModel = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
        question: model.text,
        questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return returnModel
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 15
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            imageView.layer.borderColor = UIColor.ypBlack.cgColor
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            if let statisticServis = statisticServis {
                let gameResult = GameResult(correct: correctAnswers, total: questionsAmount, date: Date())
                statisticServis.store(result: gameResult)
                
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "dd.MM.yy HH:mm"
                
                let text = "Ваш результат: \(correctAnswers)/10 \n Количество сыгранных квизов: \(statisticServis.gamesCount) \n Рекорд: \(statisticServis.bestGame.correct )\\\(statisticServis.bestGame.total) (\(dateFormater.string(from: statisticServis.bestGame.date))) \n Средняя точность: \(String(format: "%.2f", statisticServis.totalAccuracy)) %"// 1
                let viewModel = QuizResultsViewModel( // 2
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                show(quiz: viewModel) // 3
            }
            
        } else {
            currentQuestionIndex += 1
            
            questionFactory!.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertData = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory!.requestNextQuestion()})
        
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        alertPresenter.alert(alertData: alertData)
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

 
