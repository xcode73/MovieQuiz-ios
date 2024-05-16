//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Properties
    
    lazy var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private lazy var statisticService: StatisticServiceProtocol = StatisticService()
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    
    lazy var currentQuestionIndex: Int = 0
    lazy var correctAnswers: Int = 0
    
    /// StatusBar text color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet
    private var imageView: UIImageView!
    
    @IBOutlet
    private var textLabel: UILabel!
    
    @IBOutlet
    private var counterLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startQuiz()
    }
    
    //MARK: - Methods
    
    private func startQuiz() {
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
    }
    
    /// Конвертация модели вопроса во вью модель вопроса
    /// - Parameter model: модель вопроса
    /// - Returns: вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    /// Конвертация QuizResultsViewModel в AlertModel
    /// - Parameter model: Вью модель результата квиза
    /// - Returns: Модель алерты
    private func convertResultToAlert(model: QuizResultsViewModel) -> AlertModel {
        let alertModel = AlertModel(
            title: model.title,
            message: model.text,
            buttonText: model.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
        )
        return alertModel
    }
    
    /// метод, который выводит вопрос
    /// - Parameter step: вью модель для экрана вопроса
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func createResults() -> QuizResultsViewModel {
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
    
    private func clearImageViewBorder() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    /// Обработка нажатия на кнопку
    /// - Parameter answer: Нажата кнопка Да - true, Нет - false
    ///
    /// Проверка и сохранение ответа.
    /// Изменение цвета рамки постера зависимости от ответа.
    /// Показ алерты с результатом.
    /// Задержка в одну секунду для имитации загрузки вопроса из интернета.
    private func buttonAction(with answer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = answer == currentQuestion.correctAnswer
        let color = answer == currentQuestion.correctAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.borderColor = color
        
        if currentQuestionIndex == questionsAmount - 1 {
            let result = createResults()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.clearImageViewBorder()
                AlertPresenter.resultAlert(on: self, with: convertResultToAlert(model: result))
            }
        } else {
            currentQuestionIndex += 1
            correctAnswers += isCorrect ? 1 : 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.questionFactory.requestNextQuestion()
                self?.clearImageViewBorder()
            }
        }
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
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuestion(quiz: viewModel)
        }
    }
}
