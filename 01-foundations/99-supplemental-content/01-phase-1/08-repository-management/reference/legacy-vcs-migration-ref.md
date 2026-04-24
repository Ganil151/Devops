# Legacy VCS Migration Guide (SVN & Mercurial)

**Doc Version:** 1.0.0
**Role:** Senior DevOps Engineer
**Scope:** Migration Strategy to Git

---

## 1. The Paradigm Shift

### Centralized (CVCS) vs. Distributed (DVCS)

**Subversion (SVN) / CVCS:**
- **Model:** Single central server.
- **Workflow:** `checkout` -> `edit` -> `commit` (directly to server).
- **Pro:** Simple locking of files (binary assets).
- **Con:** No offline work; Single Point of Failure.

**Git / DVCS:**
- **Model:** Every developer has a full backup of the repo.
- **Workflow:** `clone` -> `commit` (local) -> `push` (server).
- **Pro:** Distributed backup, powerful branching, offline support.
- **Con:** Higher learning curve.

---

## 2. Migration Strategy: git-svn

The `git svn` tool allows bidirectional operation between a Subversion repository and Git.

### Step 1: Clone the SVN Repository
Do not just copy files. You want to preserve history.

```bash
# Standard layout assumes /trunk, /branches, and /tags
git svn clone -s https://svn.example.com/project/ --prefix=origin/
```

- `-s`: Tells Git that the SVN repo follows standard layout.
- `--prefix`: Prefixes remote branches so they look like `origin/master`.

### Step 2: Convert Authors
SVN uses usernames (e.g., `jsmith`). Git uses Name + Email.
Create a mapping file `authors.txt`:
```text
jsmith = John Smith <jsmith@company.com>
```

Run clone with author mapping:
```bash
git svn clone -s https://svn.example.com/project/ --authors-file=authors.txt
```

### Step 3: Clean up Branches and Tags
SVN tags are just directories. Git tags are objects. You often need scripts to convert SVN tag branches into real Git tags.

```bash
# Example logic to convert SVN tags
git for-each-ref --format='%(refname)' refs/remotes/origin/tags/* | while read tag_ref; do
    tag_name=${tag_ref#refs/remotes/origin/tags/}
    git tag $tag_name $tag_ref
    git branch -D -r origin/tags/$tag_name
done
```

### Step 4: Push to new Remote
```bash
git remote add origin https://github.com/company/new-repo.git
git push -u origin --all
git push --tags
```

---

## 3. Mercurial (Hg) Migration

Mercurial is also distributed, so migration is easier than SVN.
Tool: `fast-export` or `hg-git`.

```bash
# Using fast-export
git init new-repo
cd new-repo
hg-fast-export -r /path/to/local/hg-repo
git checkout HEAD
```
