//
//  LoginView.swift
//  Networking
//
//  Created by pro2017 on 12/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseDatabase



class LoginView: UIViewController {
    
    // Создаем свойство с типом userData, в него будем пердавать данные пользователя, которые мы будем получать с методов fetchFacebookFields и signInWithGoogle
    var userProfile: UserData?

    // Создаем кнопку
    lazy var fbLoginButton: UIButton = {
        let button = FBLoginButton()
        button.delegate = self
        button.frame = CGRect(x: 32, y: 500, width: self.view.frame.width - 64, height: 50)
        return button
    }()
    
    // Создаем кастомную кнопку
    lazy var customFBLoginButton: UIButton = {
        
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        button.setTitle("Login with Facebook", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 32, y: 500 + 80, width: self.view.frame.width - 64, height: 50)
        
        // Добавляем target, т.к именно через него будет происзодить логика нажатия
        button.addTarget(self, action: #selector(handleCustomLogOut), for: .touchUpInside)
        return button
        
    }()
    
    // Создаем кнопку регистрации Google
    lazy var googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.frame = CGRect(x: 32, y: 500 + 80 + 80, width: self.view.frame.width - 64, height: 50)
        button.addTarget(self, action: #selector(handleGoogleButtonTap), for: .touchUpInside)
        return button
    }()
    
    // Создаем кнопку для регистрации с помошью email
    lazy var emailLoginButton: UIButton = {
        
        let button = UIButton()
        
        button.frame = CGRect(x: 32, y: 500 + 80 + 80 + 80, width: self.view.frame.width - 64, height: 50)
        button.setTitle("Sign in with email", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(emailButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        
    }
    
    // Добавляем subView и после вызываем во viewDidLoad
    private func setupView() {
        self.view.addSubview(fbLoginButton)
        self.view.addSubview(customFBLoginButton)
        self.view.addSubview(googleLoginButton)
        self.view.addSubview(emailLoginButton)
    }

}

// MARK: - Facebook SDK

// Отслеживание входа в приложение
extension LoginView: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        // Проверяем есть ли ошибка
        if error != nil {
            print(error?.localizedDescription ?? "")
            return
        }
        
        //  Проверяем активность токена (пользователя) и если он активен, то входим в приложение
        guard AccessToken.isCurrentAccessTokenActive else { return }
        
        
        // Код при успешном входе
        print("SUCCESSFULLY LOGGED IN SUKA")
        self.signIntoFirebase()
    }
    
    // Код при успешном выходе
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("PIZDEC SUKA I'A PO S'EBAM")
    }
    
    func showMainViewController() {
        dismiss(animated: true)
        print("Showing main view ")
    }
    
    
    @objc private func handleCustomLogOut() {
        
        // Добираемся до метода logIn. В массив permissions передаем публично доступные способы входа. Их можно найти в документации нашего приложения на сайте facebook в разделе расширения и функии
        LoginManager().logIn(permissions: ["email", "public_profile"], from: self) { (result, error) in
            
            // Обрабатываем ошибку
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // Извлекаем опционал result
            guard let result = result else { return }
            
            // Обрабатываем ветку в том случае если пользоатель решил отказаться от входа в последний момент
            if result.isCancelled { return }
            else {
                // Входим с данными пользователя в Firebase
                self.signIntoFirebase()
                
                // Мы должны перейти на основной жкран только после того, как данные успешно будут сохранены в firebase, поэтому переносим этот метод в saveIntoFirebase()
//                // Переходим на основной экран
//                self.showMainViewController()
            }
        }
    }
    
    private func signIntoFirebase() {
        
        // Получаем текущий токен пользователяя
        let accessToken = AccessToken.current
        
        // Преобразовываем его в тип String
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        // Мы передаем текущий токен пользователя и полномочия в Firebase для последующей регистрации в Firebase
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        // Регистрируем пользователя с данными Facebook
        Auth.auth().signIn(with: credentials) { (user, error) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            // TODO: - передать данные
            print("Successfully logged in with user: \(String(describing: user))")
            
            // Получаем данные и сохраняем их в базе данных Firebase
            self.fetchFacebookFields()
            
        }
    }
    
    // Получем публичные данные с Facebook API, такие как email, name, id и т.д
    private func fetchFacebookFields() {
        
        // Используем класс GraphRequest, что бы указать какие публичные данные мы хотим получить от пользователя. Указываем "me", т.к так прописано в докумантации. После чего вызываем метод с помощью .start
        GraphRequest(graphPath: "me", parameters: ["fields": "name, id, email"]).start { (_, response, error) in
            
            
            // Обрабатываем ошибку
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // Кастим полученные данные response до типа [String: Any]
            if let userData = response as? [String: Any] {
                
                // Передаем в заранее созданное свойство данные
                self.userProfile = UserData(data: userData)
                
                // Сохраняем пользователя
                self.saveIntoFirebase()
                
                // Данные пользователя
                print(userData)
                print(self.userProfile?.name ?? "nil")
            }
        }
    }
    
    // Создаем метод по сохранению данных в базу данных Firebase
    private func saveIntoFirebase() {
        
        // Создаем уникальный id пользователя. Именно по нему будет определяться пользователь
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Создаем словарь выборочных данных, которые мы хотим видеть у пользователя в базе данных
        let userData = ["name": self.userProfile?.name, "email": self.userProfile?.email]
        
        // Создаем словарь пользователя. В нем по ключу uid будут находится данные userData
        let values = [uid : userData]
        
        // Создаем новую директорию в базе данных. В ней будут хваниться все зарегистрированные пользователи. Имя придумываем сами. После чего вызываем обновление директории с помощью метода .updateChildValues
        Database.database().reference().child("users").updateChildValues(values) { (error, _) in
        
            if let error = error {
                print(error)
                return
            }
            
            print("Successfully saved user in firebase database")
            // Переходим на основной экран только после того, как убедились, что данные пользователя сохранены в базе данных
            self.showMainViewController()
            
        }
    }
    
    // MARK: - Email login
    
    @objc func emailButtonAction() {
        performSegue(withIdentifier: "SignIn", sender: self)
    }
    
}

// MARK: - Google SDK

extension LoginView {
    
    @objc private func handleGoogleButtonTap() {
        signInWithGoogle()
    }
    
    private func signInWithGoogle() {
        
        // Получаем id нашего приложения
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Создаем объект конфигурации для входа
        let config = GIDConfiguration(clientID: clientID)
        
        // Начинаем вход. Мы передаем конфигурацию входа, view, с которого будет происходить вход и открываем completion
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] (user, error) in
            
            // Обрабатываем ошибку
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // Поучаем данные пользователя, для того, что бы их сохранить в Firebase
            if let userName = user?.profile?.name, let userEmail = user?.profile?.email {
                
                // Создаем словарь и передаем его в нашу модель userData
                let userData = ["name": userName, "email": userEmail]
                userProfile = UserData(data: userData)
                
            }
            
            // Авторизируем пользователя
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else { return }
            
            // Создаем токены для авторизации пользователя
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            // Регистрируем полльзователя с данными Google
            Auth.auth().signIn(with: credential) { (user, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                print("Successfully logged in with google data: \(String(describing: user))")
                // Сохраняем в базу данных
                self.saveIntoFirebase()
            }
        }
    }
    
}
