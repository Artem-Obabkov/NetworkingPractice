//
//  UserData.swift
//  Networking
//
//  Created by pro2017 on 13/10/2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation

struct UserData {
    
    let id: Int?
    let name: String?
    let email: String?
    
    init(data: [String : Any]) {
        
        let id = data["id"] as? Int
        let name = data["name"] as? String
        let email = data["email"] as? String
        
        self.id = id
        self.name = name
        self.email = email
        
    }
}
