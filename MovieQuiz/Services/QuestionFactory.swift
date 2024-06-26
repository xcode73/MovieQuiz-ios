//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Nikolai Eremenko on 16.04.2024.
//

import Foundation

class QuestionFactory {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
}

// MARK: - QuestionFactoryProtocol

extension QuestionFactory: QuestionFactoryProtocol {
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    let error = mostPopularMovies.errorMessage
                    if !error.isEmpty {
                        self.delegate?.didFailToLoadData(with: nil, errorMessage: error)
                    } else {
                        self.movies = mostPopularMovies.items
                        self.delegate?.didLoadDataFromServer()
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error, errorMessage: nil)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: NSError(), errorMessage: nil)
                }
                return
            }

            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToReceiveNextQuestion()
                }
            }

            func roundedRating(rating: Float) -> Float {
                return Float(round(10 * rating) / 10)
            }
            
            let rating = roundedRating(rating: Float(movie.rating) ?? 0)
            let questionRating = roundedRating(rating: Float.random(in: 8.1...8.9))
            let questionType = Bool.random()
            let text = "Рейтинг этого фильма \(questionType ? "больше" : "меньше") чем \(questionRating)?"
            let correctAnswer = questionType ? (rating > questionRating) : (rating < questionRating)
            
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async {
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
