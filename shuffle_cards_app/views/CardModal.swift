//
//  CardModal.swift
//  shuffle_cards_app
//
//  Created by admin on 6/9/22.
//

import UIKit

class CardModal: UIViewController {
    static let identifier: String = "CardModal"
    
    var cardData: Card?

    @IBOutlet weak var selectedCard: UIImageView!
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        if let card = cardData {
            guard let imageURL = URL(string: card.image) else { return }
            selectedCard.image = ImageManager.shared.getUIImage(formURL: imageURL)
            
        }

    }
    
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
}
