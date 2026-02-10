//
//  ViewController.swift
//  PersonalityQuiz
//
//  Created by Diana on 2/10/26.
//  //

import UIKit

class IntroductionViewController: UIViewController {

    @IBOutlet weak var timedButton: UIButton!

    private var isTimedQuiz = false
    private let timeLimitSeconds = 10

    @IBAction func unwindToQuizIntroduction(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateTimedButtonTitle()
    }

    @IBAction func toggleTimedQuiz(_ sender: UIButton) {
        isTimedQuiz.toggle()
        updateTimedButtonTitle()
    }

    private func updateTimedButtonTitle() {
        let stateText = isTimedQuiz ? "On" : "Off"
        timedButton.setTitle("Timed Quiz: \(stateText) (\(timeLimitSeconds)s/question)", for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController,
              let questionViewController = navigationController.viewControllers.first as? QuestionViewController else {
            return
        }

        let quizIndex = (sender as? UIButton)?.tag ?? 0
        let quiz = QuizBank.quiz(at: quizIndex)
        questionViewController.questions = quiz.questions
        questionViewController.quizTitle = quiz.title
        questionViewController.isTimedQuiz = isTimedQuiz
        questionViewController.timeLimitSeconds = timeLimitSeconds
    }

}
