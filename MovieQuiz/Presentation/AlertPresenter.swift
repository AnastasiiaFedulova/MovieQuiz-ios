//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Anastasiia on 08.10.2024.
//

import Foundation
import UIKit

class AlertPresenter {
    weak var delegate: MovieQuizViewController?
    func alert (alertData: AlertModel) {
        let alert = UIAlertController(title: alertData.title,
                                      message: alertData.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertData.buttonText, style: .default) { _ in alertData.completion()
            }
        
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
     func setup(delegate: MovieQuizViewController) {
        self.delegate = delegate
    }
}
