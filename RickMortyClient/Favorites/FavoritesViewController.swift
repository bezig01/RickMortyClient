//
//  FavoritesViewController.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import UIKit
import RxSwift
import RxCocoa

class FavoritesViewController: UIViewController {
    
    let viewModel = FavoritesViewModel()
    
    let bag = DisposeBag()
    
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logoutItem = UIBarButtonItem(title: "Logout", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = logoutItem
        
        logoutItem.rx.tap
            .bind { [weak self] in self?.logout() }
            .disposed(by: bag)
        
        collectionView.register(.init(nibName: FavoriteCell.id, bundle: nil), forCellWithReuseIdentifier: FavoriteCell.id)
        
        let spacing: CGFloat = 20
        let width = (UIScreen.main.bounds.width - 3 * spacing) / 2
        let height = 1.5 * width
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = .init(width: width, height: height)
        flowLayout.sectionInset = .init(top: 0, left: spacing, bottom: 0, right: spacing)
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
        collectionView.collectionViewLayout = flowLayout
        
        setupBindings()
    }
    
    private func setupBindings() {
        
        viewModel.itemsRelay
            .bind(to: collectionView.rx.items) { collectionView, row, item in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.id, for: indexPath) as! FavoriteCell
                cell.item = item
                cell.layoutIfNeeded()
                return cell
            }
            .disposed(by: bag)
        
        collectionView.rx.modelSelected(Favorite.self)
            .bind { [weak self] in self?.presentCharacter($0) }
            .disposed(by: bag)
    }
    
    private func presentCharacter(_ item: Favorite) {
        guard let characterData = item.characterData else { return }
        var character: Character?
        do {
            character = try JSONDecoder().decode(Character.self, from: characterData)
        } catch {
            print(error)
        }
        guard let character else { return }
        let viewController = CharactersViewController()
        viewController.viewModel.selectedItem = character
        navigationController?.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func logout() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.logout()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
        
        sceneDelegate.initialScreen()
    }

}

extension FavoritesViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
}
