//
//  Address.swift
//  HuTi
//
//  Created by Nguyễn Thịnh on 07/03/2023.
//

import Foundation

struct Province: Codable {
    var code: String
    var name: String
    var unit: String
}

struct District: Codable {
    var code: String
    var name: String
    var unit: String
    var province_code: String
    var province_name: String
    var full_name: String
}

struct Ward: Codable {
    var code: String
    var name: String
    var unit: String
    var district_code: String
    var district_name: String
    var province_code: String
    var province_name: String
    var full_name: String
}

struct ProvinceCoordinate {
    var name: String
    var lat: Double
    var long: Double
}

