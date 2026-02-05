# 🎯 Hands-On Challenges: Vim Crash Course

## Challenge 1: Vim Mode Mastery (Beginner)
**Objective**: Practice switching between Vim modes confidently.

**Tasks**:
1. Open Vim: `vim practice.txt`
2. Press `i` to enter INSERT mode
3. Type: "Learning Vim is essential for DevOps"
4. Press `Esc` to return to NORMAL mode
5. Press `v` to enter VISUAL mode
6. Use arrow keys to highlight text
7. Press `Esc` to return to NORMAL mode
8. Type `:` to enter COMMAND mode
9. Type `wq` and press Enter to save and quit

**Practice Pattern**: `i` → type → `Esc` → `:wq`

---

## Challenge 2: Navigation Without Arrow Keys (Intermediate)
**Objective**: Master Vim's hjkl navigation.

**Setup**:
```bash
cat > navigate.txt << 'EOF'
Line 1: Practice navigation here
Line 2: Use h j k l keys
Line 3: Not arrow keys!
Line 4: This builds muscle memory
Line 5: DevOps pros use Vim shortcuts
EOF
vim navigate.txt
```

**Tasks** (in NORMAL mode):
1. Move right 10 characters: `10l`
2. Move down 2 lines: `2j`
3. Move up 1 line: `k`
4. Move left 5 characters: `5h`
5. Jump to start of line: `0`
6. Jump to end of line: `$`
7. Jump to first line: `gg`
8. Jump to last line: `G`
9. Jump to line 3: `3G` or `:3`

**Goal**: Navigate without touching arrow keys!

---

## Challenge 3: Editing Commands (Practical)
**Objective**: Perform common editing operations.

**Setup**:
Create a file with errors:
```bash
cat > edit-practice.txt << 'EOF'
This lien has a typo
This line is fine
Deleet this word
This line needs capitaliztion
EOF
vim edit-practice.txt
```

**Tasks** (Fix the errors):
1. Fix "lien" → "line": Position cursor on 'l', press `cw`, type "line", press `Esc`
2. Delete "Deleet": Position cursor on 'D', press `dw`
3. Replace entire word: Position on "capitaliztion", press `ciw`, type "capitalization", press `Esc`
4. Delete entire line: Press `dd`
5. Undo last change: Press `u`
6. Redo: Press `Ctrl-r`

**Common Commands**:
- `x`: Delete character
- `dw`: Delete word
- `dd`: Delete line
- `yy`: Yank (copy) line
- `p`: Paste

---

## Challenge 4: Search and Replace (Advanced)
**Objective**: Master find/replace operations.

**Setup**:
```bash
cat > replace-demo.txt << 'EOF'
database_host=localhost
database_port=5432
database_user=admin
database_password=secret
database_name=myapp
EOF
vim replace-demo.txt
```

**Tasks**:
1. Find "database": In NORMAL mode, type `/database` and press Enter
2. Next occurrence: Press `n`
3. Previous occurrence: Press `N`
4. Replace first "database" with "db": `:%s/database/db/`
5. Replace ALL occurrences: `:%s/database/db/g`
6. Replace with confirmation: `:%s/localhost/prod-server/gc`
7. Replace in lines 1-3 only: `:1,3s/database/db/g`

**Power Tip**: `:%s/old/new/gc` prompts for each replacement!

---

## Challenge 5: Visual Block Mode (Power User)
**Objective**: Edit multiple lines simultaneously.

**Setup**:
```bash
cat > block-edit.txt << 'EOF'
server1.example.com
server2.example.com
server3.example.com
server4.example.com
server5.example.com
EOF
vim block-edit.txt
```

**Tasks**:
1. Position cursor on first 's' in "server1"
2. Enter VISUAL BLOCK mode: `Ctrl-v`
3. Move down 4 lines: `4j`
4. Insert at start: `I`, type "prod-", press `Esc`
5. Result: All lines now have "prod-" prefix

**Challenge**: Comment out lines 2-4 by adding "#" at the start.

---

## Challenge 6: Vim Configuration (Essential)
**Objective**: Create a professional `.vimrc` file.

**Tasks**:
Create `~/.vimrc` with these settings:
```vim
" Basic Settings
set number              " Show line numbers
set relativenumber      " Relative line numbers
set tabstop=4          " Tab width
set shiftwidth=4       " Indent width
set expandtab          " Use spaces instead of tabs
set autoindent         " Auto-indent new lines

" Search Settings
set ignorecase         " Case-insensitive search
set smartcase          " Case-sensitive if uppercase present
set hlsearch           " Highlight search results
set incsearch          " Incremental search

" UI Settings
syntax on              " Syntax highlighting
set showcmd            " Show command in bottom bar
set cursorline         " Highlight current line
set wildmenu           " Visual autocomplete for command menu

" DevOps-specific
set paste              " Better paste behavior
set mouse=a            " Enable mouse support

" Key mappings
nnoremap <C-s> :w<CR>  " Ctrl-S to save
inoremap jk <Esc>      " jk to exit insert mode
```

**Test**: Open any file and verify settings work!

---

## Challenge 7: Emergency Vim Recovery (Critical)
**Objective**: Handle common Vim emergencies.

**Scenarios**:
1. **Stuck in INSERT mode**: Press `Esc`
2. **Can't save changes**: Use `:w!` (force write) or `:w !sudo tee %`
3. **Made mistakes**: Use `u` to undo, `:e!` to reload file
4. **Want to quit without saving**: `:q!`
5. **File is read-only**: `:w new-filename.txt`
6. **Accidentally opened huge file**: `:q!` immediately

**Practice Drill**:
```bash
vim test.txt
# Try to break Vim (safely!)
# Then recover using emergency commands
```

---

## Challenge 8: Production Config Editing (Real-World)
**Objective**: Edit configuration files like a pro.

**Scenario**: Update nginx configuration on production server.

**Tasks**:
```bash
# Create sample nginx config
cat > nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}
EOF

vim nginx.conf
```

**Edits to make**:
1. Change port from 80 to 443
2. Change server_name from localhost to your domain
3. Add SSL configuration
4. Save and validate: `:w | !nginx -t`

**Pro Workflow**:
1. Make backup first: `:!cp % %.bak`
2. Edit file
3. Test config: `:!nginx -t`
4. If valid: `:wq`
5. If invalid: `:e!` (reload original)

---

## Challenge 9: Vim Macros (Expert)
**Objective**: Automate repetitive editing tasks.

**Setup**:
```bash
cat > macro-practice.txt << 'EOF'
task: deploy application
task: run tests  
task: backup database
task: restart services
task: check logs
EOF
vim macro-practice.txt
```

**Tasks** - Record macro to format tasks:
1. Position cursor on first line
2. Start recording to register 'a': `qa`
3. Perform edits:
   - `I` - Insert at beginning
   - Type "[ ]"
   - `Esc` - Return to normal
   - `A` - Append at end
   - Type " (pending)"
   - `Esc` - Return to normal
   - `j` - Move to next line
4. Stop recording: `q`
5. Play macro: `@a`
6. Repeat 3 times: `3@a`

**Result**: All tasks formatted as "[ ] task: ... (pending)"

---

## Challenge 10: The Vim Speed Challenge (Competition)
**Objective**: Complete editing tasks at professional speed.

**Challenge**: Complete these tasks in under 2 minutes:

**Setup**:
```bash
cat > speed-test.txt << 'EOF'
Line 1 needs editing
Line 2 is perfect
Line 3 delete this line
Line 4 also needs work
Line 5 is okay
Line 6 change this text
Line 7 final line
EOF
vim speed-test.txt
```

**Tasks** (timed):
1. Delete line 3: `3G` + `dd`
2. Change "Line 1" to "Modified 1": `1G` + `cw` + type + `Esc`
3. Copy line 2 and paste after line 7: `2G` + `yy` + `G` + `p`
4. Replace all "Line" with "Task": `:%s/Line/Task/g`
5. Add "DONE" at end of each line: `:%s/$/ DONE/g`
6. Save and quit: `:wq`

**Pro Time**: Under 60 seconds!

---

## Verification Checklist
- [ ] Comfortable switching between modes (Normal, Insert, Visual, Command)
- [ ] Can navigate using hjkl without arrow keys
- [ ] Know basic editing commands (d, y, p, c, x)
- [ ] Can perform search and replace operations
- [ ] Understand Visual Block mode for multi-line edits
- [ ] Created a personalized .vimrc
- [ ] Can handle emergency situations
- [ ] Know how to record and play macros

## Essential Vim Commands Reference

### Mode Switching
| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `a` | Append after cursor |
| `o` | Open new line below |
| `v` | Visual mode
|
| `Ctrl-v` | Visual Block mode |
| `:` | Command mode |
| `Esc` | Return to Normal mode |

### Navigation
| Key | Action |
|-----|--------|
| `h/j/k/l` | Left/Down/Up/Right |
| `w/b` | Next/Previous word |
| `gg/G` | Start/End of file |
| `0/$` | Start/End of line |
| `%` | Jump to matching bracket |

### Editing
| Key | Action |
|-----|--------|
| `x` | Delete character |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste |
| `u` | Undo |
| `Ctrl-r` | Redo |

### Search & Replace
| Command | Action |
|---------|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n/N` | Next/Previous match |
| `:%s/old/new/g` | Replace all |
| `:%s/old/new/gc` | Replace with confirm |

## Real-World Application
**DevOps Scenario**: Emergency config fix on production
```bash
# SSH to production server
ssh production-server

# Edit config file
sudo vim /etc/nginx/sites-available/app.conf

# Make changes:
# 1. Find issue: /error
# 2. Fix line
# 3. Save: :w !sudo tee %
# 4. Validate: :!nginx -t
# 5. Quit: :q

# Restart service if valid
sudo systemctl reload nginx
```

## Why Vim Matters in DevOps
✅ **Universal**: Available on every Linux server  
✅ **Efficient**: Edit files faster than any GUI  
✅ **Reliable**: Works over slow SSH connections  
✅ **Powerful**: Complex edits with simple key sequences  
✅ **Professional**: Expected skill for senior roles  

## Common Mistakes to Avoid
❌ Using arrow keys instead of hjkl  
❌ Not using Visual Block mode for multi-line edits  
❌ Forgetting to save (`:w`)  
❌ Using `:x` instead of `:wq` (`:x` saves if modified)  
❌ Not learning macros for repetitive tasks  

## Next Steps
Complete these challenges, then proceed to **[File Permissions](CHALLENGES.md)** →

**💡 Practice Tip**: Spend 10 minutes daily in Vim. Configure your terminal to use Vim for git commits: `git config --global core.editor vim`
