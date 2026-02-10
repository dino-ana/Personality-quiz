//
//  ResultsViewController.swift
//  PersonalityQuiz
//
//  Created by Diana on 2/10/26.
//  //

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var resultAnswerLabel: UILabel!
    @IBOutlet weak var resultDefinitionLabel: UILabel!
    
    
    var responses: [Answer]!
    var quizTitle: String?
    var isTimedQuiz: Bool = false
    var timeLimitSeconds: Int?
    var elapsedSeconds: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let resultEmoji = calculatePersonalityResult()
        saveResult(resultEmoji: resultEmoji)
        navigationItem.hidesBackButton = true
        
    }
    
    func calculatePersonalityResult() -> String {
        guard !responses.isEmpty else {
            resultAnswerLabel.text = "No result"
            resultDefinitionLabel.text = "You did not answer any questions."
            return "—"
        }

        var frequencyOfAnswers: [AnimalType: Int] = [:]
        let responseTypes = responses.map{ $0.type }
        
        for response in responseTypes {
            frequencyOfAnswers[response] = (frequencyOfAnswers[response] ?? 0) + 1
        }
        
        let frequentAnswersSorted = frequencyOfAnswers.sorted(by:
        {(pair1, pair2) -> Bool in
            return pair1.value > pair2.value
        })
        
        let mostCommonAnswer = frequentAnswersSorted.first!.key
        
        resultAnswerLabel.text = "You are a \(mostCommonAnswer.rawValue)!"
        resultDefinitionLabel.text = mostCommonAnswer.definition
        
        return String(mostCommonAnswer.rawValue)
    }

    private func saveResult(resultEmoji: String) {
        let entry = QuizHistoryEntry(
            id: UUID(),
            date: Date(),
            quizTitle: quizTitle ?? "Personality Quiz",
            resultEmoji: resultEmoji,
            isTimed: isTimedQuiz,
            timeLimitSeconds: isTimedQuiz ? timeLimitSeconds : nil,
            elapsedSeconds: isTimedQuiz ? elapsedSeconds : nil
        )
        QuizHistoryStore.add(entry)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
