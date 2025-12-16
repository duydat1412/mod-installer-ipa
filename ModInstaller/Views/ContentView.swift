import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ModInstallerViewModel()
    @State private var showDocumentPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Status
                statusSection
                
                // Mod List - ✅ FIXED: Luôn hiển thị section này
                modListSection
                
                // Actions
                Spacer()
                
                actionButtons
                
                // Progress
                if viewModel.isInstalling {
                    progressSection
                }
                
                // Footer credits
                creditsFooter
            }
            .padding()
            .navigationTitle("Mod Installer")
            .navigationBarTitleDisplayMode(.large)
            .fileImporter(
                isPresented: $showDocumentPicker,
                allowedContentTypes: [.zip],
                allowsMultipleSelection: false
            ) { result in
                handleModPackImport(result: result)
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Lỗi"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "cube.box.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Liên Quân Mod Installer")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Auto install skin mods")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Credits button
            Button(action: {
                if let url = URL(string: "https://github.com/duydat1412") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                        .font(.caption2)
                    Text("by duydat1412")
                        .font(.caption2)
                    Image(systemName: "arrow.up.right.square.fill")
                        .font(.system(size: 10))
                }
                .foregroundColor(.blue)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.top, 4)
        }
        .padding()
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: viewModel.gameFound ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(viewModel.gameFound ? .green : .red)
                
                Text("Game Status")
                    .fontWeight(.semibold)
            }
            
            Text(viewModel.statusMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
    
    // ✅ FIXED: Luôn hiển thị mod list section
    private var modListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mod Packs (\(viewModel.modPacks.count))")
                .font(.headline)
            
            if viewModel.modPacks.isEmpty {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Chưa có mod pack")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Nhấn 'Thêm Mod Pack' để import")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(10)
            } else {
                // ✅ Mod pack cards
                ScrollView {
                    ForEach(viewModel.modPacks) { mod in
                        ModPackRow(
                            modPack: mod,
                            isSelected: viewModel.selectedModPack?.id == mod.id
                        )
                        .onTapGesture {
                            withAnimation {
                                viewModel.selectedModPack = mod
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Add Mod Pack
            Button(action: {
                showDocumentPicker = true
            }) {
                Label("Thêm Mod Pack", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Backup
            Button(action: {
                viewModel.createBackup()
            }) {
                Label("Tạo Backup", systemImage: "arrow.down.doc.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.gameFound)
            
            // Install - ✅ FIXED: Hiển thị rõ trạng thái
            Button(action: {
                viewModel.installSelectedMod()
            }) {
                HStack {
                    if viewModel.selectedModPack == nil {
                        Image(systemName: "hand.tap.fill")
                        Text("Chọn mod pack để cài")
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Cài Đặt Mod")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.selectedModPack != nil ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.selectedModPack == nil || !viewModel.gameFound || viewModel.isInstalling)
            
            // Restore
            Button(action: {
                viewModel.restoreBackup()
            }) {
                Label("Restore Backup", systemImage: "arrow.uturn.backward.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.gameFound)
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 10) {
            ProgressView(value: viewModel.installProgress.percentage) {
                Text("Đang cài đặt...")
                    .font(.caption)
            }
            
            Text("\(viewModel.installProgress.filesProcessed) / \(viewModel.installProgress.totalFiles) files")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(viewModel.installProgress.currentFile)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var creditsFooter: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack(spacing: 16) {
                // GitHub repo
                Button(action: {
                    if let url = URL(string: "https://github.com/duydat1412/mod-installer-ipa") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.caption)
                        Text("Source Code")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                }
                
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.caption2)
                
                // Profile
                Button(action: {
                    if let url = URL(string: "https://github.com/duydat1412") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.circle")
                            .font(.caption)
                        Text("@duydat1412")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                }
                
                Text("•")
                    .foregroundColor(.secondary)
                    .font(.caption2)
                
                Text("v1.0.3")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text("Made with ❤️ for Liên Quân community")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Mod Pack Row

struct ModPackRow: View {
    let modPack: ModPack
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(modPack.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("by \(modPack.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label("\(modPack.fileCount) files", systemImage: "doc.fill")
                    Label(modPack.sizeFormatted, systemImage: "internaldrive.fill")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - ContentView Extension

extension ContentView {
    // MARK: - Helper Functions
    
    private func handleModPackImport(result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                viewModel.errorMessage = "Không thể truy cập file/folder"
                viewModel.showError = true
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Import mod pack
            viewModel.importModPack(from: url)
            
        } catch {
            viewModel.errorMessage = "Lỗi chọn mod pack: \(error.localizedDescription)"
            viewModel.showError = true
        }
    }
}

#Preview {
    ContentView()
}