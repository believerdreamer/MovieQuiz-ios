import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private weak var viewController: MovieQuizViewController?
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var statisticService: StatisticService!
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImpl()
        viewController.showLoadingIndicator()
    }
    // MARK: QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewController?.activityIndicator.isHidden = false
        viewController?.blurEffect.isHidden = false
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: Functions:
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {return}
        if isYes{
            correctAnswers += 1
        }
        
        proceedWithAnswer(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async {[weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.activityIndicator.isHidden = true
        viewController?.blurEffect.isHidden = true
    }
    
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.showFinalResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        viewController?.yesButton.isEnabled = true
        viewController?.noButton.isEnabled = true
        viewController?.showLoadingIndicator()
        viewController?.blurEffect.isHidden = false
        
    }
    func makeResultMessage() -> String {
        guard let statisticService = statisticService else {
            return ""
        }
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(self.correctAnswers)\\\(self.questionsAmount )"
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
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.imageView.layer.masksToBounds = true
        viewController?.imageView.layer.borderWidth = 8
        viewController?.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
            self.viewController?.imageView.layer.borderWidth = 0
            
        }
        viewController?.yesButton.isEnabled = false
        viewController?.noButton.isEnabled = false
    }
}


