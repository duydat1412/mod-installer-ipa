import Foundation
import SwiftUI
import Combine

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
        if let gameDir = gameFinder.getVersionDirectory() {
            gameFound = true
            statusMessage = "✅ Đã tìm thấy game tại: \(gameDir.path)"
        } else {
            gameFound = false
            statusMessage = "❌ Không tìm thấy Liên Quân Mobile"
        }
    }
    
    // MARK: - Scan Mod Pack
    
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
