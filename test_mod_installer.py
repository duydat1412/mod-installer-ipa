#!/usr/bin/env python3
"""
Test script for Mod Installer logic
Simulates iOS app behavior on Windows for testing
"""

import os
import shutil
from pathlib import Path
from typing import List, Dict
import json
from datetime import datetime

class Colors:
    """ANSI color codes"""
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

class ModFileMapping:
    """File mapping configuration (same as Swift app)"""
    def __init__(self, source_folder: str, target_folder: str, recursive: bool):
        self.source_folder = source_folder
        self.target_folder = target_folder
        self.recursive = recursive
    
    @staticmethod
    def get_mappings():
        return [
            ModFileMapping("AssetRefs/Hero", "AssetRefs/Hero", False),
            ModFileMapping("Prefab_Characters", "Prefab_Characters", False),
            ModFileMapping("assetbundle", "assetbundle", False),
            ModFileMapping("Databin/Client", "Databin/Client", True),
            ModFileMapping("Ages/Prefab_Characters/Prefab_Hero", "Ages/Prefab_Characters/Prefab_Hero", False),
            ModFileMapping("Languages/VN_Garena_VN", "Languages/VN_Garena_VN", False),
        ]

class MockGameEnvironment:
    """Creates mock game directory structure"""
    def __init__(self, base_path: Path):
        self.base_path = base_path
        self.game_dir = base_path / "MockGame" / "Documents" / "Resources" / "1.60.1"
        self.backup_dir = base_path / "MockGame" / "Documents" / ".ModInstaller_Backup"
        
    def setup(self):
        """Create fake game directory with sample files"""
        print(f"{Colors.BLUE}📁 Setting up mock game environment...{Colors.RESET}")
        
        # Create directory structure
        folders = [
            "AssetRefs/Hero",
            "Prefab_Characters",
            "assetbundle",
            "Databin/Client/Actor",
            "Databin/Client/Character",
            "Databin/Client/Motion",
            "Databin/Client/Shop",
            "Databin/Client/Skill",
            "Databin/Client/Sound",
            "Ages/Prefab_Characters/Prefab_Hero",
            "Languages/VN_Garena_VN",
        ]
        
        for folder in folders:
            folder_path = self.game_dir / folder
            folder_path.mkdir(parents=True, exist_ok=True)
            
            # Create dummy files
            if "AssetRefs/Hero" in folder:
                self._create_dummy_file(folder_path / "105_AssetRef.bytes", 1024)
                self._create_dummy_file(folder_path / "106_AssetRef.bytes", 1024)
                
            elif folder == "Prefab_Characters":
                self._create_dummy_file(folder_path / "Actor_105_Infos.pkg.bytes", 2048)
                self._create_dummy_file(folder_path / "Actor_106_Infos.pkg.bytes", 2048)
                
            elif folder == "assetbundle":
                self._create_dummy_file(folder_path / "original_bundle.assetbundle", 5120)
                
            elif "Databin/Client" in folder:
                if "Actor" in folder:
                    self._create_dummy_file(folder_path / "heroSkin.bytes", 3072)
                elif "Sound" in folder:
                    self._create_dummy_file(folder_path / "HeroSound.bytes", 4096)
        
        print(f"{Colors.GREEN}✅ Mock game environment created at: {self.game_dir}{Colors.RESET}\n")
        
    def _create_dummy_file(self, path: Path, size: int):
        """Create a dummy file with specified size"""
        with open(path, 'wb') as f:
            f.write(b'MOCK_DATA' * (size // 9))

class ModPackScanner:
    """Scans and analyzes mod pack (same logic as Swift app)"""
    def __init__(self, mod_pack_path: Path):
        self.mod_pack_path = mod_pack_path
        
    def scan(self) -> Dict:
        """Scan mod pack and return metadata"""
        print(f"{Colors.BLUE}🔍 Scanning mod pack: {self.mod_pack_path.name}{Colors.RESET}")
        
        # Find version folder (1.60.1)
        version_folder = self._find_version_folder()
        if not version_folder:
            print(f"{Colors.RED}❌ Cannot find version folder (1.60.1){Colors.RESET}")
            return None
            
        # Count files
        file_count = self._count_files(version_folder)
        total_size = self._calculate_size(version_folder)
        
        mod_info = {
            'name': self.mod_pack_path.name,
            'version': '1.60.1',
            'author': self._extract_author(),
            'folder_path': version_folder,
            'file_count': file_count,
            'size': total_size,
            'size_formatted': self._format_size(total_size)
        }
        
        print(f"{Colors.GREEN}✅ Mod Pack Info:{Colors.RESET}")
        print(f"   Name: {mod_info['name']}")
        print(f"   Author: {mod_info['author']}")
        print(f"   Files: {mod_info['file_count']}")
        print(f"   Size: {mod_info['size_formatted']}")
        print(f"   Path: {mod_info['folder_path']}\n")
        
        return mod_info
        
    def _find_version_folder(self) -> Path:
        """Find 1.60.1 folder in mod pack"""
        for root, dirs, files in os.walk(self.mod_pack_path):
            for dir_name in dirs:
                if '1.60' in dir_name:
                    return Path(root) / dir_name
        return None
        
    def _count_files(self, path: Path) -> int:
        """Count all files recursively"""
        count = 0
        for root, dirs, files in os.walk(path):
            count += len([f for f in files if not f.startswith('.')])
        return count
        
    def _calculate_size(self, path: Path) -> int:
        """Calculate total size in bytes"""
        total = 0
        for root, dirs, files in os.walk(path):
            for file in files:
                if not file.startswith('.'):
                    file_path = Path(root) / file
                    total += file_path.stat().st_size
        return total
        
    def _extract_author(self) -> str:
        """Extract author from folder name"""
        name = self.mod_pack_path.name
        if 'by ' in name:
            return name.split('by ')[-1].strip()
        if 'Youtube' in name:
            return 'Youtube' + name.split('Youtube')[-1]
        return 'Unknown'
        
    def _format_size(self, size: int) -> str:
        """Format size in human readable format"""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size < 1024:
                return f"{size:.2f} {unit}"
            size /= 1024
        return f"{size:.2f} TB"

class ModInstaller:
    """Simulates mod installation process"""
    def __init__(self, game_env: MockGameEnvironment):
        self.game_env = game_env
        self.log_file = Path("mod_install_test.log")
        self.logs = []
        
    def create_backup(self):
        """Backup original files"""
        print(f"{Colors.BLUE}💾 Creating backup...{Colors.RESET}")
        
        backup_dir = self.game_env.backup_dir
        game_dir = self.game_env.game_dir
        
        if backup_dir.exists():
            print(f"{Colors.YELLOW}⚠️  Backup already exists{Colors.RESET}\n")
            return
            
        backup_dir.mkdir(parents=True, exist_ok=True)
        
        for mapping in ModFileMapping.get_mappings():
            source = game_dir / mapping.target_folder
            target = backup_dir / mapping.target_folder
            
            if source.exists():
                self._log(f"Backing up: {mapping.target_folder}")
                shutil.copytree(source, target, dirs_exist_ok=True)
                
        print(f"{Colors.GREEN}✅ Backup completed!{Colors.RESET}\n")
        
    def install_mod(self, mod_info: Dict, dry_run: bool = True):
        """Install mod files"""
        mode = "DRY RUN" if dry_run else "PRODUCTION"
        print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}")
        print(f"{Colors.BOLD}🚀 Installing Mod - {mode} MODE{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}\n")
        
        mod_root = mod_info['folder_path']
        game_dir = self.game_env.game_dir
        
        files_processed = 0
        total_files = mod_info['file_count']
        
        for mapping in ModFileMapping.get_mappings():
            source_folder = mod_root / mapping.source_folder
            target_folder = game_dir / mapping.target_folder
            
            if not source_folder.exists():
                self._log(f"⚠️  Skipping {mapping.source_folder} - not found in mod pack", Colors.YELLOW)
                continue
                
            print(f"{Colors.BLUE}📂 Processing: {mapping.source_folder}{Colors.RESET}")
            
            files_copied = self._copy_files(
                source_folder,
                target_folder,
                mapping.recursive,
                dry_run
            )
            
            files_processed += files_copied
            progress = (files_processed / total_files) * 100
            print(f"   Progress: {files_processed}/{total_files} ({progress:.1f}%)\n")
            
        print(f"{Colors.BOLD}{Colors.GREEN}✅ Installation completed!{Colors.RESET}")
        print(f"{Colors.GREEN}   Files processed: {files_processed}/{total_files}{Colors.RESET}\n")
        
        self._save_log()
        
    def _copy_files(self, source: Path, target: Path, recursive: bool, dry_run: bool) -> int:
        """Copy files from source to target"""
        count = 0
        
        if not target.exists() and not dry_run:
            target.mkdir(parents=True, exist_ok=True)
            
        for item in source.iterdir():
            if item.name.startswith('.'):
                continue
                
            target_item = target / item.name
            
            if item.is_file():
                action = "WOULD COPY" if dry_run else "COPYING"
                self._log(f"   {action}: {item.name} → {target.name}", Colors.GREEN)
                
                if not dry_run:
                    if target_item.exists():
                        target_item.unlink()
                    shutil.copy2(item, target_item)
                    
                count += 1
                
            elif recursive and item.is_dir():
                count += self._copy_files(item, target_item, True, dry_run)
                
        return count
        
    def restore_backup(self, dry_run: bool = True):
        """Restore from backup"""
        mode = "DRY RUN" if dry_run else "PRODUCTION"
        print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}")
        print(f"{Colors.BOLD}🔄 Restoring Backup - {mode} MODE{Colors.RESET}")
        print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}\n")
        
        backup_dir = self.game_env.backup_dir
        game_dir = self.game_env.game_dir
        
        if not backup_dir.exists():
            print(f"{Colors.RED}❌ Backup not found!{Colors.RESET}\n")
            return
            
        for mapping in ModFileMapping.get_mappings():
            backup_folder = backup_dir / mapping.target_folder
            target_folder = game_dir / mapping.target_folder
            
            if backup_folder.exists():
                action = "WOULD RESTORE" if dry_run else "RESTORING"
                self._log(f"{action}: {mapping.target_folder}")
                
                if not dry_run:
                    if target_folder.exists():
                        shutil.rmtree(target_folder)
                    shutil.copytree(backup_folder, target_folder)
                    
        print(f"{Colors.GREEN}✅ Restore completed!{Colors.RESET}\n")
        
    def _log(self, message: str, color: str = Colors.RESET):
        """Log message"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        log_entry = f"[{timestamp}] {message}"
        self.logs.append(log_entry)
        print(f"{color}{log_entry}{Colors.RESET}")
        
    def _save_log(self):
        """Save logs to file"""
        with open(self.log_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(self.logs))
        print(f"{Colors.BLUE}📝 Log saved to: {self.log_file}{Colors.RESET}\n")

def main():
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}🧪 MOD INSTALLER - TEST SIMULATION{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}\n")
    
    # Setup paths
    base_path = Path(__file__).parent
    test_env_path = base_path / "test_environment"
    
    # Clean up previous test
    if test_env_path.exists():
        print(f"{Colors.YELLOW}🗑️  Cleaning up previous test environment...{Colors.RESET}")
        shutil.rmtree(test_env_path)
        
    test_env_path.mkdir(exist_ok=True)
    
    # 1. Setup mock game environment
    game_env = MockGameEnvironment(test_env_path)
    game_env.setup()
    
    # 2. Scan mod pack (use real mod pack from acb1)
    mod_pack_path = Path(r"c:\Users\DAT\Desktop\project\acb1\MayManh\iOS")
    
    if not mod_pack_path.exists():
        print(f"{Colors.RED}❌ Mod pack not found at: {mod_pack_path}{Colors.RESET}")
        print(f"{Colors.YELLOW}💡 Using mock mod pack instead...{Colors.RESET}\n")
        # Create mock mod pack
        mod_pack_path = test_env_path / "MockModPack"
        mod_pack_path.mkdir(exist_ok=True)
        (mod_pack_path / "Resources" / "1.60.1" / "AssetRefs" / "Hero").mkdir(parents=True, exist_ok=True)
        
    scanner = ModPackScanner(mod_pack_path)
    mod_info = scanner.scan()
    
    if not mod_info:
        print(f"{Colors.RED}❌ Failed to scan mod pack{Colors.RESET}")
        return
        
    # 3. Test installation
    installer = ModInstaller(game_env)
    
    # Create backup
    installer.create_backup()
    
    # Install mod (DRY RUN)
    print(f"{Colors.YELLOW}{'='*60}{Colors.RESET}")
    print(f"{Colors.YELLOW}MODE: DRY RUN - No files will be actually copied{Colors.RESET}")
    print(f"{Colors.YELLOW}{'='*60}{Colors.RESET}\n")
    installer.install_mod(mod_info, dry_run=True)
    
    # Ask for production run
    print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}")
    response = input(f"{Colors.YELLOW}Run in PRODUCTION mode (actually copy files)? (y/N): {Colors.RESET}")
    
    if response.lower() == 'y':
        installer.install_mod(mod_info, dry_run=False)
        
        # Test restore
        print(f"\n{Colors.BOLD}{Colors.BLUE}{'='*60}{Colors.RESET}")
        response = input(f"{Colors.YELLOW}Test RESTORE backup? (y/N): {Colors.RESET}")
        if response.lower() == 'y':
            installer.restore_backup(dry_run=False)
    
    print(f"\n{Colors.BOLD}{Colors.GREEN}{'='*60}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.GREEN}✅ TEST COMPLETED!{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.GREEN}{'='*60}{Colors.RESET}\n")
    print(f"{Colors.BLUE}📁 Test environment: {test_env_path}{Colors.RESET}")
    print(f"{Colors.BLUE}📝 Log file: {installer.log_file}{Colors.RESET}\n")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}⚠️  Test interrupted by user{Colors.RESET}")
    except Exception as e:
        print(f"\n{Colors.RED}❌ Error: {e}{Colors.RESET}")
        import traceback
        traceback.print_exc()
