//
//  ProfileView.swift
//  Networking
//
//  Created by pro2017 on 12/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class ProfileView: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    // Создаем модель данных текущего пользователя, в которую мы будем передавать данные с fetchCurrentUserData
    var currentUser: CurrentUserData?
    
    // Текущий провайдер
    var provider: String?
    
    
    
    // Создаем кастомную кнопку выхода из аккаунта
    lazy var customLogOutButton: UIButton = {
        
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        button.setTitle("LogOut", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 32, y: 500 + 80, width: self.view.frame.width - 64, height: 50)
        
        // Добавляем target, т.к именно через него будет происзодить логика нажатия
        button.addTarget(self, action: #selector(handleCustomLogOut), for: .touchUpInside)
        return button
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // Мы должны вызвать метод загрузки данных с базы данных Firebase в этом методе, т.к нам нужно, что бы этот метода срабатывал каждый раз при появления ProfileView экрана.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Настройка UI элементов
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .darkGray
        nameLabel.isHidden = true
        fetchCurrentUserData()
    }
    
    // Добавляем subview
    private func setupView() {
        self.view.addSubview(customLogOutButton)
    }

}

// MARK: - Log Out

extension ProfileView {
    
    private func openLoginView() {
        
       // Пытаемся произвести деавтроризацию из Firebase и если проходит все успешно, то открываем экран регистрации
        do {
            
            // Выходим из Firebase
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                // Создаем storyboard
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                // Создаем переход к LoginView с помощью StoryboardID
                let loginView = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginView

                // Отображаем ViewController
                self.present(loginView, animated: true)
                
            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // Получаем данные с базы данных Firebase
    private func fetchCurrentUserData() {
        
        // Проверяем есть ли текущий пользователь в базе данных
        if Auth.auth().currentUser != nil {
            
            if let username = Auth.auth().currentUser?.displayName {
                
                // Подставляем имя в лэйбл
                self.activityIndicator.stopAnimating()
                self.nameLabel.isHidden = false
                self.nameLabel.text = self.getCurrentProviderData(with: username)
                
                return
            }
            
            // Извлекаем id пользователя
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            // Создаем базу данных
            let database = Database.database().reference()
            
            // Обращаемся к директориям. Т.к у нас есть главная директория "users" и дополнительная директория с id пользователей.
            database.child("users").child(uid)
                
                // Обращаемся к базе данных с просьбой предоставить данные .value по текущему состоянию базы. Snapshot - как бы снимок базы данных на данный момент времени.
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    // Получаем данные конкретного пользователя типа [String: Any]
                    guard let currentUserData = snapshot.value as? [String: Any] else { return }
                    
                    // Передаем эти данные в модель
                    self.currentUser = CurrentUserData(uid: uid, data: currentUserData)
                    
                    // Обновляем UI элементы
                    self.activityIndicator.stopAnimating()
                    self.nameLabel.isHidden = false
                    self.nameLabel.text = self.getCurrentProviderData(with: self.currentUser?.name ?? "Noname")
                    
                }
        }
    }
    
    // Выход из приложения одной кнопкой
    @objc private func handleCustomLogOut() {
        
        // Мы получаем данные текущего пользователя пользователя
        if let providerData = Auth.auth().currentUser?.providerData {
            
            // Перебираем возможные варианты userInfo
            for userInfo in providerData {
                
                // Перебираем id провайдеров
                switch userInfo.providerID {
                
                // Если вошли через фэйсбук, то и выходим через фэйсбук
                case "facebook.com":
                    
                    LoginManager().logOut()
                    print("Successfully logged out from facebook")
                    self.openLoginView()
                
                // Если вошли через гугл то и выходим через него
                case "google.com":
                    
                    GIDSignIn.sharedInstance.signOut()
                    print("Successfully logged out from google")
                    self.openLoginView()
                    
                case "password":
                    
                    try! Auth.auth().signOut()
                    print("Successfully logged out")
                    self.openLoginView()
                    
                default:
                    print("Error")
                }
            }
        }
    }
    
    private func getCurrentProviderData(with user: String) -> String {
        
        var greetings = ""
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userIndo in providerData {
                
                switch userIndo.providerID {
                
                case "facebook.com":
                    provider = "Facebook"
                
                case "google.com":
                    provider = "Google"
                    
                case "password":
                    provider = "Email"
                    
                default:
                    break
                }
            }
            
            greetings = "\(user) logged in via \(provider!)"
        }
        
        return greetings
    }
}
