//
//  Card.swift
//  shuffle_cards_app
//
//  Created by admin on 6/14/22.
//

import Foundation

struct Card: Decodable {
    public var code: String
    public var image: String
    public var images: Image
    public var value: String
    public var suit: String
}

struct Image: Decodable {
    public var svg: String
    public var png: String
}
