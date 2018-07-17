import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var stageLabel: UILabel!
  @IBOutlet weak var timeProgressBar: UIProgressView!

  @IBOutlet weak var btn0: UIButton!
  @IBOutlet weak var btn1: UIButton!
  @IBOutlet weak var btn2: UIButton!
  @IBOutlet weak var btn3: UIButton!

  var correctAnswer: [Int] = []
  var userInput: [Int] = []
  var flashed: Int = 0
  var stage = 0

  @IBAction func startBtn(_ sender: UIButton) {
    correctAnswer.removeAll()
    userInput.removeAll()
    flashed = 0
    stage = 0
    stageLabel.text = String("STAGE \(stage)")
    nextStage()
  }

  func nextStage() {
    correctAnswer.append(Int(arc4random_uniform(4)))
    print("correctAnswer \(correctAnswer)")

    userInput.removeAll()
    flashed = 0
    stage += 1
    stageLabel.text = String("STAGE \(stage)")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.autoFlash()
    }
  }

  func autoFlash() {
    if correctAnswer.count <= flashed {
      flashed = 0
      return
    }
    flash(btn: intToBtn(from: correctAnswer[flashed]), completion: { _ in
      self.flashed += 1
      self.autoFlash()
    })
  }

  func intToBtn(from: Int) -> UIButton {
    switch from {
    case 0:
      return btn0
    case 1:
      return btn1
    case 2:
      return btn2
    case 3:
      return btn3
    default:
      fatalError()
    }
  }

  func flash(btn: UIButton, completion: ((Bool) -> Void)? = nil) {
    btn.alpha = 0
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
      btn.alpha = 1
    }, completion: completion)
  }

  func endGame() {
    //game end sound
    // game end pop-up
    correctAnswer.removeAll()
    userInput.removeAll()
    stage = 0
    print("gameEnd")
  }

  // func btns connected btn0,1,2,3
  @IBAction func btns(_ sender: UIButton) {
    userInput.append(sender.tag)
    flash(btn: sender)

    print("userInput: \(userInput)")

    if sender.tag == correctAnswer[userInput.count - 1] {
      if userInput.count == correctAnswer.count {
        nextStage()
      }
    } else {
      endGame()
    }
  }






































}


//func intToBtn(answer from: Int) -> UIButton {
//  switch from {
//  case 0:
//    return btn0
//  case 1:
//    return btn1
//  case 2:
//    return btn2
//  case 3:
//    return btn3
//  default:
//    fatalError()
//  }
//}
//
//func btnToInt(input from: UIButton) -> Int? {
//  switch from {
//  case btn0:
//    return 0
//  case btn1:
//    return 1
//  case btn2:
//    return 2
//  case btn3:
//    return 3
//  default:
//    return nil
//  }
//}

//func flashBtn(btn: UIButton, completion: ((Bool) -> Void)? = nil) {
//  btn.alpha = 0
//  UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
//    btn.alpha = 1.0
//  }, completion: completion)
//}

//extension UIButton {
//  func flashBtn() {
//    let flash = CABasicAnimation(keyPath: "opacity")
//    flash.duration = 0.3
//    flash.fromValue = 0
//    flash.toValue = 1
//    flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//    layer.add(flash, forKey: nil)
//  }
//      // + sound
//}



//  @IBOutlet weak var levelLabel: UILabel!
//  @IBOutlet weak var scoreLabel: UILabel!
//  @IBOutlet weak var secondsLabel: UILabel!
//
//  @IBOutlet weak var topLeftBtn0: UIButton!
//  @IBOutlet weak var topRightBtn1: UIButton!
//  @IBOutlet weak var bttomLeftBtn2: UIButton!
//  @IBOutlet weak var bottomRightBtn3: UIButton!
//
//  var correctAnswer: [Int] = []
//  var currentTap: Int = 0
//  var indexToPlay: Int = 0
//
//  var score: Int = 0
//  var level: Int = 1
//  var seconds: Int = 15
//
//  var timer = Timer()
//
//  @IBAction func startAction(_ sender: Any) {
//    scoreLabel.text = "score: \(0)"
//    levelLabel.text = "level: \(level)"
//    correctAnswer.removeAll()
//    currentTap = 0
//    level = 0
//    nextLevel()
//  }
//
//  func nextLevel() {
//    timer.invalidate()
//    correctAnswer.append(Int(arc4random_uniform(4)))
//    print("answer: \(correctAnswer)")
//    levelLabel.text = "level: \(level)"
//    level += 1
//    currentTap = 0
//    seconds = 15
//    runTimer()
//    playAnswerSequence()
//  }
//
//  func playAnswerSequence() {
//    if correctAnswer.count <= indexToPlay {
//      indexToPlay = 0
//      return
//    }
//    if currentTap > 0 {
//      gameOver()
//    }
//    let index = correctAnswer[indexToPlay]
//    animateAndMakeSound(button: button(forIndex: index), completion: { _ in
//      self.indexToPlay += 1
//      self.playAnswerSequence()
//    })
//  }
//
//  func runTimer() {
//    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
//  }
//  @objc func updateTimer() {
//    secondsLabel.text = String(seconds)
//    if seconds != 0 {
//      seconds -= 1
//    } else {
//      timer.invalidate()
//      gameOver()
//    }
//  }
//
//  @IBAction func tapAction(_ sender: UIButton) {
//    if currentTap >= correctAnswer.count {
//      gameOver()
//      return
//    }
//    let tapIndex = index(forBtn: sender)
//    print("tapped: \(tapIndex)")
//
//    if correctAnswer[currentTap] == tapIndex {
//      currentTap += 1
//      score += 1
//      scoreLabel.text = "score: \(score)"
//      animateAndMakeSound(button: sender, completion: { _ in
//        if self.currentTap == self.correctAnswer.count {
//          self.nextLevel()
//        }
//      })
//    } else {
//      gameOver()
//    }
//  }
//
//  func gameOver() {
//    timer.invalidate()
//    playSound("game_over.wav")
//    correctAnswer.removeAll()
//    currentTap = 0
//    level = 0
//    print("game over")
//  }
//
//  func animateAndMakeSound(button: UIButton, completion: ((Bool) -> Void)? = nil) {
//    button.alpha = 0
//    UIView.animate(withDuration: 0.75, animations: {
//      button.alpha = 1
//    }, completion: completion)
//    playSound("tone\(index(forBtn: button) + 1).wav")
//  }
//
//  func index(forBtn: UIButton) -> Int {
//    switch forBtn {
//    case topLeftBtn0:
//      return 0
//    case topRightBtn1:
//      return 1
//    case bttomLeftBtn2:
//      return 2
//    case bottomRightBtn3:
//      return 3
//    default:
//      fatalError()
//    }
//  }
//
//  func button(forIndex: Int) -> UIButton {
//    switch forIndex {
//    case 0:
//      return topLeftBtn0
//    case 1:
//      return topRightBtn1
//    case 2:
//      return bttomLeftBtn2
//    case 3:
//      return bottomRightBtn3
//    default:
//      fatalError()
//    }
//  }
//}
//
//import AVFoundation
//var audioPlayer: AVAudioPlayer!
//func playSound(_ nameOfAudioFile: String) {
//  let soundURL = Bundle.main.url(forResource: nameOfAudioFile, withExtension: nil, subdirectory: "audio")!
//  audioPlayer = try! AVAudioPlayer(contentsOf: soundURL)
//  try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//  try! AVAudioSession.sharedInstance().setActive(true)
//  audioPlayer.play()
//}
