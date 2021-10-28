//
//  ImageViewController.swift
//  Networking
//
//  Created by Alexey Efimov on 27.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import Alamofire

class ImageViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    let imageUrl = "https://applelives.com/wp-content/uploads/2016/03/iPhone-SE-11.jpeg"
    let largerImageUrl = "https://edmullen.net/test/rc.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        progressLabel.isHidden = true
        progressView.isHidden = true
    }
    
    func fetchImage() {
        
        NetworkManager.downloadImage(with: imageUrl) { (image) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            }
        }
    }
    
    func fetchImageWithAlamofire() {
        
        AlamofireNetworkRequest.getImage(from: imageUrl) { (image) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            }
        }
    }
    
    func fetchLargeImageWithAlamofire() {
        
        // Изменяем процент загрузки progressView
        AlamofireNetworkRequest.onProgress = { progress in
            self.progressView.isHidden = false
            self.progressView.progress = Float(progress)
        }
        
        // Изменяем процент загрузки progressLabel
        AlamofireNetworkRequest.onComplete = { complete in
            self.progressLabel.isHidden = false
            self.progressLabel.text = complete
        }
        
        // Убираем ненужные UI елементы и присваиваем изображение
        AlamofireNetworkRequest.downloadLargeImage(with: largerImageUrl) { (image) in
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                self.progressLabel.isHidden = true
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
            }
        }
    }
    
    static func uploadImageWithAlamofire(imageUrl: String) {
        // Проверяем URL
        guard let url = URL(string: imageUrl) else { return }
        
        // Создаем изображение и преобразовываем его в .pngData
        let image = UIImage(named: "Sosi")!
        guard let data = image.pngData() else { return }
        
        // Создаем массив headers для авторизации
        let httpHeaders = ["Authorization" : "Client-ID 19394h198y3h8ta3e1"]
        
        // ВАЖНО Данные кодируются на лету для дальнейшей передачи на сервер, поэтому большие размеры данных нужно подготавливать заранее
        upload(multipartFormData: { (multipartFormData) in
            
            // Мы передаем данные с параметром withName значение котрого мы берем из api документации на сайте, куда загружаем изображение
            multipartFormData.append(data, withName: "image")
            
            // Мы передаем URL и httpHeaders а так же получаем закодированный запрос
        }, to: url, headers: httpHeaders){ (encodingCompletion) in
            
            // Определяем положительный ли ответ или отрицательный
            switch encodingCompletion {
            
            // Здесь мы получим запрос и 2 переменные потоковой передачи данных
            case .success(request: let uploadRequest,
                          streamingFromDisk: _,
                          streamFileURL: _):
                
                // uploadRequest - получаем URL адресс по котрому делаем сам запрос
                // streamingFromDisk - определяет есть ли изображение на устройстве
                // streamFileURL - потоковая передача с диска. Если мы собираемся ее делать, то нужно указать ссылку на файл
                
                // Обычная обработка запроса
                uploadRequest.validate().responseJSON { (responseJSON) in
                    
                    switch responseJSON.result {
                    
                    case .success(let value):
                        print(value)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
