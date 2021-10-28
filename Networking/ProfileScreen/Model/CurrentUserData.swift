//
//  CurrentUserData.swift
//  Networking
//
//  Created by pro2017 on 13/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation

struct CurrentUserData {
    
    let id: String?
    let name: String?
    let email: String
    
    init?(uid: String, data: [String: Any]) {
        
        // Извлекаем опционалы
        guard
            let name = data["name"] as? String,
            let email = data["email"] as? String
        else { return nil }
        
        self.id = uid
        self.name = name
        self.email = email
        
    }
}
