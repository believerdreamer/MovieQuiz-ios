import UIKit

final class MovieQuizPresenter {
    //MARK: Properies:
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    
    // MARK: Functions:
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
} 
