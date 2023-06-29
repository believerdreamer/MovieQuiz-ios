import UIKit

protocol AlertPresenterProtocol {
    
    func show(alertModel: AlertModel)
    
}

class AlertPresenter: AlertPresenterProtocol{
    private weak var viewController: UIViewController?
    
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let completion = UIAlertAction(title: alertModel.buttonText, style: .default) { [weak self] _ in
            guard let self = self else {return}
            alertModel.completion()
        }
        
        alert.addAction(completion)
        viewController?.present(alert, animated: true)
        
    }
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
}
