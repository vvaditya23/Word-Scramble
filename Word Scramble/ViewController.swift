//
//  ViewController.swift
//  Word Scramble
//
//  Created by ヴィヤヴャハレ・アディティヤ on 29/11/23.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()   //holds all the words in the file
    var usedWords = [String]()  //holds all the valid words from user I/P
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Loaded")
        
        //display the plus button on right top corner
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        //fetch the words from file and feed it to the allWords array
        if let startWordsURL = Bundle.main.url(forResource: "words", withExtension: ".txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["error"]
        }
        
        startGame()
    }
}

extension ViewController {
    //give the title to nav cont. and make sure tableview is empty
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    //brings up popup to take user I/P
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter word", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}    //this answer propert is used further to check the validity of word
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerCasedAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        if isPossible(word: lowerCasedAnswer) {
            if isOriginal(word: lowerCasedAnswer) {
                if isReal(word: lowerCasedAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                } else {
                    errorTitle = "Word not recognized."
                    errorMessage = "You can't just make it up, you know!"
                }
            } else {
                errorTitle = "Word already used."
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible."
            errorMessage = "You cant spell '\(answer)' from '\(title!.lowercased())'."
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
        present(ac, animated: true)
    }
    
    //check if the I/P word can be made up from word
    func isPossible(word: String) -> Bool{
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    //checks that I/P word should be repeated
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    //checks the I/P word with dictionary (objC)
    func isReal(word: String) -> Bool {
        if word.count < 3 {
            return false
        } else {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            return misspelledRange.location == NSNotFound
        }
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}
