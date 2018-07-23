import UIKit
import AVFoundation

class ViewController: UIViewController {

  @IBOutlet weak var bestScoreLabel: UILabel!

  @IBOutlet weak var btn0: UIButton!
  @IBOutlet weak var btn1: UIButton!
  @IBOutlet weak var btn2: UIButton!
  @IBOutlet weak var btn3: UIButton!
  @IBOutlet weak var startBtn: UIButton!

  var userDefault = UserDefaults.standard
  var correctAnswers: [Int] = []
  var userInputs: [Int] = []
  var flashedIdx = 0
  var tappedCountIdx = 0
  var stage = 0

  var audioPlayer: AVAudioPlayer = AVAudioPlayer()
  var timer = Timer()
  var remainingSeconds: Float = 10

  @IBAction func startBtnTapped(_ sender: UIButton) {
    correctAnswers.removeAll()
    userInputs.removeAll()
    flashedIdx = 0
    stage = 0
    nextStage()
  }

  func nextStage() {
    tappedCountIdx = 0
    userInputs.removeAll()
    enableAllBtns(false)
    correctAnswers.append(Int(arc4random_uniform(4)))
    print("correctAnswer \(correctAnswers)")

    flashedIdx = 0
    stage += 1
    startBtn.setTitle("\(stage)", for: .normal)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.playSound(soundName: "upNextStage")
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
      self.playBtnFlashAutomatically()
    }
  }

  func enableAllBtns(_ enabled: Bool) {
    btn0.isEnabled = enabled
    btn1.isEnabled = enabled
    btn2.isEnabled = enabled
    btn3.isEnabled = enabled
  }

  func playBtnFlashAutomatically() {
    //    userInputs = correctAnswers
    if correctAnswers.count <= flashedIdx {
      flashedIdx = 0
      enableAllBtns(true)
      return
    }

    let intFromArray = correctAnswers[flashedIdx]
    playBtnFlash(btn: convertIntToBtn(from: intFromArray), completion: {_ in
      self.playSound(soundName: "sound\(intFromArray)")
      self.flashedIdx += 1
      self.playBtnFlashAutomatically()
    })
  }

  func playBtnFlash(btn: UIButton, completion: ((Bool) -> Void)? = nil) {
    btn.alpha = 0.3
    UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseInOut, animations: {
      btn.alpha = 1
    }, completion: completion)
  }

  func convertIntToBtn(from: Int) -> UIButton {
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

  //  func runTimer() {
  //    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(ViewController.timeLimit)), userInfo: nil, repeats: true)
  //  }
  //
  //  @objc func timeLimit() {
  ////    timeProgressBar.setProgress(Float(remainingSeconds)/100.0, animated: true)
  //    if remainingSeconds != 0 {
  //      remainingSeconds -= 1
  //    } else {
  //      timer.invalidate()
  //      endGame()
  //    }
  //  }

  func endGame() {
    playSound(soundName: "gameOver")
    //    timer.invalidate()
    correctAnswers.removeAll()
    userInputs.removeAll()
    stage = 0
    print("gameEnd")
  }

  @IBAction func tapBtn(_ sender: UIButton) {
    sender.flash()
    playSound(soundName: "sound\(sender.tag)")
    userInputs.append(sender.tag)
    print("userInputs: \(userInputs)")

    if sender.tag == correctAnswers[tappedCountIdx] {
      tappedCountIdx += 1
      if userInputs.count == correctAnswers.count {
        tappedCountIdx = 0
        enableAllBtns(false)
        nextStage()
      }
    } else if sender.tag != correctAnswers[tappedCountIdx] {
      tappedCountIdx = 0
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

extension UIButton {
  func flash() {
    let flash = CABasicAnimation(keyPath: "opacity")
    flash.duration = 0.1
    flash.fromValue = 1
    flash.toValue = 0.1
    flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

    layer.add(flash, forKey: nil)
  }
}
