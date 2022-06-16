//
//  ImageManager.swift
//  shuffle_cards_app
//
//  Created by admin on 6/15/22.
//

import Foundation
import UIKit

class ImageManager {
    
    static let shared = ImageManager()
    
    private let cardCache = NSCache<AnyObject, AnyObject>()

    func getUIImage(formURL url: URL) -> UIImage? {
               
        if let cardFromCache = cardCache.object(forKey: url as AnyObject) as? UIImage {
            return cardFromCache
        }
        if let data = try? Data(contentsOf: url) {
            if let cardToCache = UIImage(data: data) {
                cardCache.setObject(cardToCache, forKey: url as AnyObject)
                return cardToCache
            }
        }
        return UIImage(named: "no_image")
    }
}
