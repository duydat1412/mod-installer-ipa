import Foundation

class GameFinder {
    static let shared = GameFinder()
    
    private let gameIdentifier = "kgvn.app"
    private let applicationDirectory = "/var/mobile/Containers/Data/Application"
    
    // Check if we have root access
    func checkRootAccess() -> Bool {
        let testPath = "/var/mobile"
        return FileManager.default.isReadableFile(atPath: testPath)
    }
    
    // Find Liên Quân Mobile app directory
    func findGameDirectory() -> URL? {
        let fileManager = FileManager.default
        
        // Check if jailbroken device
        guard fileManager.fileExists(atPath: applicationDirectory) else {
            print("❌ Device not jailbroken or app not found")
            return nil
        }
        
        do {
            let apps = try fileManager.contentsOfDirectory(atPath: applicationDirectory)
            
            for appUUID in apps {
                let appPath = "\(applicationDirectory)/\(appUUID)/Documents"
                
                // Check if this is the game by looking for specific files
                let testPath = "\(appPath)/Resources"
                
                if fileManager.fileExists(atPath: testPath) {
                    // Additional verification - check for version folder
                    if let versions = try? fileManager.contentsOfDirectory(atPath: testPath),
                       versions.contains(where: { $0.contains("1.60") }) {
                        return URL(fileURLPath: appPath)
                    }
                }
            }
        } catch {
            print("❌ Error searching for game: \(error)")
        }
        
        return nil
    }
    
    // Get game Resources directory
    func getResourcesDirectory() -> URL? {
        guard let gameDir = findGameDirectory() else { return nil }
        
        let resourcesPath = gameDir.appendingPathComponent("Resources")
        
        if FileManager.default.fileExists(atPath: resourcesPath.path) {
            return resourcesPath
        }
        
        return nil
    }
    
    // Get specific version folder (e.g., 1.60.1)
    func getVersionDirectory(version: String = "1.60.1") -> URL? {
        guard let resourcesDir = getResourcesDirectory() else { return nil }
        
        let versionPath = resourcesDir.appendingPathComponent(version)
        
        if FileManager.default.fileExists(atPath: versionPath.path) {
            return versionPath
        }
        
        return nil
    }
}
