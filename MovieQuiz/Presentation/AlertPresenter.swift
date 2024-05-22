//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

struct AlertPresenter {
    private static func showBasicAlert(on vc: UIViewController, title: String, message: String, buttons: [String], completion: @escaping () -> ()) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        for button in buttons {
            switch button {
            case "Да":
                let systemThemeAction = UIAlertAction(title: button, style: .default) { _ in
                    completion()
                }
                alert.addAction(systemThemeAction)
            case "Нет":
                let defaultThemeAction = UIAlertAction(title: button, style: .cancel)
                alert.addAction(defaultThemeAction)
            default:
                let action = UIAlertAction(title: button, style: .default) { _ in
                    completion()
                }
                alert.addAction(action)
            }
        }
        
        DispatchQueue.main.async {
            vc.present(alert, animated: true)
        }
    }
    
    static func resultAlert(on vc: UIViewController, with model: AlertModel?) {
        guard let model = model else { return }
        showBasicAlert(on: vc,
                       title: model.title,
                       message: model.message,
                       buttons: [model.buttonText],
                       completion: model.completion)
    }
    
    static func networkErrorAlert(on vc: UIViewController, with message: String, completion: @escaping () -> Void) {
        showBasicAlert(on: vc,
                       title: "Ошибка",
                       message: message,
                       buttons: ["Попробовать еще раз"],
                       completion: completion)
    }
    
    static func themeAlert(on vc: UIViewController, completion: @escaping () -> Void) {
        showBasicAlert(on: vc,
                       title: "Выбор темы",
                       message: "Приложение рассчитано на использование темной темы. Изменить на системную?",
                       buttons: ["Да", "Нет"],
                       completion: completion)
    }
}
