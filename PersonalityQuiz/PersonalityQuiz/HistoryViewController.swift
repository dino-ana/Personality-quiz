//
//  HistoryViewController.swift
//  PersonalityQuiz
//
//  Created by Diana on 2/10/26.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!

    private var entries: [QuizHistoryEntry] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        entries = QuizHistoryStore.load()
        emptyStateLabel.isHidden = !entries.isEmpty
        tableView.reloadData()
    }

    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = entries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "HistoryCell")

        let dateText = dateFormatter.string(from: entry.date)
        cell.textLabel?.text = "\(entry.quizTitle) • \(dateText)"

        var detail = "Result: \(entry.resultEmoji)"
        if entry.isTimed {
            if let limit = entry.timeLimitSeconds {
                detail += " • Timed: \(limit)s/question"
            } else {
                detail += " • Timed"
            }
            if let elapsed = entry.elapsedSeconds {
                detail += " • Time: \(formatDuration(elapsed))"
            }
        }
        cell.detailTextLabel?.text = detail
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }

    private func formatDuration(_ seconds: Double) -> String {
        let total = max(0, Int(round(seconds)))
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
