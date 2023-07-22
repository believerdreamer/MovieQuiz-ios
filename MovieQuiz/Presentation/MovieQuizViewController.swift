import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func disableButtons()
    func hideImageBorder()
    func showIndicatorAndBlur()
    func showFinalResults(alertModel: AlertModel)
}

// MARK: UIViewController:

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: IBOutlet:
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var blurEffect: UIVisualEffectView!
    @IBOutlet private weak var imageView: UIImageView!
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    // MARK: Lifecycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
        presenter.gameBeginning()
        
    }
    
    // MARK: Actions:
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    // MARK: Functions:
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        blurEffect.isHidden = false
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        blurEffect.isHidden = true
    }
    func showNetworkError(message: String) {
        let networkErrorAlert = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать ещё раз",
            completion: {[weak self] in
                guard let self = self else {return}
                self.presenter.restartGame()
                showLoadingIndicator()
            }
        )
        alertPresenter?.show(alertModel: networkErrorAlert)
    }
    
    func show (quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        
    }
    
    func showFinalResults(alertModel: AlertModel) {
        blurEffect.isHidden = false
        activityIndicator.isHidden = true
        alertPresenter?.show(alertModel: presenter.createAlertModel())
    }
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func showIndicatorAndBlur(){
        yesButton.isEnabled = true
        noButton.isEnabled = true
        showLoadingIndicator()
        blurEffect.isHidden = false
    }
    
    func disableButtons(){
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func hideImageBorder(){
        self.imageView.layer.borderWidth = 0
    }
}
