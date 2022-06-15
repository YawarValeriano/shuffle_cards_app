//
//  ViewController.swift
//  shuffle_cards_app
//
//  Created by admin on 6/9/22.
//

import UIKit
import SVProgressHUD


class ViewController: UIViewController {

    @IBOutlet weak var cardCollection: UICollectionView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var cards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardCollection.delegate = self
        cardCollection.dataSource = self
        
        let uiNib = UINib(nibName: CardCell.uiNibName, bundle: nil)
        cardCollection.register(uiNib, forCellWithReuseIdentifier: CardCell.identifier)
    }


    @IBAction func shuffleCardsAction(_ sender: Any) {
        self.cards.removeAll()
        getNewDeckId()
    }
    
    func getNewDeckId() {
        let newDeckUrlStr = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
        guard let url = URL(string: newDeckUrlStr) else { return }
        SVProgressHUD.show()
        NetworkManager.shared.get(Deck.self, from: url) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(let deck):
                self.getShuffledCards(fromID: deck.deckId)
            case .failure(let error):
                self.showError(withDescription: error.localizedDescription)
            }
        }
        
    }
    
    func getShuffledCards(fromID deckId: String) {
        SVProgressHUD.show()
        let shuffledDeckStr = "https://deckofcardsapi.com/api/deck/\(deckId)/draw/?count=52"
        guard let shuffledDeckUrl = URL(string: shuffledDeckStr) else { return }
        NetworkManager.shared.get(ShuffledDeck.self, from: shuffledDeckUrl) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .success(let deck):
                self.cards = deck.cards
                self.cardCollection.reloadData()
            case .failure(let error):
                self.showError(withDescription: error.localizedDescription)
            }
        }
    }
    
    func showError(withDescription error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            print("OK")
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.identifier, for: indexPath) as? CardCell ?? CardCell()
        let card = cards[indexPath.row]
        if let imageURL = URL(string: card.image) {
            cell.cardImage.load(url: imageURL)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width/3.5
        let height = collectionView.frame.height/4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { return }
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: CardModal.identifier) as? CardModal else { return }
        vc.cardImage = cell.cardImage.image
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
}

let cardCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func load(url: URL) {
        if let cardFromCache = cardCache.object(forKey: url as AnyObject) as? UIImage {
            self.image = cardFromCache
            return
        }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let cardToCache = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cardCache.setObject(cardToCache, forKey: url as AnyObject)
                        self.image = cardToCache
                    }
                }
            }
        }
    }
}
