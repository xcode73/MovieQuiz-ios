//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 23.05.2024.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        loadQuiz()
    }
    
    func loadQuiz() {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        questionFactory?.loadData()
        viewController?.showSpinner()
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
        viewController?.showSpinner()
        questionFactory?.requestNextQuestion()
    }
    
    /// Вывод следующего вопроса или результата квиза
    /// - Parameter answer: Нажата кнопка: Да - true; Нет - false.
    func buttonAction(with givenAnswer: Bool) {
        storeAnswer(with: givenAnswer)
        viewController?.showAnswer(with: givenAnswer)
        
        if isLastQuestion() {
            viewController?.showResults()
        } else {
            updateQuestionIndex()
            showNextQuestion()
        }
    }
    
    /// Вывод следующего вопроса с задержкой в 1 секунду
    func showNextQuestion() {
        viewController?.showSpinner()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.questionFactory?.requestNextQuestion()
        }
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
        viewController?.hideSpinner()
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
        viewController?.hideSpinner()
        viewController?.showQuestionsAlert()
    }
}
