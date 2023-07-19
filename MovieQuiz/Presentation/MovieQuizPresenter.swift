import UIKit

final class MovieQuizPresenter {
    //MARK: Properies:
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    var correctAnswers: Int = 0
    
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
            viewController?.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
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
    
    func showNextQuestionOrResults() {
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
} 
