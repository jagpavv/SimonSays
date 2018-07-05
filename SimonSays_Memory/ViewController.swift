// block tapping action while correctAnswer is playing
// time interval between next level

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var scoreLabel: UILabel!

  @IBOutlet weak var topLeftBtn: UIButton!
  @IBOutlet weak var topRightBtn: UIButton!
  @IBOutlet weak var bttomLeftBtn: UIButton!
  @IBOutlet weak var bottomRightBtn: UIButton!

  var correctAnswer: [Int] = []
  var currentTap: Int = 0
  var indexToPlay: Int = 0
  var score: Int = 0

  @IBAction func startAction(_ sender: Any) {
    correctAnswer = []
    extendcorrectAnswer()
    scoreLabel.text = "score: \(0)"
  }

  func extendcorrectAnswer() {
    correctAnswer.append(Int(arc4random_uniform(4)))
    currentTap = 0
    playMySequence()
    print("answer: \(correctAnswer)")
  }

  func playMySequence() {
    if correctAnswer.count <= indexToPlay {
      indexToPlay = 0
      return
    }
    let index = correctAnswer[indexToPlay]
    animateAndMakeSound(button: button(forIndex: index), completion: { _ in
      self.indexToPlay += 1
      self.playMySequence()
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
          self.extendcorrectAnswer()
        }
      })
    } else {
      gameOver()
    }
  }

  func gameOver() {
    print("game over")
    playSound("game_over.wav")
    correctAnswer = []
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
    case topLeftBtn:
      return 0
    case topRightBtn:
      return 1
    case bttomLeftBtn:
      return 2
    case bottomRightBtn:
      return 3
    default:
      fatalError()
    }
  }

  func button(forIndex: Int) -> UIButton {
    switch forIndex {
    case 0:
      return topLeftBtn
    case 1:
      return topRightBtn
    case 2:
      return bttomLeftBtn
    case 3:
      return bottomRightBtn
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
