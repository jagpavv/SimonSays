import UIKit
import AVFoundation

class ViewController: UIViewController {

  @IBOutlet weak var stageLabel: UILabel!
  @IBOutlet weak var toastLabel: UILabel!
  @IBOutlet weak var timeProgressBar: UIProgressView!

  @IBOutlet weak var btn0: UIButton!
  @IBOutlet weak var btn1: UIButton!
  @IBOutlet weak var btn2: UIButton!
  @IBOutlet weak var btn3: UIButton!

  var correctAnswer: [Int] = []
  var userInput: [Int] = []
  var flashed: Int = 0
  var stage = 0

  var audioPlayer: AVAudioPlayer = AVAudioPlayer()
  var timer = Timer()
  var seconds: Float = 10

  @IBAction func startBtn(_ sender: UIButton) {
    correctAnswer.removeAll()
    userInput.removeAll()
    flashed = 0
    stage = 0
    stageLabel.text = String("STAGE \(stage)")
    nextStage()
  }

  func nextStage() {
    timer.invalidate()
    correctAnswer.append(Int(arc4random_uniform(4)))
    print("correctAnswer \(correctAnswer)")

    userInput.removeAll()
    flashed = 0
    stage += 1
    stageLabel.text = String("STAGE \(stage)")

    seconds = 10 + Float(stage)

    btn0.isEnabled = true
    btn1.isEnabled = true
    btn2.isEnabled = true
    btn3.isEnabled = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.playSound(soundName: "upNextStage")
      self.showToast(message: "watch and listen")
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
      self.autoFlash()
    }
    print("second: \(seconds)")
  }

  func showToast(message: String) {
    toastLabel.text = message
    toastLabel.alpha = 0
    toastLabel.isHidden = false
    toastLabel.layer.cornerRadius = 10
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 1.2, delay: 0.0, options: .curveEaseOut, animations: {
      self.toastLabel.alpha = 1
    }, completion: {_ in
//      self.toastLabel.alpha = 0
    })
  }

  func autoFlash() {
    var finishedFlash: Bool = false {
      didSet {
        runTimer()
        showToast(message: "Do it!")
      }
    }

    if correctAnswer.count <= flashed {
      flashed = 0
      finishedFlash = true
      return
    }

    let IntFromArray = correctAnswer[flashed]
    flash(btn: intToBtn(from: IntFromArray), completion: { _ in
      self.playSound(soundName: "sound\(IntFromArray)")
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
    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
      btn.alpha = 1
    }, completion: completion)
  }

  func runTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(ViewController.timeLimit)), userInfo: nil, repeats: true)
  }

  @objc func timeLimit() {
    timeProgressBar.setProgress(Float(seconds)/100.0, animated: true)
    if seconds != 0 {
      seconds -= 1
    } else {
      timer.invalidate()
      endGame()
    }
  }

  func endGame() {
    playSound(soundName: "gameOver")
    timer.invalidate()

    btn0.isEnabled = false
    btn1.isEnabled = false
    btn2.isEnabled = false
    btn3.isEnabled = false
    correctAnswer.removeAll()
    userInput.removeAll()
    stage = 0
    print("gameEnd")
  }

  // func btns connected btn0,1,2,3
  @IBAction func btns(_ sender: UIButton) {
    toastLabel.isHidden = true
    userInput.append(sender.tag)
    flash(btn: sender)
    playSound(soundName: "sound\(sender.tag)")

    print("userInput: \(userInput)")

    if sender.tag == correctAnswer[userInput.count - 1] {
      if userInput.count == correctAnswer.count {
        nextStage()
      }
    } else {
      endGame()
    }
  }

  func playSound(soundName: String) {
    let audioPath = Bundle.main.path(forResource: soundName, ofType: "wav", inDirectory: "audio")!
    let url = URL(fileURLWithPath: audioPath, isDirectory: true)

    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
    } catch {
      print("nooooo..")
    }
    audioPlayer.play()
  }
}
