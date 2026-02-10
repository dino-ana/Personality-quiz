//
//  QuestionViewController.swift
//  PersonalityQuiz
//
//  Created by Diana on 2/10/26.
//  //

import UIKit

class QuestionViewController: UIViewController {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var singleStackView: UIStackView!
    
    @IBOutlet weak var multipleStackView: UIStackView!
    
    @IBOutlet weak var rangedStackView: UIStackView!
    @IBOutlet weak var rangedLabel1: UILabel!
    @IBOutlet weak var rangedLabel2: UILabel!
    @IBOutlet weak var rangedSlider: UISlider!
    
    @IBOutlet weak var questionProgressView: UIProgressView!
    
    
    var questions: [Question] = []
    var quizTitle: String?
    var isTimedQuiz: Bool = false
    var timeLimitSeconds: Int = 10
    var elapsedSeconds: Double = 0
    
    var questionIndex = 0
    
    var answersChosen: [Answer] = []
    
    private var currentMultiSwitches: [UISwitch] = []
    private var questionTimer: Timer?
    private var timeRemaining: Int = 0
    private var quizStartTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if questions.isEmpty {
            let quiz = QuizBank.quiz(at: 0)
            questions = quiz.questions
            quizTitle = quiz.title
        }

        questions = QuizBank.shuffledQuestions(questions)
        if isTimedQuiz {
            quizStartTime = Date()
        }
        updateUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        questionTimer?.invalidate()
        questionTimer = nil
    }
    
    func updateUI() {
        
        singleStackView.isHidden = true
        multipleStackView.isHidden = true
        rangedStackView.isHidden = true
        
        navigationItem.title = "Question #\(questionIndex+1)"
        navigationItem.prompt = quizTitle
        
        let currentQuestion = questions[questionIndex]
        let currentAnswers = currentQuestion.answers
        let totalProgress = Float(questionIndex) / Float(questions.count)
        
        questionLabel.text = currentQuestion.text
        questionProgressView.setProgress(totalProgress, animated: true)
        timerLabel.isHidden = !isTimedQuiz
        
        switch currentQuestion.type {
        case .single:
            updateSingleStack(using: currentAnswers)
        case .multiple:
            updateMultipleStack(using: currentAnswers)
        case .ranged:
            updateRangedStack(using: currentAnswers)
        }

        if isTimedQuiz {
            startQuestionTimer()
        } else {
            questionTimer?.invalidate()
            questionTimer = nil
        }
        
    }
    
    func updateSingleStack(using answers: [Answer]) {
        singleStackView.isHidden = false
        resetStackView(singleStackView)
        
        for (index, answer) in answers.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(answer.text, for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.tag = index
            button.addTarget(self, action: #selector(singleAnswerButtonPressed(_:)), for: .touchUpInside)
            singleStackView.addArrangedSubview(button)
        }
    }
    
    func updateMultipleStack(using answers: [Answer]) {
        multipleStackView.isHidden = false
        resetStackView(multipleStackView)
        currentMultiSwitches = []
        
        for (index, answer) in answers.enumerated() {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 16
            
            let label = UILabel()
            label.text = answer.text
            label.numberOfLines = 0
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            let toggle = UISwitch()
            toggle.isOn = false
            toggle.tag = index
            toggle.setContentHuggingPriority(.required, for: .horizontal)
            toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            row.addArrangedSubview(label)
            row.addArrangedSubview(toggle)
            multipleStackView.addArrangedSubview(row)
            currentMultiSwitches.append(toggle)
        }
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit Answer", for: .normal)
        submitButton.addTarget(self, action: #selector(multipleAnswerButtonPressed), for: .touchUpInside)
        multipleStackView.addArrangedSubview(submitButton)
        
    }
    
    func updateRangedStack(using answers: [Answer]) {
        rangedStackView.isHidden = false
        rangedSlider.setValue(0.5, animated: false)
        rangedLabel1.text = answers.first?.text
        rangedLabel2.text = answers.last?.text
    }
    
    @IBAction func singleAnswerButtonPressed(_ sender: UIButton) {
        questionTimer?.invalidate()
        let currentAnswers = questions[questionIndex].answers
        let index = sender.tag
        if index >= 0 && index < currentAnswers.count {
            answersChosen.append(currentAnswers[index])
        }
        
        nextQuestion()
    }
    
    @IBAction func multipleAnswerButtonPressed() {
        questionTimer?.invalidate()
        let currentAnswers = questions[questionIndex].answers
        for toggle in currentMultiSwitches where toggle.isOn {
            let index = toggle.tag
            if index >= 0 && index < currentAnswers.count {
                answersChosen.append(currentAnswers[index])
            }
        }
        
        nextQuestion()
    }
    
    @IBAction func rangedAnswerButtonPressed() {
        questionTimer?.invalidate()
        
        let currentAnswers = questions[questionIndex].answers
        
        let index = Int(round(rangedSlider.value * Float(currentAnswers.count - 1)))
        
        answersChosen.append(currentAnswers[index])
        
        nextQuestion()
        
    }
    
    
    func nextQuestion() {
        questionIndex += 1
        
        if questionIndex < questions.count {
            updateUI()
        } else {
            questionTimer?.invalidate()
            if isTimedQuiz {
                elapsedSeconds = Date().timeIntervalSince(quizStartTime ?? Date())
            }
            performSegue(withIdentifier: "ResultsSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResultsSegue" {
            let resultsViewController = segue.destination as! ResultsViewController
            resultsViewController.responses = answersChosen
            resultsViewController.quizTitle = quizTitle
            resultsViewController.isTimedQuiz = isTimedQuiz
            resultsViewController.timeLimitSeconds = isTimedQuiz ? timeLimitSeconds : nil
            resultsViewController.elapsedSeconds = isTimedQuiz ? elapsedSeconds : nil
        }
    }

    private func startQuestionTimer() {
        questionTimer?.invalidate()
        timeRemaining = max(1, timeLimitSeconds)
        updateTimerLabel()

        questionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeRemaining -= 1
            self.updateTimerLabel()
            if self.timeRemaining <= 0 {
                self.questionTimer?.invalidate()
                self.questionTimer = nil
                self.handleTimeExpired()
            }
        }
    }

    private func updateTimerLabel() {
        timerLabel.text = "Time left: \(timeRemaining)s"
    }

    private func handleTimeExpired() {
        let currentQuestion = questions[questionIndex]
        switch currentQuestion.type {
        case .multiple:
            multipleAnswerButtonPressed()
        case .ranged:
            rangedAnswerButtonPressed()
        case .single:
            nextQuestion()
        }
    }

    private func resetStackView(_ stackView: UIStackView) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
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
