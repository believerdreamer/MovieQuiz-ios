import UIKit

// MARK: UIViewController
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    

    // MARK: IBOutlet:
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet private var imageView: UIImageView!

    // MARK: IBAction:
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }

    // MARK: Private properties:
    private let presenter = MovieQuizPresenter()
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?

    // MARK: Public properties:

    // MARK: Private methods:
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        blurEffect.isHidden = false
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        blurEffect.isHidden = true
    }
    private func showNetworkError(message: String) {
        let networkErrorAlert = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать ещё раз",
            completion: {[weak self] in
                guard let self = self else {return}
                showLoadingIndicator()
                blurEffect.isHidden = false
                questionFactory?.loadData()
                self.presenter.restartGame()
            }
        )
        alertPresenter?.show(alertModel: networkErrorAlert)
    }

    func show (quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.image = step.image

    }

    func showAnswerResult(isCorrect: Bool) {
//        presenter.didAnswer(isYes: isCorrect)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }

    func showFinalResults() {
        blurEffect.isHidden = false
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] in
                self?.presenter.currentQuestionIndex = 0
                self?.presenter.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
                self?.presenter.restartGame()
            }
        )
        alertPresenter?.show(alertModel: alertModel)

        func makeResultMessage() -> String {
            guard let statisticService = statisticService else {
                return ""
            }
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount )"
            let bestGameCorrect = statisticService.bestGame?.correct ?? 0
            let bestGameTotal = statisticService.bestGame?.total ?? 0
            let bestGameDate = statisticService.bestGame?.date.dateTimeString ?? ""
            let bestGameInfoLine = "Рекорд: \(bestGameCorrect)/\(bestGameTotal) (\(bestGameDate))"
            let averageAccuracyLine = "Средняя точность: \(accuracy)%"
            let resultMessage = [
               currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
           ].joined(separator: "\n")
            return resultMessage
       }

    }
    // MARK: Public methods:
    func didLoadDataFromServer() {
        activityIndicator.isHidden = false
        blurEffect.isHidden = false
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }



    // MARK: Lifecycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImpl()
        questionFactory?.requestNextQuestion()
        questionFactory?.loadData()

    }

}
