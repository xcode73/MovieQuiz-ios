//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

struct AlertPresenter {
    
    static func resultAlert(on vc: UIViewController, with model: AlertModel?, completion: @escaping () -> Void) {
        guard let model = model else { return }
        showBasicAlert(on: vc,
                       title: model.title,
                       message: model.message,
                       buttons: [model.buttonText],
                       identifier: "Game results",
                       completion: completion)
    }
    
    static func networkErrorAlert(on vc: UIViewController, with message: String, completion: @escaping () -> Void) {
        showBasicAlert(on: vc,
                       title: "Ошибка",
                       message: message,
                       buttons: ["Попробовать снова"],
                       identifier: "Network error",
                       completion: completion)
    }
    
    static func showQuestionNetworkError(on vc: UIViewController, completion: @escaping () -> Void) {
        showBasicAlert(on: vc,
                       title: "Ошибка",
                       message: "Не удалось загрузить вопрос! \n Проверьте подключение к сети",
                       buttons: ["Попробовать снова"],
                       identifier: "Question Error",
                       completion: completion)
    }
    
    private static func showBasicAlert(on vc: UIViewController, 
                                       title: String,
                                       message: String,
                                       buttons: [String],
                                       identifier: String,
                                       completion: @escaping () -> ()) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = .systemBackground
        
        alert.view.accessibilityIdentifier = identifier
        
        for button in buttons {
            switch button {
            case "Да":
                let systemThemeAction = UIAlertAction(title: button, style: .default) { _ in
                    completion()
                }
                systemThemeAction.accessibilityIdentifier = "Yes"
                alert.addAction(systemThemeAction)
            case "Нет":
                let defaultThemeAction = UIAlertAction(title: button, style: .cancel)
                defaultThemeAction.accessibilityIdentifier = "No"
                alert.addAction(defaultThemeAction)
            default:
                let action = UIAlertAction(title: button, style: .default) { _ in
                    completion()
                }
                action.accessibilityIdentifier = "button"
                alert.addAction(action)
            }
        }
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true)
        }
    }
}
