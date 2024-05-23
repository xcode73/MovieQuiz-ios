//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 23.05.2024.
//

import UIKit

final class MovieQuizPresenter {
    var currentQuestion: QuizQuestion?
    
    private let statisticService: StatisticService!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        loadQuiz()
    }
    
    func loadQuiz() {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }
    
    
    /// Конвертация модели вопроса во вью модель вопроса
    /// - Parameter model: модель вопроса
    /// - Returns: вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func updateQuestionIndex() {
        currentQuestionIndex += 1
    }
    
    /// Cохранение верного ответа
    /// - Parameter answer: Ответ пользователя
    func storeAnswer(with answer: Bool) {
        if answer == currentQuestion?.correctAnswer {
            correctAnswers += 1
        }
    }
    
    /// Перезапуск игры
    ///
    /// Сброс текущей статистики и запрос нового вопроса
    func restartQuiz() {
        resetQuestionIndex()
        correctAnswers = 0
        viewController?.showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    /// Вывод следующего вопроса или результата квиза
    /// - Parameter answer: Нажата кнопка: Да - true; Нет - false.
    func buttonAction(with givenAnswer: Bool) {
        storeAnswer(with: givenAnswer)
        viewController?.showAnswer(with: givenAnswer)
        
        if isLastQuestion() {
            let results = createResults()
            viewController?.showResults(quiz: results)
        } else {
            updateQuestionIndex()
            proceedToNextQuestion()
        }
    }
    
    /// Вывод следующего вопроса с задержкой в 1 секунду
    func proceedToNextQuestion() {
        viewController?.showLoadingIndicator()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.questionFactory?.requestNextQuestion()
        }
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

// MARK: - QuestionFactoryDelegate

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    /// Cообщение об успешной загрузке
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    /// Cообщение об ошибке загрузки игры
    /// - Parameter error: Описание ошибки
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: message)
    }
    
    /// Сообщение об получении следующего вопроса
    /// - Parameter question: Вопрос
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuestion(quiz: viewModel)
        }
    }
    
    /// Cообщение об ошибке при получении вопроса
    func didFailToReceiveNextQuestion() {
        viewController?.hideLoadingIndicator()
        viewController?.showQuestionsAlert()
    }
}
