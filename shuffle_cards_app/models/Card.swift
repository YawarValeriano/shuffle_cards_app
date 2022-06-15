//
//  Card.swift
//  shuffle_cards_app
//
//  Created by admin on 6/14/22.
//

import Foundation

struct ShuffledDeck: Decodable {
    public var cards: [Card]
}

struct Card: Decodable {
    public var code: String
    public var image: String
}
