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
            
            // Destination path
            let destination = modPacksFolder.appendingPathComponent(url.lastPathComponent)
            
            // Remove if exists
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            
            // Handle ZIP files
            if url.pathExtension.lowercased() == "zip" {
                // TODO: Unzip implementation
                statusMessage = "⚠️ ZIP support coming soon! Vui lòng extract trước rồi chọn folder."
                return
            }
            
            // Copy folder
            try FileManager.default.copyItem(at: url, to: destination)
            
            // Scan mod pack
            scanModPackFolder(url: destination)
            
        } catch {
            showError(message: "Lỗi import mod pack: \(error.localizedDescription)")
        }
    }
    
    func scanModPackFolder(url: URL) {
        guard let modPack = installService.scanModPack(at: url) else {
            showError(message: "Không thể đọc mod pack. Kiểm tra lại cấu trúc folder.")
            return
        }
        
        // Add to list if not exists
        if !modPacks.contains(where: { $0.folderPath == modPack.folderPath }) {
            modPacks.append(modPack)
            statusMessage = "✅ Đã thêm mod: \(modPack.name)"
        }
    }
    
    // MARK: - Backup
    
    func createBackup() {
        Task { @MainActor in
            statusMessage = "Đang tạo backup..."
            
            do {
                try installService.backupOriginalFiles { message in
                    DispatchQueue.main.async {
                        self.statusMessage = message
                    }
                }
                statusMessage = "✅ Backup hoàn tất!"
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Install Mod
    
    func installSelectedMod() {
        guard let modPack = selectedModPack else {
            showError(message: "Vui lòng chọn mod pack")
            return
        }
        
        isInstalling = true
        installProgress = InstallProgress(totalFiles: modPack.fileCount)
        
        Task { @MainActor in
            do {
                try installService.installMod(modPack) { progress in
                    DispatchQueue.main.async {
                        self.installProgress = progress
                        
                        if progress.isComplete {
                            self.isInstalling = false
                            self.statusMessage = "✅ Cài đặt mod hoàn tất! Restart game để áp dụng."
                        }
                    }
                }
            } catch {
                isInstalling = false
                showError(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Restore
    
    func restoreBackup() {
        Task { @MainActor in
            statusMessage = "Đang restore backup..."
            
            do {
                try installService.restoreBackup { message in
                    DispatchQueue.main.async {
                        self.statusMessage = message
                    }
                }
                statusMessage = "✅ Restore hoàn tất!"
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
