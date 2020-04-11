//
//  Breeds.swift
//  DogApp
//
//  Created by Timi Tejumola on 11/04/2020.
//  Copyright © 2020 Timi Tejumola. All rights reserved.
//

import Foundation

struct BreedsResponse: Codable {
    let status: String
    let message: [String: [String]]
}
