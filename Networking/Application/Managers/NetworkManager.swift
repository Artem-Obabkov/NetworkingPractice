//
//  NetworkManager.swift
//  Networking
//
//  Created by pro2017 on 06/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import UIKit

class NetworkManager {
    
    static func getRequest(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            
            guard let response = response, let data = data else { return }
            
            print(response)
            print(data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    static func postRequest(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let userData = ["Course": "Networking", "Lesson": "GET and POST"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            guard let response = response, let data = data else { return }
            
            print(response)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        } .resume()
    }
    
    static func downloadImage(with url: String, closure: @escaping (_ image: UIImage) -> ()) {
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, _, _) in
            
            if let data = data, let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    closure(image)
                }
            }
        } .resume()
    }
    
    static func showCourses(with url: String, clouser: @escaping (_ courses: [CoursesData]) -> ()) {
        // Проверяем валидность ссылки
        guard let url = URL(string: url) else { return }
        
        // Создаем сессию
        let session = URLSession(configuration: .default)
        
        // Создаем задачу
        let task = session.dataTask(with: url) { (data, _, _) in
            
            // Извлекаем опционал
            guard let data = data else { return }
            
            // Создаем JSONDecoder
            let decoder = JSONDecoder()
            
            // Пытаемся раскодировать данные в нашу модель
            do {
                // Т.к мы получаем массив CoursesData то мы должны это указать как [CoursesData].self, что значит раскодировать данные в массив типа CoursesData
                let coursesDataArray = try decoder.decode([CoursesData].self, from: data)
                
                clouser(coursesDataArray)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
}
