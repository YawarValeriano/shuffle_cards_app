//
//  Deck.swift
//  shuffle_cards_app
//
//  Created by admin on 6/14/22.
//

import Foundation


struct Deck: Decodable {
    public var deckId: String
    
    enum CodingKeys: String, CodingKey {
        case deckId = "deck_id"
    }
}
