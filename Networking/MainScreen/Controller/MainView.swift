//
//  MainView.swift
//  Networking
//
//  Created by pro2017 on 06/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import UIKit
import UserNotifications
import FBSDKLoginKit
import FirebaseAuth

private let reuseIdentifier = "CollectionViewCell"

enum Actions: String, CaseIterable {
    case downloadImage = "Download image"
    case imageAlamofire = "Image Alamofire"
    case largeImage = "Large image Alamofire"
    case get = "GET"
    case post = "POST"
    case put = "PUT with Alamofire"
    case postAlamofire = "POST with Alamofire"
    case ourCourses = "Our courses"
    case ourCoursesAlamofire = "Our courses (Alamofire)"
    case uploadImage = "Upload image"
    case startDownloadFile = "Start Download file"
    
}

class MainView: UICollectionViewController {
    
    let actions = Actions.allCases
    
    let insets: CGFloat = 25
    let itemsPerRow: CGFloat = 1
    
    let dataProvider = DataProvider()
    var filePath = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotification()
        
        dataProvider.fileLocation = { location in
            self.filePath = location.absoluteString
            self.postNotification()
            print("Your file: \(location.absoluteString)")
        }
        
        checkUserCondition()
    }

   

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return actions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        cell.label.text = actions[indexPath.row].rawValue
        cell.layer.cornerRadius = 10
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentAction = actions[indexPath.row]
        
        
        switch currentAction {
        case .downloadImage:
            performSegue(withIdentifier: "ShowImage", sender: self)
        case .imageAlamofire:
            performSegue(withIdentifier: "ShowImageAlamofire", sender: self)
        case .largeImage:
            performSegue(withIdentifier: "LargeImage", sender: self)
        case .get:
            NetworkManager.getRequest(url: "https://jsonplaceholder.typicode.com/posts")
        case .post:
            NetworkManager.postRequest(url: "https://jsonplaceholder.typicode.com/posts")
        case .put:
            performSegue(withIdentifier: "PutRequest", sender: self)
        case .postAlamofire:
            performSegue(withIdentifier: "PostAlamofire", sender: self)
        case .ourCourses:
            performSegue(withIdentifier: "Description", sender: self)
        case .ourCoursesAlamofire:
            performSegue(withIdentifier: "DescriptionAlamofire", sender: self)
        case .uploadImage:
            print("Upload Image")
        case .startDownloadFile:
            createAlert()
            self.dataProvider.stardDownload(with: "https://speed.hetzner.de/100MB.bin")
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let coursesVC = segue.destination as? CoursesViewController
        let imageVC = segue.destination as? ImageViewController
        
        
        switch segue.identifier {
        case "Description":
            DispatchQueue.main.async {
                coursesVC!.fetchData()
            }
        case "DescriptionAlamofire":
            DispatchQueue.main.async {
                coursesVC!.fetchDataWithAlamofire()
            }
        case "PostAlamofire":
            DispatchQueue.main.async {
                coursesVC!.postRequest()
            }
        case "PutRequest":
            DispatchQueue.main.async {
                coursesVC!.putRequest()
            }
        case "ShowImage":
            DispatchQueue.main.async {
                imageVC!.fetchImage()
            }
        case "ShowImageAlamofire":
            DispatchQueue.main.async {
                imageVC!.fetchImageWithAlamofire()
            }
        case "LargeImage":
            DispatchQueue.main.async {
                imageVC!.fetchLargeImageWithAlamofire()
            }
        
        
        default:
            break
        }
        
    }
    

// MARK: - Notifications
    
    private func registerForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            //
        }
    }
    
    private func postNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Download complete"
        content.body = "Your background transfer complete. File path: \(filePath)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension MainView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingWidth: CGFloat = insets * (itemsPerRow + 1)
        let availableWidth: CGFloat = collectionView.frame.width - paddingWidth
        let itemWidth: CGFloat = availableWidth / itemsPerRow
        
        return CGSize(width: itemWidth, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: insets, left: insets, bottom: insets - 20, right: insets)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: - Facebook SDK

extension MainView {
    
    func checkUserCondition() {
        
        // Если человек еще не вошел/зарегистрировался, то мы открываем окно входа
        if Auth.auth().currentUser == nil {
            
            // Создаем storyboard
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Создаем переход к LoginView с помощью StoryboardID 
            let loginView = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginView
            
            // Отображаем ViewController
            self.present(loginView, animated: true)
        }
    }
}
