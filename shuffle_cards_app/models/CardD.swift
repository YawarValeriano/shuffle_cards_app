//
//  CardD.swift
//  shuffle_cards_app
//
//  Created by admin on 6/10/22.
//

import Foundation

struct ShuffledDeckD: Decodable {
    public var cards: [CardD]
    
    enum CodingKeys: String, CodingKey {
    case cards = "cards"
    }
}

struct CardD: Decodable {
    public var code: String
    public var image: String
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case image = "image"
    }
}
