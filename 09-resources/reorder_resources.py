#!/usr/bin/env python3
import sys
from pathlib import Path
try:
    from rich.console import Console
    from rich.table import Table
    from rich.prompt import Prompt
except ImportError:
    print("Please install rich: pip install rich")
    sys.exit(1)

console = Console()
TARGET_DIR = Path("/home/gsmash/Documents/Devops/09-resources")

def get_clean_name(name):
    """Extracts the base name without numeric prefix."""
    parts = name.split('-', 1)
    if len(parts) > 1 and parts[0].isdigit():
        return parts[1]
    parts = name.split('_', 1)
    if len(parts) > 1 and parts[0].isdigit():
        return parts[1]
    return name

def main():
    if not TARGET_DIR.exists():
        console.print(f"[red]Directory not found: {TARGET_DIR}[/red]")
        sys.exit(1)

    # Get directories and sort them by current name
    dirs = sorted([d for d in TARGET_DIR.iterdir() if d.is_dir() and not d.name.startswith('.')])
    
    if not dirs:
        console.print("[yellow]No subdirectories found.[/yellow]")
        sys.exit(0)

    # Display current state
    table = Table(title=f"Directories in {TARGET_DIR.name}")
    table.add_column("ID", style="cyan", justify="right")
    table.add_column("Current Name", style="green")
    
    dir_map = {}
    for i, d in enumerate(dirs):
        table.add_row(str(i), d.name)
        dir_map[i] = d
        
    console.print(table)
    
    console.print("\n[bold]Enter the sequence of IDs in the desired order (space separated).[/bold]")
    console.print("Example: [cyan]2 0 1[/cyan] will reorder them as 01-..., 02-..., 03-...")
    
    user_input = Prompt.ask("Sequence")
    
    try:
        indices = [int(x) for x in user_input.split()]
    except ValueError:
        console.print("[red]Invalid input. Numbers only.[/red]")
        sys.exit(1)
        
    if len(indices) != len(dirs):
        console.print(f"[red]You selected {len(indices)} items, but there are {len(dirs)} directories.[/red]")
        sys.exit(1)
        
    # Preview Changes
    preview_table = Table(title="Preview Changes")
    preview_table.add_column("Old Name", style="red")
    preview_table.add_column("New Name", style="green")
    
    changes = []
    for order, idx in enumerate(indices):
        if idx not in dir_map:
            console.print(f"[red]Invalid ID: {idx}[/red]")
            sys.exit(1)
            
        original = dir_map[idx]
        clean = get_clean_name(original.name)
        new_name = f"{order+1:02d}-{clean}"
        new_path = TARGET_DIR / new_name
        
        preview_table.add_row(original.name, new_name)
        changes.append((original, new_path))
        
    console.print(preview_table)
    
    if Prompt.ask("Apply changes?", choices=["y", "n"], default="n") == "y":
        # Rename logic with temp names to avoid collisions
        temp_map = []
        with console.status("Renaming..."):
            # 1. Rename to temp
            for original, final in changes:
                temp_name = original.parent / f"__temp_{original.name}"
                original.rename(temp_name)
                temp_map.append((temp_name, final))
                
            # 2. Rename to final
            for temp, final in temp_map:
                temp.rename(final)
                
        console.print("[bold green]Done![/bold green]")
    else:
        console.print("[yellow]Cancelled.[/yellow]")

if __name__ == "__main__":
    main()
