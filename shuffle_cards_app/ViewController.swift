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
    
    var cards: [CardD] = []
    let cellIdentifier = "CardCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardCollection.delegate = self
        cardCollection.dataSource = self
        
        let uiNib = UINib(nibName: "CardCell", bundle: nil)
        cardCollection.register(uiNib, forCellWithReuseIdentifier: cellIdentifier)
    }


    @IBAction func shuffleCardsAction(_ sender: Any) {
        self.cards.removeAll()
        getNewDeckId()
    }
    
    func getNewDeckId() {
        let newDeckUrlStr = "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
        guard let url = URL(string: newDeckUrlStr) else { return }
        SVProgressHUD.show()
        NetworkManager.shared.get(DeckD.self, from: url) { result in
            switch result {
            case .success(let deck):
                self.getShuffledCards(fromID: deck.deckId)
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    print("OK")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        SVProgressHUD.dismiss()
    }
    
    func getShuffledCards(fromID deckId: String) {
        let shuffledDeckStr = "https://deckofcardsapi.com/api/deck/\(deckId)/dra2w/?count=52"
        guard let shuffledDeckUrl = URL(string: shuffledDeckStr) else { return }
        NetworkManager.shared.get(ShuffledDeckD.self, from: shuffledDeckUrl) { result in
            switch result {
            case .success(let deck):
                self.cards = deck.cards
                self.cardCollection.reloadData()
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    print("OK")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CardCell ?? CardCell()
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
    
        let cell = collectionView.cellForItem(at: indexPath) as! CardCell
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"CardModal") as? CardModal else { return  }
        
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
