//
//  ViewController.swift
//  SwiftyWords
//
//  Created by Tom Power on 28/07/2015.
//  Copyright (c) 2015 Tom Power. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    //UI outlet labels
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    //Make an array to be filled with 20 buttons
    var letterButtons = [UIButton]()
    //Store buttons here when activated
    var activatedButtons = [UIButton]()
    
    //Parse the text file to store data here
    var solutions = [String]()
    
    //Current level
    var level = 1
    var score: Int = 6 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
        
    
    
    
    @IBAction func submitTapped(sender: AnyObject) {
        //If we can find the current answer in solutions
        if let solutionPosition = find(solutions, currentAnswer.text!) {
            //Clear the array, no longer needed
            activatedButtons.removeAll()
            
            //Split the lines up by carriage returns
            var splitClues = answersLabel.text!.componentsSeparatedByString("\n")
            //Fill in the answer in the label
            splitClues[solutionPosition % 7] = currentAnswer.text
            answersLabel.text = join("\n", splitClues)
            
            currentAnswer.text = ""
            ++score

            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: levelUp))
                ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
            }
        } else {
            
            --score
             let ac = UIAlertController(title: "You Suck Man!", message: "Try harder!", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            currentAnswer.text = ""
            
            //Brings back the hidden buttons
            for btn in activatedButtons {
                btn.hidden = false
            }
            
            activatedButtons.removeAll()
            
            
        }
    }
    
    func levelUp(action: UIAlertAction!) {
        ++level
        loadLevel()
        
        for btn in letterButtons {
            btn.hidden = false
        }
    }
    
    
    @IBAction func clearTapped(sender: AnyObject) {
        
        currentAnswer.text = ""
        
        //Brings back the hidden buttons
        for btn in activatedButtons {
            btn.hidden = false
        }
        
        activatedButtons.removeAll()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        for subview in view.subviews {
            if subview.tag == 1001 {
                let btn = subview as! UIButton
                letterButtons.append(btn)
                btn.addTarget(self, action: "letterTapped:", forControlEvents: .TouchUpInside)
            }
        }
        
        loadLevel()

    }
    
    func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.hidden = true
    }
    
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: "txt") {
            if let levelContents = NSString(contentsOfFile: levelFilePath, usedEncoding: nil, error: nil) {
                var lines = levelContents.componentsSeparatedByString("\n")
                lines.shuffle()
                
                for (index, line) in enumerate(lines as! [String]) {
                    let parts = line.componentsSeparatedByString(": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionString += "\(count(solutionWord)) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
            }
        }
        
        cluesLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answersLabel.text = solutionString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        letterBits.shuffle()
        letterButtons.shuffle()
        
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

