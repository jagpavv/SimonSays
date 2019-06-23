import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    window = UIWindow(frame: UIScreen.main.bounds)

    let gameViewModel = GameViewModel()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let gameView = storyBoard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
    gameView.inject(viewModel: gameViewModel)

    window?.rootViewController = gameView

    window?.makeKeyAndVisible()

    return true
  }
}
