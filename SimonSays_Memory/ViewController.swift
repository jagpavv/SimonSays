import UIKit
import AVFoundation

let kDelayBetweenStages = 0.75
let kPlayDuration = 0.4
let kHighScoreKey = "HighScore"

class ViewController: UIViewController {

  @IBOutlet weak var highScoreLabel: UILabel!
  @IBOutlet weak var timePorgressBar: UIProgressView!

  @IBOutlet weak var btn0: UIButton!
  @IBOutlet weak var btn1: UIButton!
  @IBOutlet weak var btn2: UIButton!
  @IBOutlet weak var btn3: UIButton!
  @IBOutlet weak var startBtn: UIButton!

  let userDefault = UserDefaults.standard
  var correctAnswers: [Int] = []
  var userInputs: [Int] = []
  var playedIdx = 0
  var inputIdx = 0
  var stage = 0
  var highScore: Int {
    get {
      return userDefault.integer(forKey: kHighScoreKey)
    }
    set {
      userDefault.set(newValue, forKey: kHighScoreKey)
      userDefault.synchronize()
      highScoreLabel.text = "High score: \(newValue)"
    }
  }

  var timer = Timer()
  var totalTimeLimit: Float = 0
  var remainingTime: Float = 0 {
    didSet {
      let progress = remainingTime / totalTimeLimit
      timePorgressBar.setProgress(progress, animated: true)
    }
  }
  var audioPlayer: AVAudioPlayer = AVAudioPlayer()

  override func viewDidLoad() {
    super.viewDidLoad()
    highScoreLabel.text = "High score: \(highScore)"
    enableAllBtns(false)
  }

  @IBAction func startBtnTapped(_ sender: UIButton) {
    newGame()
    nextStage()
  }

  func newGame() {
    correctAnswers.removeAll()
    playedIdx = 0
    stage = 0
    clearUserInputs()
  }

  func clearUserInputs() {
    userInputs.removeAll()
    inputIdx = 0
  }

  func nextStage() {
    clearUserInputs()
    correctAnswers.append(Int(arc4random_uniform(4)))
    print("correctAnswer \(correctAnswers)")

    DispatchQueue.main.asyncAfter(deadline: .now() + kDelayBetweenStages) {
      self.stage += 1
      self.startBtn.setTitle("\(self.stage)", for: .normal)
      self.playSound(soundName: "upNextStage")
      self.resetTimer()
    }

    playedIdx = 0
    enableAllBtns(false)
    DispatchQueue.main.asyncAfter(deadline: .now() + (kDelayBetweenStages + 1.0)) {
      self.playAnswer()
    }
  }

  func playAnswer() {
    guard playedIdx < correctAnswers.count else {
      playedIdx = 0
      enableAllBtns(true)
      runTimer()
      return
    }

    let answer = correctAnswers[playedIdx]
    let btn = btnFromAnswer(answer)
    flashBtn(btn) {_ in
      self.playedIdx += 1
      self.playAnswer()
    }
  }

  func flashBtn(_ btn: UIButton, completion: ((Bool) -> Void)? = nil) {
    btn.alpha = 0.3
    let answer = answerFromBtn(btn)
    playSound(soundName: "sound\(answer)")
    UIView.animate(
      withDuration: kPlayDuration,
      delay: 0.0,
      options: .curveEaseInOut,
      animations: {
        btn.alpha = 1
      },
      completion: completion
    )
  }

  @IBAction func btnDown(_ sender: UIButton) {
    let guess = answerFromBtn(sender)
    self.playSound(soundName: "sound\(guess)")
    sender.alpha = 0.3
  }

  @IBAction func btnUp(_ sender: UIButton) {
    let guess = answerFromBtn(sender)
    userInputs.append(guess)
    print("userInputs: \(userInputs)")

    if guess == correctAnswers[inputIdx] {
      inputIdx += 1
      if userInputs.count == correctAnswers.count {
        nextStage()
      }
    } else {
      endGame()
    }

    sender.alpha = 1
  }

  func endGame() {
    enableAllBtns(false)
    playSound(soundName: "gameOver")
    stopTimer()

    let finalScore = stage - 1
    let highestScore = finalScore > highScore ? finalScore : highScore
    highScore = highestScore
    startBtn.setTitle("\(finalScore)", for: .normal)

    print("gameEnd")
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

  func answerFromBtn(_ from: UIButton) -> Int {
    return from.tag
  }

  func btnFromAnswer(_ from: Int) -> UIButton {
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

  func enableAllBtns(_ enabled: Bool) {
    btn0.isEnabled = enabled
    btn1.isEnabled = enabled
    btn2.isEnabled = enabled
    btn3.isEnabled = enabled
  }

  func resetTimer() {
    timer.invalidate()
    totalTimeLimit = Float(stage) + 3
    remainingTime = totalTimeLimit
  }

  func runTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTime)), userInfo: nil, repeats: true)
  }

  func stopTimer() {
    timer.invalidate()
  }

  @objc func updateTime() {
    if remainingTime > 0 {
      remainingTime -= 1
      if remainingTime == 0 {
        endGame()
      }
    }
  }

}
