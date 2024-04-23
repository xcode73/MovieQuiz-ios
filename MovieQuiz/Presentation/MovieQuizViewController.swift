//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 18.04.2024.
//

import UIKit

/// Вью контроллер для квиза
final class MovieQuizViewController: UIViewController {
    
    // MARK: - Properties
    
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var alertPresenter: AlertPresenterProtocol = AlertPresenter()
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    
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
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
    }
    
    //MARK: - Methods
    
    /// метод конвертации
    /// - Parameter model: модель вопроса
    /// - Returns: вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/10")
        return questionStep
    }
    
    /// метод, который выводит вопрос
    /// - Parameter step: вью модель для экрана вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    /// метод, который меняет цвет и размер рамки в зависимости от ответа
    /// - Parameter isCorrect: принимает булевое значение
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        correctAnswers += isCorrect ? 1 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
    }
    
    /// метод, который содержит логику перехода в один из сценариев: квиз окончен - результат; следующий вопрос.
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                        "Поздравляем, вы ответили на 10 из \(questionsAmount)!":
                        "Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте еще раз!"
            
            let resultModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            
            alertPresenter.resultAlert(model: resultModel)
        } else {
            currentQuestionIndex += 1
            questionFactory.requestNextQuestion()
        }
    }
    
    //MARK: - IBActions
    
    @IBAction
    private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction
    private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
            self?.show(quiz: viewModel)
        }
    }
}

// MARK: - AlertPresenterDelegate

extension MovieQuizViewController: AlertPresenterDelegate {
    func showResultAlert(model: AlertModel?) {
        guard let model = model else {
            return
        }
        
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        alert.addAction(action)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}
