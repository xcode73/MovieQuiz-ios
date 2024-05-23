//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

final class MovieQuizViewController: UIViewController {
    
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
    private lazy var statisticService: StatisticServiceProtocol = StatisticService()
    
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        setDefaultTheme(style: .dark)
    }
    
    //MARK: - Private methods
    
    /// Вывод вопроса
    /// - Parameter step: вью модель для экрана вопроса
    func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        resetAnswer()
        hideSpinner()
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
    func showSpinner() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
        view.isUserInteractionEnabled = false
    }
    
    /// Скрытие индикатора загрузки
    func hideSpinner() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
        view.isUserInteractionEnabled = true
    }
    
    private func setDefaultTheme(style: UIUserInterfaceStyle) {
        if traitCollection.userInterfaceStyle == .light {
            showThemeAlert()
            overrideUserInterfaceStyle = style
        }
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
    
    /// Тема оформления по выбору системы
    private func systemTheme() {
        overrideUserInterfaceStyle = .unspecified
    }
}

// MARK: - Alerts
extension MovieQuizViewController {
    
    /// Вывод результата игры
    ///
    /// Вывод результата игры и статистики всех игр с задержкой в 1 секунду
    func showResults() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            AlertPresenter.resultAlert(on: self, 
                                       with: convertResultToAlert(model: createResults()),
                                       completion: { [weak self] in
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
            self?.presenter.showNextQuestion()
        })
    }
    
    /// Вывод сообщения об изменении темы
    func showThemeAlert() {
        AlertPresenter.themeAlert(on: self, completion: { [weak self] in
            self?.systemTheme()
        })
    }
    
    /// Создание результата игры
    func createResults() -> QuizResultsViewModel {
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        let text =
                    """
                    Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(statisticService.bestGame.correct)/\(presenter.questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """
        
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть ещё раз")
        
        return viewModel
    }
    
    /// Конвертация QuizResultsViewModel в AlertModel
    /// - Parameter model: Вью модель результата квиза
    /// - Returns: Модель алерты
    func convertResultToAlert(model: QuizResultsViewModel) -> AlertModel {
        let alertModel = AlertModel(
            title: model.title,
            message: model.text,
            buttonText: model.buttonText
        )
        return alertModel
    }
}
