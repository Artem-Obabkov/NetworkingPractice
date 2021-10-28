//
//  AlamofireManager.swift
//  Networking
//
//  Created by pro2017 on 08/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    
    // Эти свойства используются, что бы можно было получить данные о загрузке в методе с другого класс
    static var onProgress: ( (Double) -> () )?
    static var onComplete: ( (String) -> () )?
    
    static func sendRequest(url: String, clouser: @escaping (_ courses: [CoursesData]) -> ()) {
        
        // Проверяем валидность ссылки
        guard let url = URL(string: url) else { return }
        
        
        // Если validate() будет отсутствовать, то response.result будет всегда равняться success, что не всегда верно, т.к ошибку он может выдать только при отсутствии интернета
        request(url).validate().responseJSON { (response) in
            
            switch response.result {
            
            // Если запрос был успешно получен то присваиваем полученные данные модели CoursesData
            case .success(let value):
                
                // Создаем массив, куда будут помещаться данные в виде модели CoursesData
                var courses = [CoursesData]()
                
                // Присваиваем новые данные
                courses = CoursesData.getCoursesArray(from: value)!
                
                // Передаем данные в класс из которого вызвали метод
                clouser(courses)
                
            // Если возникла ошибка
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    static func getImage(from url: String, completion: @escaping (_ image: UIImage) -> ()) {
        
        // Проверяем валидность ссылки
        guard let url = URL(string: url) else { return }
        
        // Создаем запрос изображения и получаем его в виде Data
        request(url).responseData { (responseData) in
            
            // Проверяем положиетльный ли ответ или нет
            switch responseData.result {
            
            case .success(let data):
                
                // Создаем изображение
                guard let image = UIImage(data: data) else { return }
                
                // Передаем в класс из которого вызвали
                DispatchQueue.main.async {
                    completion(image)
                }
                
            // В случае ошибки
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func downloadLargeImage(with url: String, completion: @escaping (_ image: UIImage) -> () ) {
        
        // Проверяем ссылку
        guard let url = URL(string: url) else { return }
        
        // Создаем запрос и вызываем метод .downloadProgress, а после вызываем метод .response
        request(url).validate().downloadProgress { (progress) in
            
            // Передаем свойствам класса AlamofireNetworkRequest значение свойств класса Progress
            self.onProgress?(progress.fractionCompleted)
            self.onComplete?(progress.localizedDescription)
            
        }.response { response in
            
            // Получаем данные и создаем изображение, полсе чего передаем это изображение в клоужер
            guard let data = response.data, let image = UIImage(data: data) else { return }
            
            // Асинхронно передаем изображение в класс из которого вызвали метод
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    // POST запрос
    static func postRequest(url: String, clouser: @escaping (_ courses: [CoursesData]) -> ()) {
        
        // Проверяем URL
        guard let url = URL(string: url) else { return }
        
        // Создаем массив данных который будем передавать на сервер. Массив имеет тип данных [String : Any], т.к с таким типом данных работает Alamofire
        let userData: [String : Any] = [
            "number_of_tests": 40,
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/2018/03/2-courselogo.jpg",
            "id": 1,
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "number_of_lessons": 20,
            "name": "Networking"]
        
        
        // Создаем запрос с определенными параметрами
        request(url, method: .post, parameters: userData).responseJSON { (response) in
            
            switch response.result {
            
            case .success(let value):
                
                // Кастим полученный JSON к типу [String : Any], а после создаем экземпляр CoursesData
                guard
                    let jsonObject = value as? [String : Any],
                    let course = CoursesData(json: jsonObject)
                      else { return }
                print(jsonObject)
                print(course)
                
                // Создаем массив и добавляем элемент
                var courses = [CoursesData]()
                courses.append(course)
                
                // Передаем в класс из которого вызвали
                clouser(courses)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
