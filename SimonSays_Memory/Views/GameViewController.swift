import UIKit
import AVFoundation

let kDelayBetweenStages = 0.75
let kPlayDuration = 0.4

class GameViewController: UIViewController {

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

  lazy var colorButtons: Array<UIButton> = {
    return [btn0, btn1, btn2, btn3]
  }()

  @objc var viewModel: GameViewModel!
  private var observers: [NSKeyValueObservation] = []

  func inject(viewModel: GameViewModel) {
    self.viewModel = viewModel
  }

  var progressBarWidth: CGFloat = 0.0
  var audioPlayer: AVAudioPlayer = AVAudioPlayer()

  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    [progressBarFrontView, progressBarBackView, btnWrapperView, startBtn].forEach { v in
      guard let v = v else { return }
      v.layer.cornerRadius = v.frame.height / 2
    }
    progressBarWidth = progressBarFrontView.frame.width
  }

  private func bind() {
    self.observers = [
      observe(\.viewModel.outStartButtonEnabled, options: [.old, .new]) { [unowned self] _, change in
        self.startBtn.isEnabled = change.newValue!
      },
      observe(\.viewModel.outColorButtonsEnabled, options: [.old, .new]) { [unowned self] _, change in
        self.colorButtons.forEach { (btn) in
          btn.isEnabled = change.newValue!
        }
      },
      observe(\.viewModel.outDarkMode, options: [.old, .new]) { [unowned self] _, change in
        self.updateDarkMode(isOn: change.newValue!)
      },
      observe(\.viewModel.outHighScore, options: [.old, .new]) { [unowned self] _, change in
        self.highScoreLabel.text = String(change.newValue!)
      },
      observe(\.viewModel.outCurrentScore, options: [.old, .new]) { [unowned self] _, change in
        self.startBtn.setTitle("\(change.newValue!)", for: .normal)
      },
      observe(\.viewModel.outStageStarted, options: [.old, .new]) { [unowned self] _, change in
        self.startGame()
      },
      observe(\.viewModel.outSound, options: [.old, .new]) { [unowned self] _, change in
        self.playSound(soundName: Sound.all[change.newValue!].rawValue)
      },
      observe(\.viewModel.outStageTimeLimit, options: [.old, .new]) { [unowned self] _, change in
        self.runProgressBar(during: change.newValue!)
      },
      observe(\.viewModel.outFlashButton, options: [.old, .new]) { [unowned self] _, change in
        self.flashBtn(change.newValue!)
      },
      observe(\.viewModel?.outStageEnded, options: [.old, .new]) { [unowned self] _, change in
        self.endGame()
      }
    ]
  }

  deinit {
    observers.removeAll()
  }

  @IBAction func darkModeChanged(_ sender: UISwitch) {
    viewModel.inDarkMode(isOn: sender.isOn)
  }

  @IBAction func startBtnTapped(_ sender: UIButton) {
    viewModel.inStart()
  }

  private func flashBtn(_ index: Int, completion: ((Bool) -> Void)? = nil) {
    let btn = colorButtons[index]
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
    viewModel.inColorButton(button: Button(rawValue: sender.tag)!)
    sender.alpha = 1
  }

  private func startGame() {
    resetProgressBar()
  }

  private func endGame() {
    resetProgressBar()
  }

  private func playSound(soundName: String) {
    guard soundName.count > 0 else { return }
    let audioPath = Bundle.main.path(forResource: soundName, ofType: "wav", inDirectory: "audio")!
    let url = URL(fileURLWithPath: audioPath, isDirectory: true)

    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
    } catch {
      print("nooooo..")
    }
    audioPlayer.play()
  }

  private func answerFromBtn(_ from: UIButton) -> Int {
    return from.tag
  }

  private func runProgressBar(during: Double) {
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

  private func resetProgressBar() {
    progressBarFrontView.layer.removeAllAnimations()
    self.progressBarFrontView.backgroundColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)
    changeWidthOfProgressBar(progressBarWidth)
  }

  private func changeWidthOfProgressBar(_ width: CGFloat) {
    var f = progressBarFrontView.frame
    f.size.width = width
    progressBarFrontView.frame = f
  }

  private func updateDarkMode(isOn: Bool) {
    darkModeSwitch.setOn(isOn, animated: false)

    UIView.animate(withDuration: 1) {
      let color = isOn ? UIColor.black : UIColor.white
      self.view.backgroundColor = color
      self.startBtn.backgroundColor = color
    }
  }
}
