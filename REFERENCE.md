# 🚀 Root REFERENCE: The DevOps Master Logic
*Last Updated: 2026-02-05 01:38 - Automated Sync*

This file serves as the core entry point for the high-level logic across all tiers. Use this to quickly navigate frequent commands, architecture patterns, and the "Trinity" orchestration suite.

---

## 🛠️ The "Trinity" Orchestration Suite
These master scripts are designed for cross-platform system management.

| Goal | Language | Location | Primary Command |
| :--- | :--- | :--- | :--- |
| **Health Audit** | Python | [./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/](./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/) | `python resource_monitor.py` |
| **Hybrid Check** | PowerShell | [./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/](./2-Intermediate/01-Phase-1/03-Runbooks-Procedures/scripts/) | `.\Invoke-HybridHealthCheck.ps1` |
| **Node Harden** | Bash | [./2-Intermediate/01-Phase-1/02-Linux/scripts/](./2-Intermediate/01-Phase-1/02-Linux/scripts/) | `sudo ./harden-linux-node.sh` |
| **K8s Audit** | PowerShell | [./3-Advanced/01-Phase-1/04-Container-Orchestration/scripts/](./3-Advanced/01-Phase-1/04-Container-Orchestration/scripts/) | `.\Invoke-K8sClusterAudit.ps1` |
| **Cloud Artifact** | PowerShell | [./2-Intermediate/02-Phase-2/01-Infrastructure-Automation/scripts/](./2-Intermediate/02-Phase-2/01-Infrastructure-Automation/scripts/) | `.\Sync-S3CloudBackup.ps1` |

---

## 🗺️ Navigation Index

- 🌱 **[Beginner Fundamentals](./1-Beginner/REFERENCE.md)**: Linux Basics & Linux SSH, Windows Basics, Networking Foundations.
- ⚙️ **[Intermediate Automation](./2-Intermediate/REFERENCE.md)**: Foundations (Weeks 1-4), Core Skills (Weeks 5-10), Advanced (Weeks 11-16).
- 🏛️ **[Advanced Enterprise](./3-Advanced/REFERENCE.md)**: General Reference.
- 👔 **[Professional Career](./4-Professional-Development/REFERENCE.md)**: General Reference.
- 📦 **[Boilerplates](./5-Boilerplates/REFERENCE.md)**: General Reference.
- 📝 **[Quizzes](./6-Quizzes/REFERENCE.md)**: General Reference.


---

## 📊 Core Command Matrix (Essential DevOps)

### 📦 Infrastructure as Code (Terraform)
```bash
terraform init          # Initialize workspace
terraform plan          # Preview infrastructure changes
terraform apply         # Deploy to provider (AWS/Azure/GCP)
```

### 🐋 Containers & Orchestration
```bash
docker build -t app:1.0 .  # Build local image
docker-compose up -d        # Deploy local stack
kubectl get pods -A         # View all running pods
```

### 🐍 Automation Logic (Python)
```bash
python -m venv .venv        # Create isolation
pip install -r reqs.txt     # Install dependencies
python script.py            # Execute automation
```

---

## 🔍 Universal Search Index

<details>
<summary>Click to expand full file index (501 files)</summary>

| Resource | Category | Path |
| :--- | :--- | :--- |
| Activate | Other | `.lessenv/bin/Activate.ps1` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/__init__.py` |
|   Main   | Other | `.lessenv/lib/python3.14/site-packages/pip/__main__.py` |
|   Pip Runner   | Other | `.lessenv/lib/python3.14/site-packages/pip/__pip-runner__.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/__init__.py` |
| Build Env | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/build_env.py` |
| Cache | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cache.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/__init__.py` |
| Autocompletion | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/autocompletion.py` |
| Base Command | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/base_command.py` |
| Cmdoptions | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/cmdoptions.py` |
| Command Context | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/command_context.py` |
| Index Command | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/index_command.py` |
| Main | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/main.py` |
| Main Parser | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/main_parser.py` |
| Parser | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/parser.py` |
| Progress Bars | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/progress_bars.py` |
| Req Command | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/req_command.py` |
| Spinners | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/spinners.py` |
| Status Codes | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/cli/status_codes.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/__init__.py` |
| Cache | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/cache.py` |
| Check | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/check.py` |
| Completion | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/completion.py` |
| Configuration | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/configuration.py` |
| Debug | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/debug.py` |
| Download | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/download.py` |
| Freeze | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/freeze.py` |
| Hash | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/hash.py` |
| Help | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/help.py` |
| Index | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/index.py` |
| Inspect | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/inspect.py` |
| Install | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/install.py` |
| List | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/list.py` |
| Lock | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/lock.py` |
| Search | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/search.py` |
| Show | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/show.py` |
| Uninstall | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/uninstall.py` |
| Wheel | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/commands/wheel.py` |
| Configuration | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/configuration.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/distributions/__init__.py` |
| Base | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/distributions/base.py` |
| Installed | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/distributions/installed.py` |
| Sdist | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/distributions/sdist.py` |
| Wheel | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/distributions/wheel.py` |
| Exceptions | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/exceptions.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/index/__init__.py` |
| Collector | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/index/collector.py` |
| Package Finder | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/index/package_finder.py` |
| Sources | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/index/sources.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/locations/__init__.py` |
|  Distutils | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/locations/_distutils.py` |
|  Sysconfig | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/locations/_sysconfig.py` |
| Base | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/locations/base.py` |
| Main | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/main.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/metadata/__init__.py` |
|  Json | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/metadata/_json.py` |
| Base | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/metadata/base.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/metadata/importlib/__init__.py` |
|  Compat | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/metadata/importlib/_compat.py` |
|  Dists | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/metadata/importlib/_dists.py` |
|  Envs | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/metadata/importlib/_envs.py` |
| Pkg Resources | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/metadata/pkg_resources.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/__init__.py` |
| Candidate | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/candidate.py` |
| Direct Url | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/direct_url.py` |
| Format Control | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/format_control.py` |
| Index | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/index.py` |
| Installation Report | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/installation_report.py` |
| Link | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/link.py` |
| Release Control | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/release_control.py` |
| Scheme | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/scheme.py` |
| Search Scope | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/search_scope.py` |
| Selection Prefs | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/selection_prefs.py` |
| Target Python | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/target_python.py` |
| Wheel | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/models/wheel.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/network/__init__.py` |
| Auth | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/network/auth.py` |
| Cache | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/network/cache.py` |
| Download | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/network/download.py` |
| Lazy Wheel | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/network/lazy_wheel.py` |
| Session | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/network/session.py` |
| Utils | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/network/utils.py` |
| Xmlrpc | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/network/xmlrpc.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/__init__.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/build/__init__.py` |
| Build Tracker | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/build/build_tracker.py` |
| Metadata | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/build/metadata.py` |
| Metadata Editable | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/build/metadata_editable.py` |
| Wheel | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/build/wheel.py` |
| Wheel Editable | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/build/wheel_editable.py` |
| Check | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/check.py` |
| Freeze | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/freeze.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/install/__init__.py` |
| Wheel | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/install/wheel.py` |
| Prepare | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/operations/prepare.py` |
| Pyproject | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/pyproject.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/req/__init__.py` |
| Constructors | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/req/constructors.py` |
| Pep723 | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/req/pep723.py` |
| Req Dependency Group | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/req/req_dependency_group.py` |
| Req File | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/req/req_file.py` |
| Req Install | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/req/req_install.py` |
| Req Set | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/req/req_set.py` |
| Req Uninstall | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/req/req_uninstall.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/__init__.py` |
| Base | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/base.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/legacy/__init__.py` |
| Resolver | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/legacy/resolver.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/__init__.py` |
| Base | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/base.py` |
| Candidates | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/candidates.py` |
| Factory | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/factory.py` |
| Found Candidates | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/found_candidates.py` |
| Provider | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/provider.py` |
| Reporter | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/reporter.py` |
| Requirements | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/requirements.py` |
| Resolver | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/resolution/resolvelib/resolver.py` |
| Self Outdated Check | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/self_outdated_check.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/__init__.py` |
|  Jaraco Text | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/_jaraco_text.py` |
|  Log | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/_log.py` |
| Appdirs | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/appdirs.py` |
| Compat | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/compat.py` |
| Compatibility Tags | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/compatibility_tags.py` |
| Datetime | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/datetime.py` |
| Deprecation | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/deprecation.py` |
| Direct Url Helpers | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/direct_url_helpers.py` |
| Egg Link | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/egg_link.py` |
| Entrypoints | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/entrypoints.py` |
| Filesystem | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/filesystem.py` |
| Filetypes | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/filetypes.py` |
| Glibc | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/glibc.py` |
| Hashes | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/hashes.py` |
| Logging | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/logging.py` |
| Misc | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/misc.py` |
| Packaging | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/packaging.py` |
| Pylock | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/pylock.py` |
| Retry | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/retry.py` |
| Subprocess | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/subprocess.py` |
| Temp Dir | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/temp_dir.py` |
| Unpacking | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/unpacking.py` |
| Urls | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/urls.py` |
| Virtualenv | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/virtualenv.py` |
| Wheel | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/utils/wheel.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/vcs/__init__.py` |
| Bazaar | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/vcs/bazaar.py` |
| Git | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/vcs/git.py` |
| Mercurial | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/vcs/mercurial.py` |
| Subversion | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/vcs/subversion.py` |
| Versioncontrol | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/vcs/versioncontrol.py` |
| Wheel Builder | Other | `.lessenv/lib/python3.14/site-packages/pip/_internal/wheel_builder.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/__init__.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/__init__.py` |
|  Cmd | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/_cmd.py` |
| Adapter | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/adapter.py` |
| Cache | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/cache.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/caches/__init__.py` |
| File Cache | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/caches/file_cache.py` |
| Redis Cache | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/caches/redis_cache.py` |
| Controller | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/controller.py` |
| Filewrapper | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/filewrapper.py` |
| Heuristics | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/heuristics.py` |
| Serialize | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/serialize.py` |
| Wrapper | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/cachecontrol/wrapper.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/certifi/__init__.py` |
|   Main   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/certifi/__main__.py` |
| Core | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/certifi/core.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/dependency_groups/__init__.py` |
|   Main   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/dependency_groups/__main__.py` |
|  Implementation | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/dependency_groups/_implementation.py` |
|  Lint Dependency Groups | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/dependency_groups/_lint_dependency_groups.py` |
|  Pip Wrapper | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/dependency_groups/_pip_wrapper.py` |
|  Toml Compat | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/dependency_groups/_toml_compat.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/distlib/__init__.py` |
| Compat | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/distlib/compat.py` |
| Resources | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/distlib/resources.py` |
| Scripts | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/distlib/scripts.py` |
| Util | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/distlib/util.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/distro/__init__.py` |
|   Main   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/distro/__main__.py` |
| Distro | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/distro/distro.py` |
| License | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/LICENSE.md` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/__init__.py` |
| Codec | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/codec.py` |
| Compat | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/compat.py` |
| Core | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/core.py` |
| Idnadata | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/idnadata.py` |
| Intranges | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/intranges.py` |
| Package Data | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/package_data.py` |
| Uts46Data | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/idna/uts46data.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/msgpack/__init__.py` |
| Exceptions | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/msgpack/exceptions.py` |
| Ext | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/msgpack/ext.py` |
| Fallback | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/msgpack/fallback.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/__init__.py` |
|  Elffile | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/_elffile.py` |
|  Manylinux | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/_manylinux.py` |
|  Musllinux | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/_musllinux.py` |
|  Parser | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/_parser.py` |
|  Structures | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/_structures.py` |
|  Tokenizer | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/_tokenizer.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/licenses/__init__.py` |
|  Spdx | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/licenses/_spdx.py` |
| Markers | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/markers.py` |
| Metadata | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/metadata.py` |
| Pylock | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/pylock.py` |
| Requirements | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/requirements.py` |
| Specifiers | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/specifiers.py` |
| Tags | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/tags.py` |
| Utils | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/utils.py` |
| Version | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/packaging/version.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pkg_resources/__init__.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/platformdirs/__init__.py` |
|   Main   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/platformdirs/__main__.py` |
| Android | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/platformdirs/android.py` |
| Api | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/platformdirs/api.py` |
| Macos | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/platformdirs/macos.py` |
| Unix | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/platformdirs/unix.py` |
| Version | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/platformdirs/version.py` |
| Windows | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/platformdirs/windows.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/__init__.py` |
|   Main   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/__main__.py` |
| Console | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/console.py` |
| Filter | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/filter.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/filters/__init__.py` |
| Formatter | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/formatter.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/formatters/__init__.py` |
|  Mapping | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/formatters/_mapping.py` |
| Lexer | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/lexer.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/lexers/__init__.py` |
|  Mapping | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/lexers/_mapping.py` |
| Python | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/lexers/python.py` |
| Modeline | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/modeline.py` |
| Plugin | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/plugin.py` |
| Regexopt | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/regexopt.py` |
| Scanner | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/scanner.py` |
| Sphinxext | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/sphinxext.py` |
| Style | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/style.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/styles/__init__.py` |
|  Mapping | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/styles/_mapping.py` |
| Token | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/token.py` |
| Unistring | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/unistring.py` |
| Util | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pygments/util.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pyproject_hooks/__init__.py` |
|  Impl | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pyproject_hooks/_impl.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pyproject_hooks/_in_process/__init__.py` |
|  In Process | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/pyproject_hooks/_in_process/_in_process.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/__init__.py` |
|   Version   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/__version__.py` |
|  Internal Utils | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/_internal_utils.py` |
| Adapters | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/adapters.py` |
| Api | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/api.py` |
| Auth | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/auth.py` |
| Certs | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/certs.py` |
| Compat | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/compat.py` |
| Cookies | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/cookies.py` |
| Exceptions | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/exceptions.py` |
| Help | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/help.py` |
| Hooks | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/hooks.py` |
| Models | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/models.py` |
| Packages | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/packages.py` |
| Sessions | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/sessions.py` |
| Status Codes | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/status_codes.py` |
| Structures | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/structures.py` |
| Utils | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/requests/utils.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/__init__.py` |
| Providers | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/providers.py` |
| Reporters | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/reporters.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/resolvers/__init__.py` |
| Abstract | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/resolvers/abstract.py` |
| Criterion | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/resolvers/criterion.py` |
| Exceptions | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/resolvers/exceptions.py` |
| Resolution | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/resolvers/resolution.py` |
| Structs | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/resolvelib/structs.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/__init__.py` |
|   Main   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/__main__.py` |
|  Cell Widths | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_cell_widths.py` |
|  Emoji Codes | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_emoji_codes.py` |
|  Emoji Replace | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_emoji_replace.py` |
|  Export Format | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_export_format.py` |
|  Extension | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_extension.py` |
|  Fileno | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_fileno.py` |
|  Inspect | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_inspect.py` |
|  Log Render | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_log_render.py` |
|  Loop | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_loop.py` |
|  Null File | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_null_file.py` |
|  Palettes | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_palettes.py` |
|  Pick | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_pick.py` |
|  Ratio | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_ratio.py` |
|  Spinners | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_spinners.py` |
|  Stack | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_stack.py` |
|  Timer | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_timer.py` |
|  Win32 Console | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_win32_console.py` |
|  Windows | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_windows.py` |
|  Windows Renderer | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_windows_renderer.py` |
|  Wrap | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/_wrap.py` |
| Abc | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/abc.py` |
| Align | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/align.py` |
| Ansi | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/ansi.py` |
| Bar | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/bar.py` |
| Box | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/box.py` |
| Cells | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/cells.py` |
| Color | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/color.py` |
| Color Triplet | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/color_triplet.py` |
| Columns | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/columns.py` |
| Console | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/console.py` |
| Constrain | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/constrain.py` |
| Containers | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/containers.py` |
| Control | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/control.py` |
| Default Styles | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/default_styles.py` |
| Diagnose | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/diagnose.py` |
| Emoji | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/emoji.py` |
| Errors | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/errors.py` |
| File Proxy | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/file_proxy.py` |
| Filesize | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/filesize.py` |
| Highlighter | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/highlighter.py` |
| Json | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/json.py` |
| Jupyter | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/jupyter.py` |
| Layout | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/layout.py` |
| Live | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/live.py` |
| Live Render | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/live_render.py` |
| Logging | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/logging.py` |
| Markup | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/markup.py` |
| Measure | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/measure.py` |
| Padding | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/padding.py` |
| Pager | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/pager.py` |
| Palette | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/palette.py` |
| Panel | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/panel.py` |
| Pretty | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/pretty.py` |
| Progress | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/progress.py` |
| Progress Bar | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/progress_bar.py` |
| Prompt | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/prompt.py` |
| Protocol | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/protocol.py` |
| Region | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/region.py` |
| Repr | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/repr.py` |
| Rule | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/rule.py` |
| Scope | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/scope.py` |
| Screen | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/screen.py` |
| Segment | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/segment.py` |
| Spinner | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/spinner.py` |
| Status | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/status.py` |
| Style | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/style.py` |
| Styled | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/styled.py` |
| Syntax | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/syntax.py` |
| Table | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/table.py` |
| Terminal Theme | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/terminal_theme.py` |
| Text | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/text.py` |
| Theme | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/theme.py` |
| Themes | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/themes.py` |
| Traceback | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/traceback.py` |
| Tree | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/rich/tree.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/tomli/__init__.py` |
|  Parser | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/tomli/_parser.py` |
|  Re | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/tomli/_re.py` |
|  Types | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/tomli/_types.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/tomli_w/__init__.py` |
|  Writer | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/tomli_w/_writer.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/truststore/__init__.py` |
|  Api | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/truststore/_api.py` |
|  Macos | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/truststore/_macos.py` |
|  Openssl | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/truststore/_openssl.py` |
|  Ssl Constants | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/truststore/_ssl_constants.py` |
|  Windows | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/truststore/_windows.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/__init__.py` |
|  Collections | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/_collections.py` |
|  Version | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/_version.py` |
| Connection | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/connection.py` |
| Connectionpool | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/connectionpool.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/__init__.py` |
|  Appengine Environ | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/_appengine_environ.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/_securetransport/__init__.py` |
| Bindings | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/_securetransport/bindings.py` |
| Low Level | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/_securetransport/low_level.py` |
| Appengine | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/appengine.py` |
| Ntlmpool | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/ntlmpool.py` |
| Pyopenssl | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/pyopenssl.py` |
| Securetransport | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/securetransport.py` |
| Socks | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/contrib/socks.py` |
| Exceptions | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/exceptions.py` |
| Fields | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/fields.py` |
| Filepost | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/filepost.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/packages/__init__.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/packages/backports/__init__.py` |
| Makefile | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/packages/backports/makefile.py` |
| Weakref Finalize | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/packages/backports/weakref_finalize.py` |
| Six | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/packages/six.py` |
| Poolmanager | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/poolmanager.py` |
| Request | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/request.py` |
| Response | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/response.py` |
|   Init   | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/__init__.py` |
| Connection | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/connection.py` |
| Proxy | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/proxy.py` |
| Queue | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/queue.py` |
| Request | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/request.py` |
| Response | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/response.py` |
| Retry | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/retry.py` |
| Ssl  | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/ssl_.py` |
| Ssl Match Hostname | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/ssl_match_hostname.py` |
| Ssltransport | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/ssltransport.py` |
| Timeout | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/timeout.py` |
| Url | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/url.py` |
| Wait | Other | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/wait.py` |
| License | Other | `.lessenv/lib/python3.14/site-packages/pip-26.0.1.dist-info/licenses/src/pip/_vendor/idna/LICENSE.md` |
| 10 Base T | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/10 Base-T.md` |
| 1000Base T | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/1000Base-T.md` |
| 100Base T | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/100Base-T.md` |
| Types | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/Types.md` |
| Wiring | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Cables & Connectors/Wiring.md` |
| Computer Network Components | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Computer network components.md` |
| Hub | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/HUB.md` |
| Nic | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/NIC.md` |
| 1841 Cisco Router | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Components/1841 Cisco Router.md` |
| Modem | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Components/Modem.md` |
| Router Devices And Wic Modules | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Components/Router devices and WIC modules.md` |
| Loop Back Interface | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/LOOP-BACK INTERFACE.md` |
| Ospf | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/OSPF.md` |
| Route Aggregation | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Route Aggregation.md` |
| Routing Alogrithms | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Routing Alogrithms.md` |
| Routing Concepts | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Routing Concepts.md` |
| Routing Loops | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Routing Loops.md` |
| Routing Protocol Metrics | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Protocols/Routing Protocol Metrics.md` |
| Router Main | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/1. Physical/Devices/Router/Router Main.md` |
| Computer Network Models | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/Computer Network Models.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/Quiz.md` |
| Real Life Scenarios | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/02-Network-Models/OSI Model/Real-Life-Scenarios.md` |
| Challenges | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/03-IP-Addressing/CHALLENGES.md` |
| Lab 01 Telnet Test | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/07-Network-Troubleshooting-Labs/lab_01_telnet_test.py` |
| Lab 02 Dns Resolver | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/07-Network-Troubleshooting-Labs/lab_02_dns_resolver.py` |
| Ip Addressing Subnetting Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/IP-Addressing-Subnetting-Ref.md` |
| Network Devices Hardware Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Network-Devices-Hardware-Ref.md` |
| Network Models Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Network-Models-Ref.md` |
| Network Protocols Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Network-Protocols-Ref.md` |
| Network Troubleshooting Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Network-Troubleshooting-Ref.md` |
| Networking Best Practices Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/REFERENCE/Networking-Best-Practices-Ref.md` |
| Get Networkinventory | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Get-NetworkInventory.ps1` |
| Measure Networklatency | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Measure-NetworkLatency.ps1` |
| Resolve Dnsissues | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Resolve-DNSIssues.ps1` |
| Test Networkdiagnostics | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Test-NetworkDiagnostics.ps1` |
| Test Portconnectivity | 🌱 Beginner | `1-Beginner/01-Phase-1/01-Networking/scripts/Test-PortConnectivity.ps1` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/01-Introduction/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/01-Introduction/Quiz.md` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/02-Filesystem/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/02-Filesystem/Quiz.md` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/03-Commands/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/03-Commands/Quiz.md` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/04-Permissions/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/04-Permissions/Quiz.md` |
| Fedora Systemaudit | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Fedora-SystemAudit.sh` |
| Fedora Toolbox | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Fedora-Toolbox.sh` |
| Optimize Fedorafull | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Optimize-FedoraFull.sh` |
| Optimize Intelgpu | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Optimize-IntelGPU.sh` |
| Preset Generator | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Preset-Generator.sh` |
| Rollback Fedorafull | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/Rollback-FedoraFull.sh` |
| Fedora Network | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/fedora-network.sh` |
| Fedora Security | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/bash/fedora-security.sh` |
| Input Enhancer Preset | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/python/Input-Enhancer-Preset.py` |
| Preseteqgenarator | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/Fedora/Scripts/python/PresetEqGenarator.py` |
| Dnf Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/01-RHEL-Family/dnf-cheat-sheet.md` |
| Apt Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/02-Debian-Family/apt-cheat-sheet.md` |
| Zypper Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/03-SUSE-Family/zypper-cheat-sheet.md` |
| Apk Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/04-Lightweight-and-Cloud-Native/apk-cheat-sheet.md` |
| Pacman Cheat Sheet | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/04-Lightweight-and-Cloud-Native/pacman-cheat-sheet.md` |
| Distro Comparison Matrix | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/05-Distros/Distro-Comparison-Matrix.md` |
| Interview Questions And Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/Interview_Questions_and_Quiz.md` |
| Linux Best Practices Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-Best-Practices-Ref.md` |
| Linux Essential Commands Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-Essential-Commands-Ref.md` |
| Linux Filesystem Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-Filesystem-Ref.md` |
| Linux Permissions Ownership Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-Permissions-Ownership-Ref.md` |
| Linux Ssh Security Ref | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/REFERENCE/Linux-SSH-Security-Ref.md` |
| Interview Questions | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/SSH/Interview_Questions.md` |
| Quiz | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/SSH/Quiz.md` |
| Disk Usage Analyzer | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/disk-usage-analyzer.sh` |
| Linux System Audit | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/linux-system-audit.sh` |
| Permission Analyzer | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/permission-analyzer.sh` |
| Process Monitor | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/process-monitor.sh` |
| Ssh Hardening | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/bash/ssh-hardening.sh` |
| Input Enhancer Generator | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/python/Input_Enhancer_Generator.py` |
| Preset Eq Generator | 🌱 Beginner | `1-Beginner/01-Phase-1/02-Linux/scripts/python/Preset_Eq_Generator.py` |
| Linkks | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Linkks.md` |
| Login Screen | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Login Screen.md` |
| Format Volume | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Format-Volume.md` |
| Get Disk | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Get-Disk.md` |
| Get Partition | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Get-Partition.md` |
| Get Volume | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Get-Volume.md` |
| Initialize Disk | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Initialize-Disk.md` |
| New Partition | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/New-Partition.md` |
| Remove Partition | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Remove-Partition.md` |
| Resize Partition | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Resize-Partition.md` |
| Set Volume | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/DiskAndStorage/Set-Volume.md` |
| Get Eventlog | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/EventLogs/Get-EventLog.md` |
| Get Winevent | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/EventLogs/Get-WinEvent.md` |
| Get Acl | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/FileAndACL/Get-Acl.md` |
| Set Acl | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/FileAndACL/Set-Acl.md` |
| Add Hostsentry | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Add-HostsEntry.md` |
| Audit Firewallprofiles | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Audit-FirewallProfiles.md` |
| Audit Firewallrules | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Audit-FirewallRules.md` |
| Get Processconnections | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Get-ProcessConnections.md` |
| Get Systemuptime | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Get-SystemUptime.md` |
| Get Wifipasswords | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Get-WiFiPasswords.md` |
| Reset Dnscache | 🌱 Beginner | `1-Beginner/01-Phase-1/03-Windows-Basics/Part-1-PowerShell-Automation/Commands/HacksAndTips/Reset-DnsCache.md` |

</details>


---

## 🕒 Recent Activity (Auto-Generated)

| File | Last Modified | Path |
| :--- | :--- | :--- |
| git_command.py | 2026-02-05 01:29 | `git_command.py` |
| core_auto.py | 2026-02-05 00:40 | `2-Intermediate/02-Phase-2/01-Infrastructure-Automation/01-Scripting-Automation/02-Python-for-Infrastructure/01-Part-1-The-Blueprint/04-Reference/core_auto.py` |
| LICENSE.md | 2026-02-05 00:30 | `.lessenv/lib/python3.14/site-packages/pip-26.0.1.dist-info/licenses/src/pip/_vendor/idna/LICENSE.md` |
| wait.py | 2026-02-05 00:30 | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/wait.py` |
| url.py | 2026-02-05 00:30 | `.lessenv/lib/python3.14/site-packages/pip/_vendor/urllib3/util/url.py` |


---

## 🛡️ Repository Standards
1.  **Atomicity**: Every functional module MUST have its own `REFERENCE.md`.
2.  **No Rot**: Use the [Link Scanner](./00-Resources/01-Scripts-Code/Maintenance/repository_audit.py) to verify internal links.
3.  **Hierarchy**: Follow the `Beginner -> Intermediate -> Advanced` flow for learning.

---
*"Infrastructure is code. Knowledge is scale."*
