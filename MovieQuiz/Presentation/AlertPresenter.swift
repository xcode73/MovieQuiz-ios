//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

struct AlertPresenter {
    private static func resultAlert(on vc: UIViewController, title: String, message: String, buttonText: String, completion: @escaping () -> Void) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default) { _ in
            completion()
        }
        alert.addAction(action)
        vc.present(alert, animated: true)
    }
    
    static func showResultAlert(on vc: UIViewController, with model: AlertModel?) {
        guard let model = model else { return }
        resultAlert(on: vc,
                    title: model.title,
                    message: model.message,
                    buttonText: model.buttonText,
                    completion: model.completion)
    }
}
