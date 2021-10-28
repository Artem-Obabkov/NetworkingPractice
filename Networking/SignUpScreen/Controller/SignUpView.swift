//
//  SignUpView.swift
//  Networking
//
//  Created by pro2017 on 14/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import UIKit
import Firebase

class SignUpView: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    var activityIndicator: UIActivityIndicatorView?
    
    // Создаем кнопку для входа
    lazy var continiueButton: UIButton = {
        
        let button = UIButton()
        
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 100)
        
        button.setTitle("Continiue", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.darkGray, for: .normal)
        
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 5
        
        button.addTarget(self, action: #selector(performSignInAction), for: .touchUpInside)
        
        return button
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        isButtonEnable(enable: false)
        
        // Добавляем селекторов для textView, что бы можно было проверять введенный текст
        self.usernameTF.addTarget(self, action: #selector(tfAction), for: .editingChanged)
        self.emailTF.addTarget(self, action: #selector(tfAction), for: .editingChanged)
        self.passwordTF.addTarget(self, action: #selector(tfAction), for: .editingChanged)
        self.confirmPasswordTF.addTarget(self, action: #selector(tfAction), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Добавляем обзервера, что бы можно было определить высоту клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupView() {
        self.usernameTF.setBottomBorder(with: .white)
        self.emailTF.setBottomBorder(with: .white)
        self.passwordTF.setBottomBorder(with: .white)
        self.confirmPasswordTF.setBottomBorder(with: .white)
        
        self.view.addSubview(continiueButton)
        
        // Добавляем activityIndicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.color = .white
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = continiueButton.center
        
        self.activityIndicator = activityIndicator
        self.view.addSubview(self.activityIndicator!)
    }
    
    private func isButtonEnable(enable: Bool) {
        
        if enable {
            self.continiueButton.alpha = 1
            self.continiueButton.isEnabled = true
        } else {
            self.continiueButton.alpha = 0.5
            self.continiueButton.isEnabled = false
        }
    }
    
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        
        // Получаем размеры клавиатуры
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        continiueButton.center = CGPoint(x: self.view.center.x , y: self.view.frame.height - keyboardFrame.height - 16 - self.continiueButton.frame.height / 2 )
        
        activityIndicator!.center = CGPoint(x: self.view.center.x , y: self.view.frame.height - keyboardFrame.height - 16 - self.activityIndicator!.frame.height / 2 )
    }
    
    
    @objc func keyboardWillDisappear(notification: NSNotification) {
        
        continiueButton.center = CGPoint(x: self.view.center.x , y: self.view.frame.height - 100 )
        
        activityIndicator!.center = CGPoint(x: self.view.center.x , y: self.view.frame.height - 100 )
    }
    
    
    @objc func tfAction() {
        
        guard
            let username = usernameTF.text,
            let email = emailTF.text,
            let password = passwordTF.text,
            let confirmPassword = confirmPasswordTF.text
        else { return }
        
        var formFilled = !(email.isEmpty) && !(password.isEmpty) && !(username.isEmpty) && !(confirmPassword.isEmpty)
        
        if (password != confirmPassword) && password.count >= 6 {
            
            self.passwordTF.setBottomBorder(with: .red)
            self.confirmPasswordTF.setBottomBorder(with: .red)
            formFilled = false
            
        } else {
            
            self.passwordTF.setBottomBorder(with: .white)
            self.confirmPasswordTF.setBottomBorder(with: .white)
            formFilled = true
        }
        
        self.isButtonEnable(enable: formFilled)
    }
    
    
    
    @objc func performSignInAction() {
        
        // Отключаем кнопку, и активируем индикатор загрузки, что бы пользователь понимал что что то происходит
        self.isButtonEnable(enable: false)
        continiueButton.setTitle("", for: .normal)
        activityIndicator?.startAnimating()
        activityIndicator?.hidesWhenStopped = true
        
        // Извлекаем email, имя пользователя и пароль
        guard
            let email = emailTF.text,
            let username = usernameTF.text,
            let password = passwordTF.text
        else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            // Обрабатываем ошибку
            if let error = error {
                print(error.localizedDescription)
                
                // Снова включваем кнопку, что бы у пользователя была возможность повторно зарегестрироваться
                self.isButtonEnable(enable: true)
                self.continiueButton.setTitle("Continiue", for: .normal)
                self.activityIndicator?.stopAnimating()
                
                return
            }
            
            // Мы так же можем добавить имя пользователя в Firebase, для этого нам нужно создать запрос на изменение
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                
                // Изменяем имя пользователя в Firebase
                changeRequest.displayName = username
                
                // Подтверждаем запрос
                changeRequest.commitChanges { (error) in
                    
                    // Обрабатываем ошибку
                    if let error = error {
                        print(error.localizedDescription)
                        
                        // Снова включваем кнопку, что бы у пользователя была возможность повторно зарегестрироваться
                        self.isButtonEnable(enable: true)
                        self.continiueButton.setTitle("Continiue", for: .normal)
                        self.activityIndicator?.stopAnimating()
                    }
                    
                    return
                }
            }
            
            // Что бы закрыть сразу несколько viewController-ов мы должны знать их количество и последовательно их закрыть
            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true)
            
        }
        
    }
    
}
