### A step-by-step guide on writing your first pre-commit hook

![](https://miro.medium.com/v2/resize:fit:833/1*HzAJEG9sMVOzpvAWMUzNTw.png)
pre-commit run results, including our Hamilton hook!
Most software is developed using the `git` version control system to update and distribute code. One challenge of writing code collaboratively is ensuring specific standards while each contributor has their style and opinion about what constitutes clean code.
**pre-commit hooks** are scripts or commands to execute automatically before committing code changes. They can enforce styling rules and catch errors before they’re committed and further distributed. Notable hooks include checking files for syntax errors, sorting imports, and normalizing quotation marks. They are an essential tool for any project, especially open-source ones with many contributors.
### Why create custom pre-commit hooks?
I wanted to create pre-commit hooks to validate dataflow definitions for the Python library [Hamilton](https://github.com/dagworks-inc/hamilton), but I found most online resources scattered and limited to basic use.

In this post, you’ll find:
1. How to start using pre-commit hooks in your project
2. A step-by-step tutorial to develop custom pre-commit hooks
To ground the discussion, I’ll go through this GitHub repository containing the pre-commit hooks I developed for Hamilton.
### Start using pre-commit hooks
Hooks are a mechanism built directly into the `git` version control system. You can find your project’s hooks under the `.git/hooks` directory (it might be hidden by default). Although they are colloquially called “pre-commit hooks”, git hooks cover the whole git lifecycle. For instance, you can have hooks trigger just after a commit or before a push. Also, hooks can be written in any programming language. Notably, the Ruff library reimplemented many Python-based hooks in Rust for performance improvement.

Compared to software testing, which focuses on code behavior, you can think of hooks as lightweight checks you would do on each file save. While you can expect tests to change and evolve with your codebase, your code-writing guidelines and pre-commit hooks will likely be constant.
### Project setup
Let’s pretend we’re starting a new Python project (or using an existing one) in the directory `/my-project`. The preferred way of working with pre-commit hooks is through the pre-commit Python library. We can set it up with the following steps:
1. Create a git repository for your project with `git init`
2. Install the pre-commit library with `pip install pre-commit`
3. Add a `.pre-commit-config.yaml` to your repository. Here’s an example:

```yaml
# .pre-commit-config.yaml  
repos:  
    # repository with hook definitions  
-   repo: https://github.com/pre-commit/pre-commit-hooks  
    rev: v2.3.0  # release version of the repo  
    hooks:  # list of hooks from the repo to include in this project  
    -   id: end-of-file-fixer  
    -   id: trailing-whitespace  
    -   id: check-yaml  
        args: ['--unsafe']  # add arguments to `check-yaml`  
  
    # download another repository with hooks  
-   repo: https://github.com/psf/black  
    rev: 22.10.0  
    hooks:  
    -   id: black
```
4. Install the hooks with `pre-commit install`. It will read instructions from `.pre-commit-config.yaml` and install hooks locally under `.git/hooks/pre-commit`

5. Make a commit or manually run hooks with `pre-commit run --all-files` to trigger the hooks
### Create a custom pre-commit hook
Community-maintained hooks provide flexibility and can be tailored to meet your preferred coding guidelines. They should meet your needs 98% of the time. However, off-the-shelf solutions don’t know about the specific tools you’re using or your team’s internal conventions. For example, you might want to validate internal configurations or enforce a directory structure for your projects.

In our case, we want to create a hook to validate the Python code for their Hamilton dataflow definition. Our hook script will leverage the `[hamilton](https://blog.dagworks.io/p/a-command-line-tool-to-improve-your)` CLI tool to conduct the validation, leaving us with a simple code example to follow.
#### 1. Setting up your pre-commit hook repository
As introduced in the **Project setup** section, pre-commit hooks need to exist in a public repository to allow projects to reference them in `.pre-commit-config.yaml` and install them locally with `pre-commit install`.

Previously, we were in our project directory `/my-project` where we defined a `.pre-commit-config.yaml` and installed hooks. Now, we’ll create a `/my-hooks` directory where we’ll define our custom hooks. You can refer to our `[hamilton-pre-commit](https://github.com/DAGWorks-Inc/hamilton-pre-commit)` [repository](https://github.com/DAGWorks-Inc/hamilton-pre-commit) to view the general structure.

![](https://miro.medium.com/v2/resize:fit:833/1*lCGsPyWfLUBJILyJTUujPg.png)
#### 2. Writing the hook’s logic
Under `hooks/`, we have a file `__init__.py` to [make the directory a discoverable Python module](https://docs.python.org/3/tutorial/modules.html) and our script `cli_command.py`. It contains a single function `main()`, which reads a list of `hamilton` CLI commands from `sys.argv`. Then, it executes them one by one as a subprocess wrapped in a `try/except` clause.
```python
# hooks/cli_command.py  

import sys  
import json  
import subprocess  
  
PASS = 0  
FAIL = 1  
  
def main() -> int:  
    """Execute a list of commands using the Hamilton CLI"""      
    commands = sys.argv[1:]  
  
    if len(commands) == 0:  
        return PASS  
          
    exit_code = PASS  
    for command in commands:  
        try:  
            args = command.split(" ")  
            # insert `--json-out` for proper stdout parsing  
            args.insert(1, "--json-out")  
            result = subprocess.run(args, stdout=subprocess.PIPE, text=True)  
            response = json.loads(result.stdout)  
              
            if response["success"] is False:  
                raise ValueError  
                  
        except Exception:  
            exit_code |= FAIL  
  
    return exit_code  
  
if __name__ == "__main__":  
    raise SystemExit(main())
```
At the beginning, we set `exit_code = PASS`, but any exception or unsuccessful commands will set `exit_code = FAIL`. The `main()` function returns the exit code to the `SystemExit` exception. For the pre-commit hook to succeed, we need to return `PASS` after all commands succeeded. It might be counterintuitive to have `PASS=0` and `FAIL=1` but these values refer to the standard system’s exit code. We used Python for convenience, but this simple logic could be in a lighter scripting language like Bash. 
#### 3. Defining the hook entry point
Now, your hooks repository (`/my-hooks`) must include a `.pre-commit-hooks.yaml` file that specifies the available hooks and how to execute them once installed.
```yaml
- id: cli-command  
  name: Execute `hamilton` CLI commands  
  description: This hook executes a command using the `hamilton` CLI.  
  entry: cli-command  
  language: python  
  types: [python]  
  stages: [pre-commit, pre-merge-commit, manual]  
  pass_filenames: false
```
In our case, we set `id: cli-command` and `entry: cli-command`, add some metadata, and specify the programming language as Python. Importantly, the `files` attribute wasn’t set to have our hook run once per commit. In your case, you might want to set `files: "*.py"` to run your hook on each edited Python file for example learn about available options

So far, we created a Python script under `hooks/cli_command.py` and added to `.pre-commit-hooks.yaml` a hook with the entry point `cli-command`. However, you need to link the two explicitly in your Python project file `pyproject.toml`.

```yaml
[project.scripts]  
cli-command = "hooks.cli_command:main"
```

This line reads “the entry point `cli-command` refers to the function `main` in `hooks.cli_command`”.

> see [this example](https://github.com/pre-commit/pre-commit-hooks/blob/main/setup.cfg) if you’re using `setup.cfg`for your Python project

#### 4. Testing your hook locally
First, you should validate your hook’s logic with unit tests. However, we won’t dive into testing since it deserves its own post. Our `hamilton-pre-commit` repository currently doesn’t have tests since the underlying CLI is tested under the main Hamilton repository. You can visit the [officially maintained pre-commit hooks](https://github.com/pre-commit/pre-commit-hooks/tree/main/tests) for test examples.

Second, you should verify that the `.pre-commit-hooks.yaml` and entry points are properly configured by trying your pre-commit hook locally. Ideally, you’d want to avoid adding a commit to trigger the hook each time you want to test changes. The pre-commit library provides utilities to facilitate this process, but it requires a few manual steps detailed in [pre-commit GitHub issues](https://github.com/pre-commit/pre-commit/issues/850).

1. Go to your directory `/my-project` where you’d like to test your hook.
2. Execute `pre-commit try-repo ../LOCAL/PATH/TO/my-hooks` then, you should see a local initialization message.

![](https://miro.medium.com/v2/resize:fit:833/1*O--PJYp8FHrBPw86iPITLA.png)

One limitation is that you can’t directly pass `args` to your hook via this command.

3. Copy the configuration found under `Using config:` to a local file and add the `args` section. We created `.local-pre-commit-config.yaml` but you can use any name.

```yaml
# my-project/.local-pre-commit-config.yaml  
repos:  
  - repo: ../../dagworks/hamilton-pre-commit  
    rev: e4b77a499ba0ff3446a86ebbe4c2cbca82eb54f8  
    hooks:  
    - id: cli-command  
      args: [  
        hamilton build my_func2.py  
      ]
```
4. Use your local hook via `pre-commit run --config .local-pre-commit-config.yaml --all-files`. The `--all-files` flag will apply the hook to all files in your repository instead of those currently staged.

![](https://miro.medium.com/v2/resize:fit:833/1*Apr36ZUN84RtL2xuwuOgMw.png)

> When adding a test, always start by making it fail. You wouldn’t want to add a test that always succeeds `:^)`
#### 5. Publishing your pre-commit hook
You’re almost there! You have a working hook script that’s tested and packaged in a git repository. Now, you just need to make it available online. We will show the steps for GitHub-hosted projects, but your pre-commit hook can live anywhere accessible via `git clone`.

1. From your GitHub repository, go to the **Releases** section
![[1_Du4r4SjxjOGwP58rMOJrgg.webp]]
Main page of a GitHub repository.

2. Click **Draft a new release**
![[1_3eNjkCTPWsmqVQWFpO2FOw.webp]]
**Releases** section of a GitHub repository

3. On the new release page, you need to add a version tag, a title, and a description. If it’s your first release, I suggest setting the tag as `v0.1.0` to [follow semantic versioning](https://semver.org/), as recommended by GitHub.

When you’re making changes and want to distribute experimental versions, you can set your version as `v0.1.1-rc` (for “release candidate”) and mark it as a pre-release using the checkbox.
![](https://miro.medium.com/v2/resize:fit:833/1*8QW0tsnmJ2NJQhCBlrEFBg.png)

**New release** form on GitHub.

The `rev` value in your `.pre-commit-config.yaml` file will need to match the **version tag** you set.
```yaml
repos:  
- repo: https://github.com/DAGWorks-Inc/hamilton-pre-commit  
  rev: v0.1.3rc  
  hooks:  
    - id: cli-command  
      # ...
```

Congrats! You made it through this post! You are now able to use pre-commit hooks to improve code quality in your projects. Equipped with an understanding of their internals, you can start writing your own hooks!

Don’t forget to take a look at the many hooks maintained by the community before reinventing the wheel: [https://pre-commit.com/hooks.html](https://pre-commit.com/hooks.html)