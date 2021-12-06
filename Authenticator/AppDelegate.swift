import UIKit
import CoreData
import CloudKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                // Override point for customization after application launch.
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
            setupContainer()
        }()
        
        func setupContainer() -> NSPersistentContainer {
            
            let isCloudKitEnabled = UserDefaults.standard.bool(forKey: "isCloudKitEnabled")
            
            let container: NSPersistentContainer?
            
            if isCloudKitEnabled {
                debugPrint("Is syncing iCloud")
                container = NSPersistentCloudKitContainer(name: "Authenticator")
                container?.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                container?.viewContext.automaticallyMergesChangesFromParent = true
                
                guard let description = container?.persistentStoreDescriptions.first else {
                    fatalError("###\(#function): Failed to retrieve a persistent store description.")
                }
                
                description.setOption(true as NSNumber,
                                      forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                
                // this will output the cloudKit Container Name
                debugPrint("cloudkit container identifier : \(String(describing: description.cloudKitContainerOptions?.containerIdentifier))")
            } else {
                debugPrint("Is Not syncing iCloud")
                container = NSPersistentContainer(name: "Authenticator")
                
                guard let description = container?.persistentStoreDescriptions.first else {
                    fatalError("###\(#function): Failed to retrieve a persistent store description.")
                }
                
                description.setOption(true as NSNumber,
                                      forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                
                // This allows a 'non-iCloud' sycning container to keep track of changes if a user changes their mind
                // and turns it on.
                description.setOption(true as NSNumber,
                                      forKey: NSPersistentHistoryTrackingKey)
            }
            container!.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    logger.debug("Unresolved error \(error), \(error.userInfo)")

                }
            })
            // As NSPersistentCloudKitContainer is a subclass of NSPersistentContainer, you can return either.
            return container!
            }
        
            // MARK: - Core Data Saving support

            func saveContext () {
                let context = persistentContainer.viewContext
                    if context.hasChanges {
                            do {
                                    try context.save()
                            } catch {
                                    let nserror = error as NSError
                                    logger.debug("Unresolved error \(nserror), \(nserror.userInfo)")
                            }
                    }
            }
    
            // MARK: - CloudKit Deletion
    
            func RemoveiCloudData(completion: @escaping (_ response: Bool) -> Void) {
                // replace the identifier with your container identifier
                let container = CKContainer(identifier: "iCloud.io.plus1xp.authenticator")
                let database = container.privateCloudDatabase
                
                // instruct iCloud to delete the whole zone (and all of its records)
                database.delete(withRecordZoneID: .init(zoneName: "com.apple.coredata.cloudkit.zone"), completionHandler: { (zoneID, error) in
                    if let error = error {
                        completion(false)
                        debugPrint("error deleting zone: - \(error.localizedDescription)")
                    } else {
                        completion(true)
                        debugPrint("successfully deleted zone")
                    }
                })
            }
}
