import Foundation

// Mod Pack model
struct ModPack: Identifiable, Codable {
    let id: UUID
    let name: String
    let version: String
    let author: String
    let folderPath: URL
    let fileCount: Int
    let size: Int64
    var isInstalled: Bool
    
    init(name: String, version: String, author: String, folderPath: URL, fileCount: Int, size: Int64) {
        self.id = UUID()
        self.name = name
        self.version = version
        self.author = author
        self.folderPath = folderPath
        self.fileCount = fileCount
        self.size = size
        self.isInstalled = false
    }
    
    var sizeFormatted: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// File mapping configuration
struct ModFileMapping {
    let sourceFolder: String
    let targetFolder: String
    let recursive: Bool
    
    static let mappings: [ModFileMapping] = [
        // AssetRefs/Hero
        ModFileMapping(
            sourceFolder: "AssetRefs/Hero",
            targetFolder: "AssetRefs/Hero",
            recursive: true
        ),
        
        // Prefab_Characters
        ModFileMapping(
            sourceFolder: "Prefab_Characters",
            targetFolder: "Prefab_Characters",
            recursive: true
        ),
        
        // assetbundle
        ModFileMapping(
            sourceFolder: "assetbundle",
            targetFolder: "assetbundle",
            recursive: true
        ),
        
        // Databin/Client
        ModFileMapping(
            sourceFolder: "Databin/Client",
            targetFolder: "Databin/Client",
            recursive: true
        ),
        
        // Ages/Prefab_Characters/Prefab_Hero
        ModFileMapping(
            sourceFolder: "Ages/Prefab_Characters/Prefab_Hero",
            targetFolder: "Ages/Prefab_Characters/Prefab_Hero",
            recursive: true
        ),
        
        // Languages/VN_Garena_VN
        ModFileMapping(
            sourceFolder: "Languages/VN_Garena_VN",
            targetFolder: "Languages/VN_Garena_VN",
            recursive: true
        )
    ]
}

// Installation progress
struct InstallProgress {
    var currentFile: String = ""
    var filesProcessed: Int = 0
    var totalFiles: Int = 0
    var isComplete: Bool = false
    var error: String?
    
    var percentage: Double {
        guard totalFiles > 0 else { return 0 }
        return Double(filesProcessed) / Double(totalFiles)
    }
}
