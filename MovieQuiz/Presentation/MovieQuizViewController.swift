//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showQuestion(quiz step: QuizStepViewModel)
    func showAnswer(with answer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showResults(quiz result: QuizResultsViewModel)
    func showNetworkError(message: String)
    func showQuestionsAlert()
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet
    private var imageView: UIImageView!
    
    @IBOutlet
    private var textLabel: UILabel!
    
    @IBOutlet
    private var counterLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView! {
      didSet {
        loadingView.layer.cornerRadius = 6
      }
    }
    
    @IBOutlet
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private properties
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    //MARK: - Private methods
    
    /// Вывод вопроса
    /// - Parameter step: вью модель для экрана вопроса
    func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        resetAnswer()
        hideLoadingIndicator()
    }
    
    /// Изменение цвета рамки постера в зависимости от ответа.
    /// - Parameter answer: Ответ пользователя
    func showAnswer(with answer: Bool) {
        let color: CGColor?
        
        if answer == presenter.currentQuestion?.correctAnswer {
            color = UIColor.ypGreen.cgColor
        } else {
            color = UIColor.ypRed.cgColor
        }
        
        imageView.layer.borderColor = color
    }
    
    /// Вывод индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
        view.isUserInteractionEnabled = false
    }
    
    /// Скрытие индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
        view.isUserInteractionEnabled = true
    }
    
    /// Изменение цвета рамки постера на прозрачный
    private func resetAnswer() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    //MARK: - IBActions
    
    @IBAction
    private func yesButtonClicked(_ sender: UIButton) {
        presenter.buttonAction(with: true)
    }
    
    @IBAction
    private func noButtonClicked(_ sender: UIButton) {
        presenter.buttonAction(with: false)
    }
}

// MARK: - Alerts
extension MovieQuizViewController {
    
    /// Вывод результата игры
    ///
    /// Вывод результата игры и статистики всех игр с задержкой в 1 секунду
    func showResults(quiz result: QuizResultsViewModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            let model = presenter.convertResultToAlert(model: result)
            AlertPresenter.resultAlert(on: self, with: model, completion: { [weak self] in
                self?.presenter.restartQuiz()
            })
        }
    }
    
    /// Вывод сообщения о проблемах с сетью
    /// - Parameter message: Описание ошибки
    func showNetworkError(message: String) {
        AlertPresenter.networkErrorAlert(on: self, with: message, completion: { [weak self] in
            self?.presenter.loadQuiz()
        })
    }
    
    /// Вывод сообщения о проблемах с сетью
    func showQuestionsAlert() {
        AlertPresenter.showQuestionNetworkError(on: self, completion: { [weak self] in
            self?.presenter.proceedToNextQuestion()
        })
    }
}
