import Foundation

class ModInstallService {
    static let shared = ModInstallService()
    
    private let fileManager = FileManager.default
    private let backupFolderName = ".ModInstaller_Backup"
    
    // MARK: - Scan Mod Pack
    
    func scanModPack(at url: URL) -> ModPack? {
        // Tìm folder 1.60.1 trong mod pack
        var modRootURL = url
        
        // Check for nested structure: Resources/Resources/1.60.1
        if let resourcesURL = findVersionFolder(in: url) {
            modRootURL = resourcesURL
        } else {
            print("❌ Cannot find version folder in mod pack")
            return nil
        }
        
        // Count files
        let fileCount = countFiles(in: modRootURL)
        let size = calculateSize(of: modRootURL)
        
        // Extract metadata from folder name or config
        let name = url.lastPathComponent
        let author = extractAuthor(from: url) ?? "Unknown"
        
        return ModPack(
            name: name,
            version: "1.60.1",
            author: author,
            folderPath: modRootURL,
            fileCount: fileCount,
            size: size
        )
    }
    
    private func findVersionFolder(in url: URL) -> URL? {
        let fileManager = FileManager.default
        
        // Check direct
        if url.lastPathComponent.contains("1.60") {
            return url
        }
        
        // Check nested
        do {
            let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for item in contents {
                if item.lastPathComponent.contains("1.60") {
                    return item
                }
                
                // Check one level deeper
                if item.hasDirectoryPath {
                    if let found = findVersionFolder(in: item) {
                        return found
                    }
                }
            }
        } catch {
            print("Error scanning: \(error)")
        }
        
        return nil
    }
    
    private func countFiles(in url: URL) -> Int {
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey]) else {
            return 0
        }
        
        var count = 0
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
               resourceValues.isRegularFile == true {
                count += 1
            }
        }
        return count
    }
    
    private func calculateSize(of url: URL) -> Int64 {
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        return totalSize
    }
    
    private func extractAuthor(from url: URL) -> String? {
        let name = url.lastPathComponent
        
        // Extract from patterns like "[Mod VN] ... by Author"
        if name.contains("by ") {
            let components = name.components(separatedBy: "by ")
            return components.last?.trimmingCharacters(in: .whitespaces)
        }
        
        // Extract from "Youtube KHAM-PHA-MOBILE"
        if name.contains("Youtube") {
            let components = name.components(separatedBy: "Youtube")
            return "Youtube" + (components.last ?? "")
        }
        
        return nil
    }
    
    // MARK: - Backup Original Files
    
    func backupOriginalFiles(progress: @escaping (String) -> Void) throws {
        guard let gameDir = GameFinder.shared.getVersionDirectory() else {
            throw ModInstallError.gameNotFound
        }
        
        let backupDir = gameDir.deletingLastPathComponent().appendingPathComponent(backupFolderName)
        
        // Check if backup already exists
        if fileManager.fileExists(atPath: backupDir.path) {
            print("✅ Backup already exists")
            return
        }
        
        progress("Creating backup...")
        
        // Create backup directory
        try fileManager.createDirectory(at: backupDir, withIntermediateDirectories: true)
        
        // Backup each mapped folder
        for mapping in ModFileMapping.mappings {
            let sourceURL = gameDir.appendingPathComponent(mapping.targetFolder)
            let backupURL = backupDir.appendingPathComponent(mapping.targetFolder)
            
            if fileManager.fileExists(atPath: sourceURL.path) {
                progress("Backing up \(mapping.targetFolder)...")
                try fileManager.copyItem(at: sourceURL, to: backupURL)
            }
        }
        
        progress("Backup completed!")
    }
    
    // MARK: - Install Mod
    
    func installMod(_ modPack: ModPack, progress: @escaping (InstallProgress) -> Void) throws {
        guard let gameDir = GameFinder.shared.getVersionDirectory() else {
            throw ModInstallError.gameNotFound
        }
        
        let modRootURL = modPack.folderPath
        var installProgress = InstallProgress(totalFiles: modPack.fileCount)
        
        // Process each mapping
        for mapping in ModFileMapping.mappings {
            let sourceFolder = modRootURL.appendingPathComponent(mapping.sourceFolder)
            let targetFolder = gameDir.appendingPathComponent(mapping.targetFolder)
            
            // Check if source exists
            guard fileManager.fileExists(atPath: sourceFolder.path) else {
                print("⚠️ Skipping \(mapping.sourceFolder) - not found in mod pack")
                continue
            }
            
            installProgress.currentFile = mapping.sourceFolder
            progress(installProgress)
            
            // Copy files
            try copyFiles(
                from: sourceFolder,
                to: targetFolder,
                recursive: mapping.recursive,
                progress: &installProgress,
                progressCallback: progress
            )
        }
        
        installProgress.isComplete = true
        progress(installProgress)
    }
    
    private func copyFiles(
        from source: URL,
        to target: URL,
        recursive: Bool,
        progress: inout InstallProgress,
        progressCallback: (InstallProgress) -> Void
    ) throws {
        // Create target directory if needed
        try fileManager.createDirectory(at: target, withIntermediateDirectories: true)
        
        let contents = try fileManager.contentsOfDirectory(
            at: source,
            includingPropertiesForKeys: [.isRegularFileKey, .isDirectoryKey]
        )
        
        for item in contents {
            // Skip hidden files
            if item.lastPathComponent.hasPrefix(".") {
                continue
            }
            
            let targetItem = target.appendingPathComponent(item.lastPathComponent)
            
            let resourceValues = try item.resourceValues(forKeys: [.isRegularFileKey, .isDirectoryKey])
            
            if resourceValues.isRegularFile == true {
                // Copy file (replace if exists)
                if fileManager.fileExists(atPath: targetItem.path) {
                    try fileManager.removeItem(at: targetItem)
                }
                
                try fileManager.copyItem(at: item, to: targetItem)
                
                progress.currentFile = item.lastPathComponent
                progress.filesProcessed += 1
                progressCallback(progress)
                
            } else if recursive && resourceValues.isDirectory == true {
                // Recursively copy directory
                try copyFiles(
                    from: item,
                    to: targetItem,
                    recursive: true,
                    progress: &progress,
                    progressCallback: progressCallback
                )
            }
        }
    }
    
    // MARK: - Restore Backup
    
    func restoreBackup(progress: @escaping (String) -> Void) throws {
        guard let gameDir = GameFinder.shared.getVersionDirectory() else {
            throw ModInstallError.gameNotFound
        }
        
        let backupDir = gameDir.deletingLastPathComponent().appendingPathComponent(backupFolderName)
        
        guard fileManager.fileExists(atPath: backupDir.path) else {
            throw ModInstallError.backupNotFound
        }
        
        progress("Restoring backup...")
        
        // Restore each backed up folder
        for mapping in ModFileMapping.mappings {
            let backupURL = backupDir.appendingPathComponent(mapping.targetFolder)
            let targetURL = gameDir.appendingPathComponent(mapping.targetFolder)
            
            if fileManager.fileExists(atPath: backupURL.path) {
                progress("Restoring \(mapping.targetFolder)...")
                
                // Remove current
                if fileManager.fileExists(atPath: targetURL.path) {
                    try fileManager.removeItem(at: targetURL)
                }
                
                // Copy backup
                try fileManager.copyItem(at: backupURL, to: targetURL)
            }
        }
        
        progress("Restore completed!")
    }
    
    // MARK: - Delete Backup
    
    func deleteBackup() throws {
        guard let gameDir = GameFinder.shared.getVersionDirectory() else {
            throw ModInstallError.gameNotFound
        }
        
        let backupDir = gameDir.deletingLastPathComponent().appendingPathComponent(backupFolderName)
        
        if fileManager.fileExists(atPath: backupDir.path) {
            try fileManager.removeItem(at: backupDir)
        }
    }
}

// MARK: - Errors

enum ModInstallError: LocalizedError {
    case gameNotFound
    case backupNotFound
    case invalidModPack
    case copyFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .gameNotFound:
            return "Không tìm thấy Liên Quân Mobile. Vui lòng cài game và chạy ít nhất 1 lần."
        case .backupNotFound:
            return "Không tìm thấy backup. Vui lòng tạo backup trước."
        case .invalidModPack:
            return "Mod pack không hợp lệ. Kiểm tra lại cấu trúc folder."
        case .copyFailed(let file):
            return "Lỗi khi copy file: \(file)"
        }
    }
}
