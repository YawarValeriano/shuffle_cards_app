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
    @IBOutlet weak var searchCard: UISearchBar!
    @IBOutlet weak var bottomCollectionConstraint: NSLayoutConstraint!
    
    var cards: [Card] = []
    var filteredCards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        initializeCollectionAndSearchBar()
    }
    
    @IBAction func shuffleCardsAction(_ sender: Any) {
        self.cards.removeAll()
        getNewDeckId()
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        bottomCollectionConstraint.constant = keyboardFrame.size.height
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        bottomCollectionConstraint.constant = 10
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func initializeCollectionAndSearchBar(){
        cardCollection.delegate = self
        cardCollection.dataSource = self
        
        let uiNib = UINib(nibName: CardCell.uiNibName, bundle: nil)
        cardCollection.register(uiNib, forCellWithReuseIdentifier: CardCell.identifier)
        
        searchCard.showsCancelButton = true
        searchCard.delegate = self
    
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
                self.filteredCards = deck.cards
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
        if filteredCards.count > 0 {
            searchCard.isUserInteractionEnabled = true
        }
        return filteredCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCell.identifier, for: indexPath) as? CardCell ?? CardCell()
        let card = filteredCards[indexPath.row]
        if let imageURL = URL(string: card.image) {
            cell.cardImage.image = ImageManager.shared.getUIImage(formURL: imageURL)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let generalFrame = self.view.frame
        let width = generalFrame.width/4
        let height = generalFrame.height/6
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = filteredCards[indexPath.row]
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: CardModal.identifier) as? CardModal else { return }
        vc.cardData = card
        navigationController?.present(vc, animated: true, completion: nil)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filteredCards = self.cards
        self.cardCollection.reloadData()
        searchBar.text = ""
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.filteredCards = self.cards
        } else {
            let textToSearch = searchText.lowercased()
            self.filteredCards = cards.filter { card in
                card.code.lowercased().contains(textToSearch) ||
                card.suit.lowercased().contains(textToSearch) ||
                card.value.lowercased().contains(textToSearch)
            }
        }
        
        self.cardCollection.reloadData()
    }
}
