//
//  CharactersViewController.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CoreData

class CharactersViewController: UIViewController {

    let viewModel = CharactersViewModel()
    
    let bag = DisposeBag()
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionItem>!
    
    @IBOutlet var tableView: UITableView!
    
    var indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let favoriteButton = UIBarButtonItem(title: "Favorites", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = favoriteButton
        
        favoriteButton.rx.tap
            .bind { [weak self] in self?.presentFavorite() }
            .disposed(by: bag)
        
        
        tableView.register(.init(nibName: CharacterCell.id, bundle: nil), forCellReuseIdentifier: CharacterCell.id)
        tableView.register(.init(nibName: CharacterInfoCell.id, bundle: nil), forCellReuseIdentifier: CharacterInfoCell.id)
        
        indicator = UIActivityIndicatorView(frame: .init(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        tableView.tableFooterView = indicator
        
        setupBindings()
        
        if let item = viewModel.selectedItem {
            viewModel.fetchEpisodes([item])
            viewModel.fetchLocationUsers(item.location)
            return
        }
        
        viewModel.fetchNextPage()
    }
    
    func setupBindings() {
        
        tableView.rx.setDelegate(self)
            .disposed(by: bag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { [weak self] dataSource, tableView, indexPath, item in
            
            guard let selectedItem = self?.viewModel.selectedItem else {
                let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.id, for: indexPath) as! CharacterCell
                cell.item = (item, self?.viewModel.episodes[item.id])
                return cell
            }
            
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: CharacterInfoCell.id, for: indexPath) as! CharacterInfoCell
                cell.item = (selectedItem, self?.viewModel.episodes[item.id])
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.id, for: indexPath) as! CharacterCell
                cell.item = (item, self?.viewModel.episodes[item.id])
                return cell
            default:
                fatalError()
            }
        })
        
        viewModel.sectionsRelay
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .bind { [weak self] in self?.presentCharacter($0) }
            .disposed(by: bag)
        
        viewModel.errorRelay
            .compactMap { $0 }
            .bind { [weak self] in self?.presentAlert($0) }
            .disposed(by: bag)
        
    }
    
    private func presentFavorite() {
        let viewController = FavoritesViewController()
        navigationController?.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentCharacter(_ indexPath: IndexPath) {
        if viewModel.selectedItem != nil, indexPath.section == 0 { return }
        let viewController = CharactersViewController()
        viewController.viewModel.selectedItem = dataSource[indexPath]
        navigationController?.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentAlert(_ error: Error) {
        
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.bounds
        
        alertController.addAction(.init(title: "OK", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    deinit {
        print(String(describing: self), #function)
    }
}

extension CharactersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var text = "Rick and Morty"
        var size: CGFloat = 40
        
        if let item = viewModel.selectedItem {
            switch section {
            case 0:
                text = item.name
            case 1:
                text = "Also from \"\(item.location.name)\""
                size = 24
            default:
                fatalError()
            }
        }
        
        let titleView = UILabel()
        titleView.text = text
        titleView.font = .systemFont(ofSize: size, weight: .bold)
        titleView.adjustsFontSizeToFitWidth = true
        titleView.minimumScaleFactor = 0.5
        return titleView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if viewModel.hasNextPage && indexPath.row == viewModel.items.count-1 {
            indicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [indicator] in
                indicator?.stopAnimating()
            }
            
            viewModel.fetchNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .normal, title: "Favorite") { [weak self] action, view, completionHandler in
            
            self?.favoriteItem(indexPath)
            completionHandler(true)
        }
        action.backgroundColor = .systemOrange
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    private func favoriteItem(_ indexPath: IndexPath) {
        
        let item = dataSource[indexPath]
        let episode = viewModel.episodes[item.id]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        appDelegate.favoriteItem(item, episode: episode)
    }
}

extension CharactersViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        guard navigationController.viewControllers.count > 2,
              let rootViewController = navigationController.viewControllers.first else { return }
        navigationController.viewControllers = [rootViewController, viewController]
    }
}
