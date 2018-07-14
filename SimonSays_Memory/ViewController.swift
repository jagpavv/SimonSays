// time interval between next level
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var levelLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!

  @IBOutlet weak var topLeftBtn0: UIButton!
  @IBOutlet weak var topRightBtn1: UIButton!
  @IBOutlet weak var bttomLeftBtn2: UIButton!
  @IBOutlet weak var bottomRightBtn3: UIButton!

  var correctAnswer: [Int] = []
  var currentTap: Int = 0
  var indexToPlay: Int = 0

  var score: Int = 0
  var level: Int = 1

  @IBAction func startAction(_ sender: Any) {
    scoreLabel.text = "score: \(0)"
    levelLabel.text = "level: \(level)"
    correctAnswer.removeAll()
    nextLevel()
  }

  func nextLevel() {
    correctAnswer.append(Int(arc4random_uniform(4)))
    levelLabel.text = "level: \(level)"
    level += 1
    print("answer: \(correctAnswer)")
    currentTap = 0
    playAnswerSequence()
  }

  func playAnswerSequence() {
    if correctAnswer.count <= indexToPlay {
      indexToPlay = 0
      return
    }
    if currentTap > 0 {
      gameOver()
    }
    let index = correctAnswer[indexToPlay]
    animateAndMakeSound(button: button(forIndex: index), completion: { _ in
      self.indexToPlay += 1
      self.playAnswerSequence()
    })
  }

  @IBAction func tapAction(_ sender: UIButton) {
    if currentTap >= correctAnswer.count {
      gameOver()
      return
    }
    let tapIndex = index(forBtn: sender)
    print("tapped: \(tapIndex)")

    if correctAnswer[currentTap] == tapIndex {
      currentTap += 1
      score += 1
      scoreLabel.text = "score: \(score)"
      animateAndMakeSound(button: sender, completion: { _ in
        if self.currentTap == self.correctAnswer.count {
          self.nextLevel()
        }
      })
    } else {
      gameOver()
    }
  }

  func gameOver() {
    print("game over")
    playSound("game_over.wav")
    correctAnswer.removeAll()
  }

  func animateAndMakeSound(button: UIButton, completion: ((Bool) -> Void)? = nil) {
    button.alpha = 0
    UIView.animate(withDuration: 0.75, animations: {
      button.alpha = 1
    }, completion: completion)
    playSound("tone\(index(forBtn: button) + 1).wav")
  }

  func index(forBtn: UIButton) -> Int {
    switch forBtn {
    case topLeftBtn0:
      return 0
    case topRightBtn1:
      return 1
    case bttomLeftBtn2:
      return 2
    case bottomRightBtn3:
      return 3
    default:
      fatalError()
    }
  }

  func button(forIndex: Int) -> UIButton {
    switch forIndex {
    case 0:
      return topLeftBtn0
    case 1:
      return topRightBtn1
    case 2:
      return bttomLeftBtn2
    case 3:
      return bottomRightBtn3
    default:
      fatalError()
    }
  }
}

import AVFoundation
var audioPlayer: AVAudioPlayer!
func playSound(_ nameOfAudioFile: String) {
  let soundURL = Bundle.main.url(forResource: nameOfAudioFile, withExtension: nil, subdirectory: "audio")!
  audioPlayer = try! AVAudioPlayer(contentsOf: soundURL)
  try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
  try! AVAudioSession.sharedInstance().setActive(true)
  audioPlayer.play()
}
