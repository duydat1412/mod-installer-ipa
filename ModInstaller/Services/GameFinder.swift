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
        
        print("🔍 Searching for game in: \(applicationDirectory)")
        
        do {
            let apps = try fileManager.contentsOfDirectory(atPath: applicationDirectory)
            print("📱 Found \(apps.count) apps")
            
            for appUUID in apps {
                let appPath = "\(applicationDirectory)/\(appUUID)/Documents"
                
                // Check if this is the game by looking for specific files
                let testPath = "\(appPath)/Resources"
                
                if fileManager.fileExists(atPath: testPath) {
                    print("✅ Found Resources folder: \(testPath)")
                    
                    // Check for ANY version folder (not just 1.60)
                    if let versions = try? fileManager.contentsOfDirectory(atPath: testPath) {
                        print("📂 Versions found: \(versions)")
                        
                        // Look for version folders (e.g., 1.60.1, 1.61.2, etc.)
                        if versions.contains(where: { $0.range(of: "^\\d+\\.\\d+", options: .regularExpression) != nil }) {
                            print("🎮 Game found at: \(appPath)")
                            return URL(fileURLWithPath: appPath)
                        }
                    }
                }
            }
        } catch {
            print("❌ Error searching for game: \(error)")
        }
        
        print("❌ Game not found")
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
    func getVersionDirectory(version: String? = nil) -> URL? {
        guard let resourcesDir = getResourcesDirectory() else { return nil }
        
        // If specific version provided, try that first
        if let version = version {
            let versionPath = resourcesDir.appendingPathComponent(version)
            if FileManager.default.fileExists(atPath: versionPath.path) {
                return versionPath
            }
        }
        
        // Otherwise, find ANY version folder automatically
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: resourcesDir.path)
            
            // Look for folders matching version pattern (e.g., 1.60.1, 1.61.2)
            for folder in contents {
                if folder.range(of: "^\\d+\\.\\d+\\.\\d+$", options: .regularExpression) != nil {
                    let versionPath = resourcesDir.appendingPathComponent(folder)
                    print("🎯 Auto-detected version: \(folder)")
                    return versionPath
                }
            }
            
            // Fallback: Try 2-part versions (e.g., 1.60)
            for folder in contents {
                if folder.range(of: "^\\d+\\.\\d+$", options: .regularExpression) != nil {
                    let versionPath = resourcesDir.appendingPathComponent(folder)
                    print("🎯 Auto-detected version: \(folder)")
                    return versionPath
                }
            }
        } catch {
            print("❌ Error reading Resources folder: \(error)")
        }
        
        return nil
    }
}
