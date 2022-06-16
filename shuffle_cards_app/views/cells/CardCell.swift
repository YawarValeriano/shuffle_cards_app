//
//  CardCell.swift
//  shuffle_cards_app
//
//  Created by admin on 6/9/22.
//

import UIKit

class CardCell: UICollectionViewCell {
    static let identifier: String = "CellIdentifier"
    static let uiNibName: String = "CardCell"

    @IBOutlet weak var cardImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
