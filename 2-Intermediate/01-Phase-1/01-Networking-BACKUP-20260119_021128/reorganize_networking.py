#!/usr/bin/env python3
"""
Intermediate Networking Module - Part-Based Reorganization
Safely reorganizes the networking module into logical Parts.
"""

import os
import shutil
from pathlib import Path
from datetime import datetime
import json

class NetworkingReorganizer:
    def __init__(self, networking_path):
        self.networking_path = Path(networking_path)
        self.backup_path = self.networking_path.parent / f"01-Networking-BACKUP-{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        self.migration_log = []
        
    def create_backup(self):
        """Create full backup before any changes"""
        print(f"[*] Creating backup: {self.backup_path}")
        shutil.copytree(self.networking_path, self.backup_path)
        print(f"[+] Backup created successfully")
        
        # Create backup manifest
        manifest = {
            'timestamp': datetime.now().isoformat(),
            'source': str(self.networking_path),
            'backup': str(self.backup_path),
            'restore_command': f'rm -rf "{self.networking_path}" && mv "{self.backup_path}" "{self.networking_path}"'
        }
        
        with open(self.backup_path / 'BACKUP_INFO.json', 'w') as f:
            json.dump(manifest, f, indent=2)
        
        return self.backup_path
    
    def create_part_structure(self):
        """Create the new Part directories"""
        
        parts = {
            'Part-1-Cloud-Fundamentals': {
                'description': 'Core VPC and cloud networking concepts',
                'modules': [
                    ('01-VPC-Fundamentals', '01-VPC-Fundamentals'),
                    ('02-Subnetting-and-CIDR', '02-Subnetting-and-CIDR'),
                    ('03-Internet-and-NAT-Gateways', '03-Internet-and-NAT-Gateways'),
                    ('04-Routing-and-Route-Tables', '04-Routing-and-Route-Tables'),
                ]
            },
            'Part-2-Network-Security': {
                'description': 'Security controls and access management',
                'modules': [
                    ('05-Network-Security-NACLs-SGs', '01-Security-Groups-and-NACLs'),
                    ('05-VPN-Technologies', '02-VPN-Technologies'),
                    ('04-Network-Security', '03-Traditional-Network-Security'),
                ]
            },
            'Part-3-Connectivity-Patterns': {
                'description': 'Inter-VPC and hybrid connectivity',
                'modules': [
                    ('06-VPC-Peering-and-Transit-Gateway', '01-VPC-Peering-and-Transit-Gateway'),
                    ('09-Hybrid-Connectivity', '02-Hybrid-Connectivity'),
                    ('07-Load-Balancing-ALB-NLB', '03-Load-Balancing-ALB-NLB'),
                    ('06-Load-Balancing', '04-Load-Balancing-Basics'),
                ]
            },
            'Part-4-High-Availability': {
                'description': 'HA, DR, and monitoring',
                'modules': [
                    ('08-High-Availability-and-Multi-Region', '01-High-Availability-Multi-Region'),
                    ('10-Monitoring-and-Troubleshooting', '02-Monitoring-and-Troubleshooting'),
                    ('01-DNS-DHCP', '03-DNS-and-DHCP'),
                ]
            },
            'Part-5-Traditional-Networking': {
                'description': 'Traditional networking concepts (optional)',
                'modules': [
                    ('02-VLANs-Switching', '01-VLANs-and-Switching'),
                    ('03-Advanced-Routing', '02-Advanced-Routing-Protocols'),
                ]
            }
        }
        
        return parts
    
    def reorganize(self, dry_run=False):
        """Execute the reorganization"""
        
        parts_structure = self.create_part_structure()
        
        for part_name, part_data in parts_structure.items():
            part_path = self.networking_path / part_name
            
            if dry_run:
                print(f"\n[DRY RUN] Would create: {part_name}/")
                print(f"  Description: {part_data['description']}")
            else:
                part_path.mkdir(exist_ok=True)
                print(f"\n[CREATED] {part_name}/")
                
                # Create Part README
                self._create_part_readme(part_path, part_name, part_data)
            
            # Move modules
            for old_name, new_name in part_data['modules']:
                old_path = self.networking_path / old_name
                new_path = part_path / new_name
                
                if old_path.exists():
                    if dry_run:
                        print(f"  [DRY RUN] Would move: {old_name} -> {part_name}/{new_name}")
                    else:
                        shutil.move(str(old_path), str(new_path))
                        print(f"  [MOVED] {old_name} -> {part_name}/{new_name}")
                        
                        self.migration_log.append({
                            'old_path': str(old_path.relative_to(self.networking_path)),
                            'new_path': str(new_path.relative_to(self.networking_path)),
                            'timestamp': datetime.now().isoformat()
                        })
                else:
                    print(f"  [SKIP] {old_name} (not found)")
        
        return self.migration_log
    
    def _create_part_readme(self, part_path, part_name, part_data):
        """Create README for each Part"""
        
        readme_content = f"""# {part_name.replace('-', ' ')}

{part_data['description']}

## Modules in This Part

"""
        
        for old_name, new_name in part_data['modules']:
            module_title = new_name.replace('-', ' ').replace('_', ' ')
            readme_content += f"- **[{new_name}](./{new_name}/)** - {module_title}\n"
        
        readme_content += f"""

## Learning Path

Complete these modules in order for the best learning experience.

---

**Part of**: [Intermediate Networking](../README.md)
"""
        
        with open(part_path / 'README.md', 'w', encoding='utf-8') as f:
            f.write(readme_content)
    
    def update_main_readme(self):
        """Update the main networking README"""
        
        new_readme = """# Intermediate Networking: Cloud VPCs & Architecture

> **"Networking is the plumbing of modern infrastructure. Understanding how data flows through cloud networks is essential for every DevOps engineer."**

---

## 📚 Module Organization

This module is organized into **5 logical Parts** for structured learning:

### [Part 1: Cloud Fundamentals](./Part-1-Cloud-Fundamentals/)
Core VPC concepts and cloud networking foundations.

**Modules:**
- 01-VPC-Fundamentals
- 02-Subnetting-and-CIDR
- 03-Internet-and-NAT-Gateways
- 04-Routing-and-Route-Tables

### [Part 2: Network Security](./Part-2-Network-Security/)
Security controls, firewalls, and access management.

**Modules:**
- 01-Security-Groups-and-NACLs
- 02-VPN-Technologies
- 03-Traditional-Network-Security

### [Part 3: Connectivity Patterns](./Part-3-Connectivity-Patterns/)
Inter-VPC connectivity and load balancing.

**Modules:**
- 01-VPC-Peering-and-Transit-Gateway
- 02-Hybrid-Connectivity
- 03-Load-Balancing-ALB-NLB
- 04-Load-Balancing-Basics

### [Part 4: High Availability](./Part-4-High-Availability/)
HA, disaster recovery, and monitoring.

**Modules:**
- 01-High-Availability-Multi-Region
- 02-Monitoring-and-Troubleshooting
- 03-DNS-and-DHCP

### [Part 5: Traditional Networking](./Part-5-Traditional-Networking/)
Classical networking concepts (optional for cloud-focused learners).

**Modules:**
- 01-VLANs-and-Switching
- 02-Advanced-Routing-Protocols

---

## 🎯 Learning Path

### Recommended Order:
1. **Start with Part 1** - Cloud Fundamentals (essential)
2. **Move to Part 2** - Security patterns
3. **Continue with Part 3** - Connectivity
4. **Master Part 4** - HA and monitoring
5. **Optional: Part 5** - Traditional concepts

### Time Estimate:
- **Part 1**: 8-10 hours
- **Part 2**: 6-8 hours
- **Part 3**: 8-10 hours
- **Part 4**: 6-8 hours
- **Part 5**: 4-6 hours (optional)

**Total**: ~32-42 hours for complete mastery

---

## 🔗 Related Modules

### Prerequisites:
- [Beginner Networking](../../../1-Beginner/01-Phase-1/01-Networking/) - Basic concepts

### Next Steps:
- [Advanced Networking](../../../3-Advanced/01-Phase-1/01-Networking/) - Service mesh, SDN
- [Linux Administration](../02-Linux/) - System networking

---

## 🏆 Certifications

This module prepares you for:
- **AWS Certified Solutions Architect - Associate**
- **Azure Network Engineer Associate**
- **GCP Professional Cloud Architect**

---

## 📺 Video Learning

See [Youtube_Lessons.md](./Youtube_Lessons.md) for curated video tutorials.

---

**Ready to dive in?** Start with [Part 1: Cloud Fundamentals](./Part-1-Cloud-Fundamentals/)!
"""
        
        readme_path = self.networking_path / 'README.md'
        
        # Backup old README
        if readme_path.exists():
            shutil.copy(readme_path, self.networking_path / 'README.md.backup')
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(new_readme)
        
        print("[+] Main README updated")
    
    def save_migration_log(self):
        """Save migration log for reference"""
        
        log_path = self.networking_path / 'MIGRATION_LOG.json'
        
        log_data = {
            'timestamp': datetime.now().isoformat(),
            'backup_location': str(self.backup_path),
            'changes': self.migration_log
        }
        
        with open(log_path, 'w', encoding='utf-8') as f:
            json.dump(log_data, f, indent=2)
        
        print(f"[+] Migration log saved: {log_path}")


if __name__ == "__main__":
    import sys
    
    networking_path = "C:/Users/Ganil/Documents/Devops/2-Intermediate/01-Phase-1/01-Networking"
    
    if len(sys.argv) > 1 and sys.argv[1] == '--dry-run':
        print("=== DRY RUN MODE ===")
        print("No files will be moved. This is a preview only.")
        print()
        
        reorg = NetworkingReorganizer(networking_path)
        reorg.reorganize(dry_run=True)
        
        print("\n=== DRY RUN COMPLETE ===")
        print("To execute for real, run without --dry-run flag")
    else:
        print("=" * 70)
        print("INTERMEDIATE NETWORKING - PART-BASED REORGANIZATION")
        print("=" * 70)
        print()
        
        reorg = NetworkingReorganizer(networking_path)
        
        # Create backup first
        backup_path = reorg.create_backup()
        print()
        
        # Execute reorganization
        print("[*] Starting reorganization...")
        reorg.reorganize(dry_run=False)
        print()
        
        # Update main README
        print("[*] Updating main README...")
        reorg.update_main_readme()
        print()
        
        # Save log
        reorg.save_migration_log()
        print()
        
        print("=" * 70)
        print("✅ REORGANIZATION COMPLETE")
        print("=" * 70)
        print()
        print(f"Backup saved at: {backup_path}")
        print("If you need to rollback, run:")
        print(f'  rm -rf "{networking_path}" && mv "{backup_path}" "{networking_path}"')
        print()
        print("Review the new structure and test all links before deleting backup!")
