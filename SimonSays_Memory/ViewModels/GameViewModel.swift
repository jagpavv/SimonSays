import Foundation

enum Sound: String {
  case upNextStage
  case gameOver
  static let all: [Sound] = [.upNextStage, .gameOver]
}

enum Button: Int {
  case b0
  case b1
  case b2
  case b3
}

class GameViewModel: NSObject {
  private let kHighScoreKey = "HighScore"
  private let kDarkModeKey = "DarkMode"

  // Inputs
  func inStart() {
    outStartButtonEnabled = false
    newGame()
    outStageStarted = 1
    nextStage()
  }

  func inColorButton(button: Button) {
    let guess = button.rawValue
    userInputs.append(guess)
    print("userInputs: \(userInputs)")

    if guess == correctAnswers[inputIdx] {
      inputIdx += 1
      if isCorrectAnswer {
        outStageStarted += 1
        nextStage()
      }
    } else {
      endGame()
      outStageEnded += 1
    }
  }

  func inDarkMode(isOn: Bool) {
    isDarkModeOn = isOn
  }

  // outputs
  @objc dynamic var outHighScore: Int = 0
  @objc dynamic var outCurrentScore: Int = 0
  @objc dynamic var outDarkMode: Bool = false
  @objc dynamic var outStartButtonEnabled: Bool = true
  @objc dynamic var outColorButtonsEnabled: Bool = false
  @objc dynamic var outSound: Int = 0
  @objc dynamic var outFlashButton: Int = 0
  @objc dynamic var outStageStarted: Int = 0
  @objc dynamic var outStageEnded: Int = 0
  @objc dynamic var outStageTimeLimit: Double = 0

  private let userDefault = UserDefaults.standard
  private var correctAnswers: [Int] = []
  private var userInputs: [Int] = []
  private var playedIdx = 0
  private var inputIdx = 0
  private var stage = 0
  private var highScore: Int {
    get {
      return userDefault.integer(forKey: kHighScoreKey)
    }
    set {
      userDefault.set(newValue, forKey: kHighScoreKey)
      userDefault.synchronize()
      outHighScore = newValue
    }
  }

  private var isDarkModeOn: Bool {
    get {
      return userDefault.bool(forKey: kDarkModeKey)
    }
    set {
      userDefault.set(newValue, forKey: kDarkModeKey)
      userDefault.synchronize()
      outDarkMode = newValue
    }
  }

  private var isCorrectAnswer: Bool {
    return userInputs == correctAnswers
  }

  private var timeLimit: Double = 8

  private func newGame() {
    correctAnswers.removeAll()
    playedIdx = 0
    stage = 0
    clearUserInputs()
  }

  private func clearUserInputs() {
    userInputs.removeAll()
    inputIdx = 0
  }

  private func darkModeChanged(isOn: Bool) {
    userDefault.set(isOn, forKey: kDarkModeKey)
    userDefault.synchronize()
  }

  private func nextStage() {
    clearUserInputs()
    correctAnswers.append(Int(arc4random_uniform(4)))
    print("correctAnswer \(correctAnswers)")

    DispatchQueue.main.asyncAfter(deadline: .now() + kDelayBetweenStages) {
      self.stage += 1
      self.timeLimit += 1.5
      print("timeLimit: \(self.timeLimit)")
      self.outCurrentScore = self.stage
      self.outSound = 0 // Sound.upNextStage.rawValue
    }

    playedIdx = 0
    outColorButtonsEnabled = false

    DispatchQueue.main.asyncAfter(deadline: .now() + (kDelayBetweenStages + 1.0)) {
      self.playAnswer()
    }
  }

  private func playAnswer() {
    guard playedIdx < correctAnswers.count else {
      playedIdx = 0
      outColorButtonsEnabled = true
      outStageTimeLimit = timeLimit
      return
    }

    let answer = correctAnswers[playedIdx]
    outFlashButton = answer
    DispatchQueue.main.asyncAfter(deadline: .now() + kPlayDuration) {
      self.playedIdx += 1
      self.playAnswer()
    }
  }

  private func endGame() {
    outColorButtonsEnabled = false
    outStartButtonEnabled = true
    outSound = 1 // Sound.gameOver.rawValue

    timeLimit = 8
    let finalScore = stage - 1
    let highestScore = finalScore > highScore ? finalScore : highScore
    highScore = highestScore
    outCurrentScore = finalScore
    print("gameEnd")
  }

}
