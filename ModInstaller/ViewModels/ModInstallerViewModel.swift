import Foundation
import SwiftUI
import Combine

@MainActor
class ModInstallerViewModel: ObservableObject {
    @Published var modPacks: [ModPack] = []
    @Published var selectedModPack: ModPack?
    @Published var installProgress = InstallProgress()
    @Published var isInstalling = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var statusMessage = ""
    @Published var gameFound = false
    
    private let installService = ModInstallService.shared
    private let gameFinder = GameFinder.shared
    
    init() {
        checkGameInstallation()
    }
    
    // MARK: - Check Game
    
    func checkGameInstallation() {
        // Check root access first
        let hasRootAccess = gameFinder.checkRootAccess()
        
        if !hasRootAccess {
            gameFound = false
            statusMessage = "❌ Không có quyền truy cập root\n\n⚠️ App cần cài qua TrollStore để có quyền đặc biệt"
            return
        }
        
        if let gameDir = gameFinder.getVersionDirectory() {
            gameFound = true
            statusMessage = "✅ Đã tìm thấy game tại: \(gameDir.path)"
        } else {
            gameFound = false
            statusMessage = "❌ Không tìm thấy Liên Quân Mobile\n\nKiểm tra:\n1. Game đã cài chưa?\n2. App được cài qua TrollStore?\n3. Xem Console logs để debug"
        }
    }
    
    // MARK: - Scan Mod Pack
    
    func importModPack(from url: URL) {
        // Copy mod pack to app's Documents folder for permanent access
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let modPacksFolder = documentsURL.appendingPathComponent("ModPacks")
        
        do {
            // Create ModPacks folder if needed
            try FileManager.default.createDirectory(at: modPacksFolder, withIntermediateDirectories: true)
            
            // Handle ZIP files
            if url.pathExtension.lowercased() == "zip" {
                // TODO: Unzip implementation
                statusMessage = "⚠️ ZIP support coming soon! Vui lòng extract trước rồi chọn folder."
                return
            }
            
            // Auto-detect mod pack structure
            let modPackURL = findModPackRoot(in: url)
            
            // Destination path
            let destination = modPacksFolder.appendingPathComponent(url.lastPathComponent)
            
            // Remove if exists
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            
            // Copy folder
            try FileManager.default.copyItem(at: url, to: destination)
            
            // Find and scan the actual mod pack location
            let actualModRoot = findModPackRoot(in: destination)
            scanModPackFolder(url: actualModRoot)
            
        } catch {
            showError(message: "Lỗi import mod pack: \(error.localizedDescription)")
        }
    }
    
    /// Auto-detect mod pack root folder (Resources/1.60.x/)
    private func findModPackRoot(in folder: URL) -> URL {
        let fm = FileManager.default
        
        // Check if current folder already has mod files
        if hasModFiles(at: folder) {
            print("✅ Found mod files at root: \(folder.path)")
            return folder
        }
        
        // Look for Resources folder
        let resourcesURL = folder.appendingPathComponent("Resources")
        if fm.fileExists(atPath: resourcesURL.path) {
            // Look for version folders (1.60.1, 1.61.2, etc.)
            if let contents = try? fm.contentsOfDirectory(atPath: resourcesURL.path) {
                for item in contents {
                    if item.range(of: "^\\d+\\.\\d+", options: .regularExpression) != nil {
                        let versionURL = resourcesURL.appendingPathComponent(item)
                        if hasModFiles(at: versionURL) {
                            print("✅ Found mod files at: \(versionURL.path)")
                            return versionURL
                        }
                    }
                }
            }
        }
        
        // Fallback: recursively search
        if let enumerator = fm.enumerator(at: folder, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if hasModFiles(at: fileURL) {
                    print("✅ Found mod files at: \(fileURL.path)")
                    return fileURL
                }
            }
        }
        
        print("⚠️ No mod files detected, using root folder: \(folder.path)")
        return folder
    }
    
    /// Check if folder contains mod files (AssetRefs, Prefab_Characters, etc.)
    private func hasModFiles(at folder: URL) -> Bool {
        let fm = FileManager.default
        let expectedFolders = ["AssetRefs", "Prefab_Characters", "assetbundle", "Databin", "Ages", "Languages"]
        
        var count = 0
        for folderName in expectedFolders {
            let path = folder.appendingPathComponent(folderName).path
            if fm.fileExists(atPath: path) {
                count += 1
            }
        }
        
        // Consider it a mod pack if at least 2 expected folders exist
        return count >= 2
    }
    
    func scanModPackFolder(url: URL) {
        print("🔍 Scanning mod pack at: \(url.path)")
        
        guard let modPack = installService.scanModPack(at: url) else {
            showError(message: "Không thể đọc mod pack.\n\nKiểm tra:\n- Folder có đúng cấu trúc không?\n- Có chứa AssetRefs, Prefab_Characters, etc?")
            return
        }
        
        print("✅ Found mod pack: \(modPack.name) - \(modPack.fileCount) files")
        
        // Add to list if not exists
        if !modPacks.contains(where: { $0.folderPath == modPack.folderPath }) {
            modPacks.append(modPack)
            statusMessage = "✅ Đã thêm: \(modPack.name)\n📦 \(modPack.fileCount) files (\(modPack.sizeFormatted))"
        } else {
            statusMessage = "⚠️ Mod pack đã tồn tại"
        }
    }
    
    // MARK: - Backup
    
    func createBackup() {
        guard gameFound else {
            showError(message: "Chưa tìm thấy game. Vui lòng cài Liên Quân Mobile trước.")
            return
        }
        
        Task { @MainActor in
            statusMessage = "⏳ Đang tạo backup..."
            
            do {
                try installService.backupOriginalFiles { message in
                    DispatchQueue.main.async {
                        self.statusMessage = "📦 " + message
                    }
                }
                statusMessage = "✅ Backup hoàn tất!\n\n⚠️ Lưu ý: Backup sẽ bị ghi đè nếu tạo lại."
            } catch {
                showError(message: "Lỗi tạo backup:\n\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Install Mod
    
    func installSelectedMod() {
        guard let modPack = selectedModPack else {
            showError(message: "⚠️ Vui lòng chọn mod pack từ danh sách")
            return
        }
        
        guard gameFound else {
            showError(message: "❌ Chưa tìm thấy game")
            return
        }
        
        isInstalling = true
        installProgress = InstallProgress(totalFiles: modPack.fileCount)
        statusMessage = "⏳ Đang cài đặt \(modPack.name)..."
        
        Task { @MainActor in
            do {
                try installService.installMod(modPack) { progress in
                    DispatchQueue.main.async {
                        self.installProgress = progress
                        
                        if progress.isComplete {
                            self.isInstalling = false
                            self.statusMessage = """
                            ✅ Cài đặt thành công!
                            
                            📝 Bước tiếp theo:
                            1. Tắt Liên Quân (force close)
                            2. Mở lại game
                            3. Kiểm tra skin mods
                            
                            💡 Nếu muốn gỡ: ấn Restore Backup
                            """
                        }
                    }
                }
            } catch {
                isInstalling = false
                showError(message: "❌ Lỗi cài đặt:\n\(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Restore
    
    func restoreBackup() {
        guard gameFound else {
            showError(message: "Chưa tìm thấy game")
            return
        }
        
        Task { @MainActor in
            statusMessage = "⏳ Đang restore backup..."
            
            do {
                try installService.restoreBackup { message in
                    DispatchQueue.main.async {
                        self.statusMessage = "📦 " + message
                    }
                }
                statusMessage = """
                ✅ Đã restore về bản gốc!
                
                📝 Restart game để áp dụng
                """
            } catch {
                showError(message: "❌ Lỗi restore:\n\(error.localizedDescription)\n\n💡 Có thể chưa tạo backup?")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
