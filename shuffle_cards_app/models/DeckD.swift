//
//  DeckD.swift
//  shuffle_cards_app
//
//  Created by admin on 6/10/22.
//

import Foundation

struct DeckD: Decodable {
    public var deckId: String
    
    enum CodingKeys: String, CodingKey {
        case deckId = "deck_id"
    }
}
