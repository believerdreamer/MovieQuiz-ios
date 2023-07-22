import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showFinalResults(alertModel: MovieQuiz.AlertModel) {
        
    }
    
    func disableButtons() {
    }
    
    func hideImageBorder() {
        
    }
    
    func showIndicatorAndBlur() {
        
    }
    
    func showFinalResults() {
        
    }
    
    func show(quiz step: QuizStepViewModel) {}
    
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    
    func showLoadingIndicator() {}
    
    func hideLoadingIndicator() {}
    
    func showNetworkError(message: String) {}
    
}
