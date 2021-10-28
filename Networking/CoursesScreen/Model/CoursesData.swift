//
//  CoursesData.swift
//  Networking
//
//  Created by pro2017 on 05/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation

struct CoursesData: Codable {
    let id: Int
    let name: String
    let link: String
    let imageURL: String
    let numberOfLessons, numberOfTests: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, link
        case imageURL = "imageUrl"
        case numberOfLessons = "number_of_lessons"
        case numberOfTests = "number_of_tests"
    }
    
    // Раскладываем полученный JSON файл 
    init?(json: [String: Any]) {
        
        let id = json["id"] as! Int
        let name = json["name"] as! String
        let link = json["link"] as! String
        let imageURL = json["imageUrl"] as! String
        let numberOfLessons = json["number_of_lessons"] as? Int
        let numberOfTests = json["number_of_tests"] as? Int
        
        self.id = id
        self.name = name
        self.link = link
        self.imageURL = imageURL
        self.numberOfLessons = numberOfLessons
        self.numberOfTests = numberOfTests
    }
    
    // Создаем статичную функцию которая будет возвращать массив данных [CoursesData]
    static func getCoursesArray(from json: Any) -> [CoursesData]? {
        
        // Получаем массив словарей с типом [String: Any]
        guard let jsonArray = json as? Array<[String : Any]> else { return nil }
        print(jsonArray)
        
        // Перебираем jsonArray и присваиваем значение его элементов в структуру CoursesData
        return jsonArray.compactMap { CoursesData(json: $0) }
    }
    
    
}
