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
                
                // Mod List
                if !viewModel.modPacks.isEmpty {
                    modListSection
                }
                
                // Actions
                Spacer()
                
                actionButtons
                
                // Progress
                if viewModel.isInstalling {
                    progressSection
                }
            }
            .padding()
            .navigationTitle("Mod Installer")
            .navigationBarTitleDisplayMode(.large)
            .alert("Lỗi", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
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
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var modListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mod Packs (\(viewModel.modPacks.count))")
                .font(.headline)
            
            ScrollView {
                ForEach(viewModel.modPacks) { mod in
                    ModPackRow(
                        modPack: mod,
                        isSelected: viewModel.selectedModPack?.id == mod.id
                    )
                    .onTapGesture {
                        viewModel.selectedModPack = mod
                    }
                }
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
            
            // Install
            Button(action: {
                viewModel.installSelectedMod()
            }) {
                Label("Cài Đặt Mod", systemImage: "arrow.down.circle.fill")
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
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color.secondary.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
