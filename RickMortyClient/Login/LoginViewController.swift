//
//  LoginViewController.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var resetButton: UIButton!
    
    @IBOutlet var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    private func setupBindings() {
        
        let usernameIsEmpty = usernameField.rx.text
            .map { $0?.isEmpty ?? true }
        
        let passwordIsEmpty = passwordField.rx.text
            .map { $0?.isEmpty ?? true }
        
        Observable.combineLatest(usernameIsEmpty, passwordIsEmpty) { !$0 && !$1 }
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: bag)
        
        usernameIsEmpty
            .map { !$0 }
            .bind(to: resetButton.rx.isEnabled)
            .disposed(by: bag)
        
        loginButton.rx.tap
            .bind { [weak self] in self?.checkCredentials() }
            .disposed(by: bag)
        
        resetButton.rx.tap
            .bind { [weak self] in self?.resetPassword() }
            .disposed(by: bag)
        
        registerButton.rx.tap
            .bind { [weak self] in self?.presentRegister() }
            .disposed(by: bag)
        
    }
    
    private func checkCredentials() {
        guard let username = usernameField.text,
              let password = passwordField.text,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        guard appDelegate.tryLogin(username, password: password) else {
            presentAlert(.invalidCredentials)
            return
        }
        
        dismiss(animated: true)
    }
    
    private func resetPassword() {
        guard let username = usernameField.text,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        guard !appDelegate.isUsernameAvailable(username) else {
            presentAlert(.userNotFound)
            return
        }
        
        appDelegate.resetPassword(username, password: "123")
        presentAlert(.hasBeenReset(username))
    }
    
    private func presentAlert(_ type: Alert) {
        let message: String
        switch type {
        case .invalidCredentials:
            message = "Invalid credentials. Please try again!"
        case .hasBeenReset(let username):
            message = "The password has been reset to \"123\" for username: \"\(username)\"."
        case .userNotFound:
            message = "User not found. Please try again!"
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.bounds
        
        alertController.addAction(.init(title: "OK", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func presentRegister() {
        
        let viewController = RegisterViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension LoginViewController {
    
    enum Alert {
        case invalidCredentials
        case hasBeenReset(_ username: String)
        case userNotFound
    }
}
