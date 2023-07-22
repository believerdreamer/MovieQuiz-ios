import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestion: QuizQuestion?
    private weak var viewController: (MovieQuizViewControllerProtocol)?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 9
    private var correctAnswers: Int = 0
    private var statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        statisticService = StatisticServiceImpl()
        viewController.showLoadingIndicator()
    }
    // MARK: QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        viewController?.showIndicatorAndBlur()
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
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
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
        if currentQuestion.correctAnswer == isYes{
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
        viewController?.showIndicatorAndBlur()
        
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
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
            viewController?.hideImageBorder()
        }
        viewController?.disableButtons()
    }
    
    func gameBeginning(){
        statisticService = StatisticServiceImpl()
        questionFactory?.requestNextQuestion()
        questionFactory?.loadData()
    }
}


