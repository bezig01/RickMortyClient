//
//  AppDelegate.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import UIKit
import CoreData
import Kingfisher
import CryptoKit
import KeychainAccess

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var userID: UUID?
    var isUserLoggedIn: Bool { userID != nil }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ImageCache.default.memoryStorage.config.countLimit = 20
        _ = tryAutoLogin()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RickMortyClient")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

extension AppDelegate {
    
    var currentUser: User? {
        
        let defaults = UserDefaults.standard
        guard let userID = defaults.string(forKey: "userID") else { return nil }
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        fetchRequest.fetchLimit = 1
        
        var user: User?
        
        do {
            let results = try context.fetch(fetchRequest)
            user = results.first
        } catch {
            print(error)
        }
        
        return user
    }
    
    func tryAutoLogin() -> Bool {
        
        let keychain = Keychain()
        
        guard let currentUser,
              let password = keychain["password"] else { return false }
        
        let data = password.data(using: .utf8)!
        let digest = Insecure.SHA1.hash(data: data)
        
        guard currentUser.passwordHash == Data(digest) else { return false }
        self.userID = currentUser.userID
        
        print("USER LOGGED IN")
        
        return true
    }
    
    func isUsernameAvailable(_ username: String) -> Bool {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.fetchLimit = 1
        
        var isAvailable = false
        
        do {
            let results = try context.fetch(fetchRequest)
            isAvailable = results.isEmpty
        } catch {
            print(error)
        }
        return isAvailable
    }
    
    func registerUser(_ username: String, password: String, phoneNumber: String?) {
        
        let context = persistentContainer.viewContext
        let user = User(context: context)
        
        user.userID = UUID()
        user.username = username
        user.phoneNumber = phoneNumber
        
        let data = password.data(using: .utf8)!
        let digest = Insecure.SHA1.hash(data: data)
        
        let passwordHash = Data(digest)
        user.passwordHash = passwordHash
        
        context.insert(user)
        
        saveContext()
    }
    
    func tryLogin(_ username: String, password: String) -> Bool {
        
        let keychain = Keychain()
        let defaults = UserDefaults.standard
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.fetchLimit = 1
        
        var user: User?
        do {
            let results = try context.fetch(fetchRequest)
            user = results.first
        } catch {
            print(error)
        }
        
        guard let user else { return false }
        
        let data = password.data(using: .utf8)!
        let digest = Insecure.SHA1.hash(data: data)
        
        guard user.passwordHash == Data(digest) else { return false }
        
        defaults.set(user.userID?.uuidString, forKey: "userID")
        keychain["password"] = password
        self.userID = user.userID
        
        print("USER LOGGED IN")
        
        return true
    }
    
    func resetPassword(_ username: String, password: String) {
        
        let keychain = Keychain()
        let defaults = UserDefaults.standard
        let context = persistentContainer.viewContext
        
        let fetchRequest = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.fetchLimit = 1
        
        var user: User?
        do {
            let results = try context.fetch(fetchRequest)
            user = results.first
        } catch {
            print(error)
        }
        
        guard let user else { return }
        
        let data = password.data(using: .utf8)!
        let digest = Insecure.SHA1.hash(data: data)
        
        let passwordHash = Data(digest)
        user.passwordHash = passwordHash
        
        saveContext()
        
        defaults.set(user.userID?.uuidString, forKey: "userID")
        keychain["password"] = password
    }
    
    func logout() {
        let keychain = Keychain()
        let defaults = UserDefaults.standard
        
        defaults.set(nil, forKey: "userID")
        keychain["password"] = nil
        userID = nil
    }
    
    func favoriteItem(_ item: Character, episode: Episode?) {
        guard let currentUser else { return }
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = Favorite.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "user == %@ && characterID == %d", currentUser, item.id)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            guard results.isEmpty else { return }
        } catch {
            print(error)
        }
        
        let favorite = Favorite(context: context)
        favorite.characterID = Int32(item.id)
        favorite.characterName = item.name
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(item)
            favorite.characterData = data
        } catch {
            print(error)
        }
        
        if let episode {
            
            favorite.episodeID = Int32(episode.id)
            favorite.episodeName = episode.name
            
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(item)
                favorite.episodeData = data
            } catch {
                print(error)
            }
        }
        
        favorite.user = currentUser
        favorite.timestamp = Date()
        
        context.insert(favorite)
        
        saveContext()
        
        retrieveImage(item.image, with: item.id)
    }
    
    func fileURL(_ characterID: Int) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: .userDomainMask).first else { return nil }
        let fileURL = documentURL.appendingPathComponent("character-\(characterID).png")
        return fileURL
    }
    
    private func saveImage(_ image: UIImage, with characterID: Int) {
        guard let imageData = image.pngData(),
              let fileURL = fileURL(characterID) else { return }
        do {
            try imageData.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    private func retrieveImage(_ url: URL, with characterID: Int) {
        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            switch result {
            case .success(let value):
                self?.saveImage(value.image, with: characterID)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchFavorites() -> [Favorite] {
        guard let currentUser else { return [] }
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = Favorite.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", currentUser)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        var results: [Favorite] = []
        
        do {
            results = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return results
    }
}
