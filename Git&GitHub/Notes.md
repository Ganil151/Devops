### GIT OPERATION & COMMANDS


> Set Up Repo 
- Git init
- Git Clone
- Git Config
- Git Alias: are used to create shorter commands that map to longer commands

#### Save Changes
- Git Add : to update and save a snapshot
- Git Commit : git commit -m "<message>"
- Git Diff : finds the changes between the files or branch
- Git Stash : if you are switching from branch to branch without committing changes, it stashes the changes until you commit then
git stash pop : to add the changes

> Inspect Repo
- Git status : command displays the state of the working directory

- Git Log : all the log's and by whom:
you can also use git --oneline for a shorter version 

- Git Reflog : 
is a reference log file that stores a chronological list of all changes made to the HEAD pointer in your Git repository

- Git Tag : is used to capture(tag) a point in history that is used for a marked version release

- Git Blame : function displays of author metadata attached to specific committed lines in a file.

##### Git Configure file
- git config --global user.name "user_name"
- git config --global user.email "user_email"
- set the code editor: 
git config --global core.editor "code --wait"



> Pull & Push and Remote
- git remote -v: to see if you have a remote running

- git remote add <url>

- git remote add origin https://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@github.com/Ganil151/DevOps.git

- git remote rename <the oldname> <the newname>
  
- git remote remove name

- git pull : git pull origin main 

- git -u push origin main : to push the files on github repositories 

> Parallel Development

- Git Branch : 
git branch <branch_name>, to create a new branch
To commit the branch: git checkout <branch_name> then: git commit -m "message"
to find which branch; git branch -vv
git branch -d <branch_name> : to delete the branch
git branch -M main : to change the name of the branch 

- Git Switch:
does the same as git branch but you can use
git switch -c <branch_name> (create a branch and move there)

- Git Merge: is one of two utilities that specializes in integrating changes from one branch onto another.
1. checkout to the main branch
2. then merge with the main branch 

- git checkout: to switch branch; 
git checkout -b <branch_name> (create a branch and move it)
use git checkout HEAD~(2):the number you like to head back too.

- Git Rebase:
is one of two utilities that specializes in integrating changes from one branch onto another, it also **Rewrite the History** do not use on main or master branch
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".


> To add files or folders to existing repository:
- git merge --allow-unrelated-histories <branch-name>
- git pull origin <branch-name> --allow-unrelated-histories
- git push origin main


> Side Notes
 
- git config --global init.defaultBranch <name> : To configure the initial branch name to use in all of your new repositories, which will suppress this warning, call:


> Archive your Repository
- git archive master --format=zip - output=../name_of_file.zip

> Bundle your Repository
- git bundle create ../repo.bundler master

### Introduction to SSH Keys

> SSH: key is an access credential for the secure shell network protocol. This authenticated and encrypted secure network protocol is used for remote communication between machines on an unsecured open network. SSH is used for remote file transfer, network management, and remote operating system access.

- How to create SSH KEY?
create key: ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
after filling in all;
add the new SSH key to the ssh-agent: ssh-add -K /Users/you/.ssh/id_rsa

















#### Fix Errors while pull & push 
Create Personal Access Token on GitHub
From your GitHub account, go to Settings → Developer Settings → Personal Access Token → Tokens (classic) → Generate New Token (Give your password) → Fill up the form → click Generate token → Copy the generated Token:  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

for Linux: git clone https://<tokenhere>@github.com/<user>/<repo>.git







>for DevOps Tutorials:
[Links:](https://youtu.be/a2uh2hA4V3A)
>for Git&GitHub Tutorials:
[Links:](https://youtu.be/zTjRZNkhiEU)
[MoreBooks](https://github.com/jidibinlin/Free-DevOps-Books-1/tree/master/book)


https://youtu.be/zTjRZNkhiEU?t=8164
