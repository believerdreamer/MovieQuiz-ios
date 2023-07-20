import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}

// MARK: UIViewController:

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {

    // MARK: IBOutlet:
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet var imageView: UIImageView!
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    // MARK: Lifecycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        presenter.statisticService = StatisticServiceImpl()
        presenter.questionFactory?.requestNextQuestion()
        presenter.questionFactory?.loadData()

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
        activityIndicator.stopAnimating()
        blurEffect.isHidden = true
    }
    func showNetworkError(message: String) {
        let networkErrorAlert = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать ещё раз",
            completion: {[weak self] in
                guard let self = self else {return}
                presenter.questionFactory?.loadData()
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
    
    func showFinalResults() {
        blurEffect.isHidden = false
        activityIndicator.isHidden = true
        presenter.statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: presenter.makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] in
                self?.presenter.currentQuestionIndex = 0
                self?.presenter.correctAnswers = 0
                self?.presenter.restartGame()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    func highlightImageBorder(isCorrectAnswer: Bool) {
           imageView.layer.masksToBounds = true
           imageView.layer.borderWidth = 8
           imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
       }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
}
