//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Public properties
    var questionFactory: QuestionFactory?
    lazy var currentQuestionIndex: Int = 0
    lazy var correctAnswers: Int = 0
    
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
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if traitCollection.userInterfaceStyle == .light {
            showThemeAlert()
            overrideUserInterfaceStyle = .dark
        }
        
        loadQuiz()
    }
    
    //MARK: - Private methods
    
    /// Загрузка вопрос
    private func loadQuiz() {
        showSpinner()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        questionFactory?.loadData()
    }
    
    /// Конвертация модели вопроса во вью модель вопроса
    /// - Parameter model: модель вопроса
    /// - Returns: вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    /// Вывод вопроса
    /// - Parameter step: вью модель для экрана вопроса
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderColor = UIColor.clear.cgColor
        hideSpinner()
    }
    
    /// Вывод следующего вопроса или результата квиза
    /// - Parameter answer: Нажата кнопка: Да - true; Нет - false.
    private func buttonAction(with givenAnswer: Bool) {
//        showSpinner()
        storeAnswer(with: givenAnswer)
        showAnswer(with: givenAnswer)
        
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            showNextQuestion()
        }
    }
    
    /// Вывод следующего вопроса с задержкой в 1 секунду
    private func showNextQuestion() {
        showSpinner()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.questionFactory?.requestNextQuestion()
        }
    }
    
    /// Cохранение верного ответа
    /// - Parameter answer: Ответ пользователя
    private func storeAnswer(with answer: Bool) {
        if answer == currentQuestion?.correctAnswer {
            correctAnswers += 1
        }
    }
    
    /// Изменение цвета рамки постера в зависимости от ответа.
    /// - Parameter answer: Ответ пользователя
    private func showAnswer(with answer: Bool) {
        let color: CGColor?
        
        if answer == currentQuestion?.correctAnswer {
            color = UIColor.ypGreen.cgColor
        } else {
            color = UIColor.ypRed.cgColor
        }
        
        imageView.layer.borderColor = color
    }
    
    /// Перезапуск игры
    ///
    /// Сброс текущей статистики и запрос нового вопроса
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showSpinner()
        questionFactory?.requestNextQuestion()
    }
    
    /// Вывод индикатора загрузки
    private func showSpinner() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
        view.isUserInteractionEnabled = false
    }

    private func hideSpinner() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
        view.isUserInteractionEnabled = true
    }
    
    
    
    //MARK: - IBActions
    
    @IBAction
    private func yesButtonClicked(_ sender: UIButton) {
        buttonAction(with: true)
    }
    
    @IBAction
    private func noButtonClicked(_ sender: UIButton) {
        buttonAction(with: false)
    }
    
    /// Тема оформления по выбору системы
    private func systemTheme() {
        overrideUserInterfaceStyle = .unspecified
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    
    /// Cообщение об успешной загрузке
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    /// Cообщение об ошибке загрузки игры
    /// - Parameter error: Описание ошибки
    func didFailToLoadData(with error: any Error) {
        hideSpinner()
        showNetworkError(message: error.localizedDescription)
    }
    
    /// Сообщение об получении следующего вопроса
    /// - Parameter question: Вопрос
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuestion(quiz: viewModel)
        }
    }
    
    func didFailToReceiveNextQuestion() {
        hideSpinner()
        showQuestionsAlert()
    }
}


// MARK: - Alerts
private extension MovieQuizViewController {
    
    /// Вывод результата игры
    ///
    /// Вывод результата игры и статистики всех игр с задержкой в 1 секунду
    func showResults() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            AlertPresenter.resultAlert(on: self, with: convertResultToAlert(model: createResults()))
        }
    }
    
    /// Вывод сообщения о проблемах с сетью
    /// - Parameter message: Описание ошибки
    func showNetworkError(message: String) {
        AlertPresenter.networkErrorAlert(on: self, with: message, completion: { [weak self] in
            self?.loadQuiz()
        })
    }
    
    /// Вывод сообщения о проблемах с сетью
    func showQuestionsAlert() {
        AlertPresenter.showQuestionNetworkError(on: self, completion: { [weak self] in
            self?.showNextQuestion()
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
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let text =
                    """
                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                    Количество сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(statisticService.bestGame.date.dateTimeString))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """
        
        let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть еще раз")
        
        return viewModel
    }
    
    /// Конвертация QuizResultsViewModel в AlertModel
    /// - Parameter model: Вью модель результата квиза
    /// - Returns: Модель алерты
    func convertResultToAlert(model: QuizResultsViewModel) -> AlertModel {
        let alertModel = AlertModel(
            title: model.title,
            message: model.text,
            buttonText: model.buttonText,
            completion: { [weak self] in
                self?.restartQuiz()
            }
        )
        return alertModel
    }
}
