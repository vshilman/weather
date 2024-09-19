import UIKit

class Coordinator {
    var navigationController: UINavigationController?

    func start() {
        let weatherVC = ViewController()
        weatherVC.viewModel = ViewModel()
        navigationController = UINavigationController(rootViewController: weatherVC)
    }
}
