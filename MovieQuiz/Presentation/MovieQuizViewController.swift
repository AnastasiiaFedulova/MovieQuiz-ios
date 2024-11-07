import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    private var errorAlertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
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
        
        presenter = MovieQuizPresenter(viewController: self)
      //  presenter.viewController = self
        
        let errorAlertPresenter = AlertPresenter()
        errorAlertPresenter.setup(delegate: self)
        self.errorAlertPresenter = errorAlertPresenter
        
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    
    func show(quiz step: QuizStepViewModel) {
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        showLoadingIndicator()
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
     func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect {
            presenter.correctAnswersPlusOne()
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
            self.presenter.showNextQuestionOrResults()
            imageView.layer.borderColor = UIColor.ypBlack.cgColor
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
     func show(quiz result: QuizResultsViewModel) {
        
         let alertData = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: {
             self.presenter.restartGame()
          
         })
    
        errorAlertPresenter?.alert(alertData: alertData)
        
    }
        
         func showLoadingIndicator() {
            activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
            activityIndicator.startAnimating() // включаем анимацию
        }
        func hideLoadingIndicator() {
            activityIndicator.isHidden = true
        }
        
        func showNetworkError(message: String) {
            hideLoadingIndicator() // скрываем индикатор загрузки
            
            let errorAlert = AlertModel(title: "Ошибка", message: "", buttonText: "Попробовать еще раз", completion: { [weak self] in
                self?.presenter.restartGame()

                self?.showLoadingIndicator()
            })
            
            errorAlertPresenter?.alert(alertData: errorAlert)
        }
        
        @IBAction private func yesButtonClicked(_ sender: UIButton) {
            presenter.yesButtonClicked()
        }
        
        @IBAction private func noButtonClicked(_ sender: UIButton) {
                    presenter.noButtonClicked()
        }
    }

