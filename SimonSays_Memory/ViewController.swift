import UIKit
import AVFoundation

let kDelayBetweenStages = 0.75
let kPlayDuration = 0.4
let kHighScoreKey = "HighScore"
let kDarkModeKey = "DarkMode"

class ViewController: UIViewController {

  @IBOutlet weak var highScoreLabel: UILabel!

  @IBOutlet weak var progressBarBackView: UIView!
  @IBOutlet weak var progressBarFrontView: UIView!

  @IBOutlet weak var btn0: UIButton!
  @IBOutlet weak var btn1: UIButton!
  @IBOutlet weak var btn2: UIButton!
  @IBOutlet weak var btn3: UIButton!
  @IBOutlet weak var startBtn: UIButton!
  @IBOutlet weak var btnWrapperView: UIView!
  @IBOutlet weak var darkModeSwitch: UISwitch!

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
      highScoreLabel.text = "\(newValue)"
    }
  }

  var isCorrectAnswer: Bool {
    return userInputs == correctAnswers
  }
  var progressBarWidth: CGFloat = 0.0
  var timeLimit: Double = 8
  var audioPlayer: AVAudioPlayer = AVAudioPlayer()

  override func viewDidLoad() {
    super.viewDidLoad()
    highScoreLabel.text = "\(highScore)"
    enableAllBtns(false)

    darkModeSwitch.setOn(userDefault.bool(forKey: kDarkModeKey), animated: false)
    darkModeChanged(darkModeSwitch)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    for v in [progressBarFrontView, progressBarBackView, btnWrapperView, startBtn] {
      guard let v = v else { return }
      v.layer.cornerRadius = v.frame.height / 2
    }

    progressBarWidth = progressBarFrontView.frame.width
  }

  @IBAction func darkModeChanged(_ sender: UISwitch) {
    UIView.animate(withDuration: 1) {
      let color = sender.isOn ? UIColor.black : UIColor.white
      self.view.backgroundColor = color
      self.startBtn.backgroundColor = color
    }
    userDefault.set(sender.isOn, forKey: kDarkModeKey)
    userDefault.synchronize()
  }

  @IBAction func startBtnTapped(_ sender: UIButton) {
    enableStartBtn(false)
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
    resetProgressBar()
    clearUserInputs()
    correctAnswers.append(Int(arc4random_uniform(4)))
    print("correctAnswer \(correctAnswers)")

    DispatchQueue.main.asyncAfter(deadline: .now() + kDelayBetweenStages) {
      self.stage += 1
      self.timeLimit += 1.5
      print("timeLimit: \(self.timeLimit)")
      self.startBtn.setTitle("\(self.stage)", for: .normal)
      self.playSound(soundName: "upNextStage")
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
      runProgressBar(during: timeLimit)
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
      if isCorrectAnswer {
        nextStage()
      }
    } else {
      endGame()
    }

    sender.alpha = 1
  }

  func endGame() {
    resetProgressBar()
    enableAllBtns(false)
    enableStartBtn(true)
    playSound(soundName: "gameOver")
    timeLimit = 8
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

  func enableStartBtn(_ enabled: Bool) {
    startBtn.isEnabled = enabled
  }

  func runProgressBar(during: Double) {
    UIView.animate(withDuration: during,
                   delay: 0,
                   options: .curveLinear,
                   animations: {
                    self.changeWidthOfProgressBar(0)
                    self.progressBarFrontView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
    }) { finished in
      if finished {
        self.endGame()
      }
    }
  }

  func resetProgressBar() {
    progressBarFrontView.layer.removeAllAnimations()
    self.progressBarFrontView.backgroundColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)
    changeWidthOfProgressBar(progressBarWidth)
  }

  func changeWidthOfProgressBar(_ width: CGFloat) {
    var f = progressBarFrontView.frame
    f.size.width = width
    progressBarFrontView.frame = f
  }

}
