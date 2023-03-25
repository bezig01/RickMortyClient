//
//  RegisterViewController.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class RegisterViewController: UIViewController {
    
    let bag = DisposeBag()
    
    @IBOutlet var usernameField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBOutlet var phoneNumberField: UITextField!
    
    @IBOutlet var agreeButton: UIButton!
    
    @IBOutlet var registerButton: UIButton!
    
    let acceptedRelay = BehaviorRelay<Bool>(value: false)
    var isAccepted: Bool = false {
        didSet {
            acceptedRelay.accept(isAccepted)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAccepted = false
        
        setupBindings()
    }
    
    private func setupBindings() {
        
        let usernameIsEmpty = usernameField.rx.text
            .map { $0?.isEmpty ?? true }
        
        let passwordIsEmpty = passwordField.rx.text
            .map { $0?.isEmpty ?? true }
        
        Observable.combineLatest(usernameIsEmpty, passwordIsEmpty) { !$0 && !$1 }
            .bind(to: agreeButton.rx.isEnabled)
            .disposed(by: bag)
        
        Observable.combineLatest(usernameIsEmpty, passwordIsEmpty, acceptedRelay) { !$0 && !$1 && $2 }
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: bag)
        
        agreeButton.rx.tap
            .bind { [weak self] in self?.isAccepted.toggle() }
            .disposed(by: bag)
        
        acceptedRelay
            .map { UIImage(systemName: $0 ? "checkmark.square" : "square") }
            .bind(to: agreeButton.rx.image(for: .normal))
            .disposed(by: bag)
        
        registerButton.rx.tap
            .bind { [weak self] in self?.registerUser() }
            .disposed(by: bag)
        
    }
    
    private func registerUser() {
        
        guard let username = usernameField.text,
              let password = passwordField.text,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        guard appDelegate.isUsernameAvailable(username) else {
            presentAlert(username)
            return
        }
        
        appDelegate.registerUser(username, password: password, phoneNumber: phoneNumberField.text)
        
        guard appDelegate.tryLogin(username, password: password) else {
            print("WTF")
            return
        }
        dismiss(animated: true)
    }
    
    private func presentAlert(_ username: String) {
        
        let message = "The username \"\(username)\" is already registered."
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.bounds
        
        alertController.addAction(.init(title: "OK", style: .cancel))
        
        present(alertController, animated: true)
    }
}
