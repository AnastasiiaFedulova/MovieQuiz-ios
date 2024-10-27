import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticServise: StatisticServiceProtocol?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        imageView.layer.cornerRadius = 20
        
        statisticServise = StatisticService()
        
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self) 
        self.questionFactory = questionFactory
        showLoadingIndicator()
        questionFactory.loadData()
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
        let returnModel = QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
        question: model.text,
        questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return returnModel
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    private func showAnswerResult(isCorrect: Bool) {

        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
    
        
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
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    private func showNextQuestionOrResults() {

        
        if currentQuestionIndex == questionsAmount - 1 {
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
                show(quiz: viewModel)
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
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let errorAlert = AlertModel(title: "Ошибка", message: "", buttonText: "Попробовать еще раз", completion: {
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory!.requestNextQuestion()
        })
        
        let errorAlertPresenter = AlertPresenter()
        errorAlertPresenter.setup(delegate: self)
        errorAlertPresenter.alert(alertData: errorAlert)
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

 
