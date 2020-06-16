//
//  MainCoordinater.swift
//  MVVMCSample
//
//  Created by Ranjeet Singh on 20/05/20.
//  Copyright © 2020 Ranjeet Singh. All rights reserved.
//

import Foundation
import UIKit


protocol Coordinater: class {
    var parentCoordinater: Coordinater? { get set }
    var navigationController: UINavigationController { get set }
    var childCoordinaters: [Coordinater] { get set }
    var parentVC: UIViewController? { get }
    func navigate()
    func goBackToParent()
}

extension Coordinater {
    
    func childDidFinish(_ coordinater: Coordinater) {
        for (index, childCoordinater) in childCoordinaters.enumerated() {
            if coordinater === childCoordinater {
                self.childCoordinaters.remove(at: index)
                return
            }
        }
    }
    
    func goBackToParent() {
        guard let vc = parentVC else { return }
        self.navigationController.popToViewController(vc, animated: true)
        self.parentCoordinater?.childDidFinish(self)
    }
}

class BaseCoordinater: NSObject, UINavigationControllerDelegate {
    var didFinish: ((_ fromViewController: UIViewController) -> Void)?
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }
        didFinish?(fromViewController)
    }
    
    deinit {
        debugPrint("Coordinater: \(String(describing: self))")
    }
}

class MainCoordinater: BaseCoordinater, Coordinater {
    weak var parentVC: UIViewController?
    
    var parentCoordinater: Coordinater? = nil
    
    var navigationController: UINavigationController
    
    var childCoordinaters = [Coordinater]()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.parentVC = navigationController.topViewController
        super.init()
        self.navigationController.delegate = self
    }
    
    private func setupCoordinater(_ childCoordinater : Coordinater) {
        self.childCoordinaters.append(childCoordinater)
        childCoordinater.parentCoordinater = self
    }
    
    func navigate() {
        let vc = FlickerViewController.instantiate()
        vc.viewModel = FlickerViewModel()
        vc.viewModel.coordinater = self
        
        self.navigationController.pushViewController(vc, animated: true)
    }
}

protocol FlickerCoordinater {
    func showFlickerDetail(viewModel: FlickerItemViewModel)
}

extension MainCoordinater: FlickerCoordinater {
    func showFlickerDetail(viewModel: FlickerItemViewModel) {
        let vc = FlickerDetailViewController.instantiate()
        viewModel.coordinater = self
        vc.viewModel = Observable(viewModel)

        self.navigationController.pushViewController(vc, animated: true)

    }
}
