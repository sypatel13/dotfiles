# CLI and terminal setup

[playbook.yml](playbook.yml) installs the CLI tools from
[TERMINAL_TOOLS.md](TERMINAL_TOOLS.md) and links the terminal configuration
to this checkout on Apple Silicon or Intel Macs.
[ubuntu.yml](ubuntu.yml) provides the equivalent CLI setup for Ubuntu 26.04
on amd64 or arm64, without Homebrew. See [Ubuntu setup](#ubuntu-setup).
[cachyos.yml](cachyos.yml) uses pacman packages on CachyOS, and
[bazzite.yml](bazzite.yml) uses Homebrew on Bazzite. See
[CachyOS setup](#cachyos-setup) and [Bazzite setup](#bazzite-setup).
All run locally as your normal user. Do not launch any of them with `sudo`,
`--become`, or concurrently with another setup run. The Ubuntu playbook
requests sudo only for its system package and APT repository tasks. The
CachyOS playbook requests sudo only for its package, Docker service, and
group tasks. The macOS and Bazzite playbooks do not use sudo.

## What the MacBook setup manages

- The Homebrew formulae in [vars.yml](vars.yml), including standalone Docker,
  Compose, Buildx, and kubectl clients.
- The Copilot CLI and Task casks, plus SauceCodePro Nerd Font.
- Oh My Zsh, Powerlevel10k, and Deja's Oh My Zsh plugin at pinned Git commits.
  Oh My Zsh automatic updates are disabled so it stays at the managed revision.
- Symlinks for Zsh, Powerlevel10k, Oh my tmux!, and Ghostty. See
  [Oh my tmux!](#oh-my-tmux) for how the tmux files are split.
  A comment-only native Ghostty config prevents that location from overriding
  the shared config. Existing native settings are backed up.
- Docker plugin links for `docker compose` and `docker buildx`. It does not edit
  Docker credentials or contexts.
- Symlinks for [.gitconfig](.gitconfig) and [.gitignore_global](.gitignore_global).
  The linked Git config sets your identity, credential cache, global ignore
  file, and delta pager. An existing `~/.gitconfig` is backed up, not merged.
  Later `git config --global` writes, including `gh auth setup-git`, change
  the repository file.

It does not install Docker Desktop, Ghostty, VS Code, VS Code extensions,
Obsidian, or the Copilot desktop app. Obsidian's CLI and Desktop-only Docker
plugins require their respective apps and are outside this CLI-only setup.
Existing applications are not removed.

Homebrew supplies the mise executable. For this project's automation, mise
selects pinned Python, uv, and Task versions from [mise.toml](mise.toml).
uv manages the project virtual environment and Python dependency lockfile.
Task defines the workflow in [Taskfile.yml](Taskfile.yml).

The Mac's Homebrew Python and Task packages remain in the tool inventory.
They are separate from the versions mise selects inside this project.
The playbook does not remove existing standalone installations, import shell
history, change your login shell, or authenticate any service.
macOS-provided utilities do not need reinstalling.

## MacBook prerequisites

1. Install Apple's Command Line Tools with `xcode-select --install` and finish
   the installer, or select an existing Xcode installation.
2. Install current [Homebrew](https://brew.sh) using its official instructions.
   Use `/opt/homebrew` on Apple Silicon or `/usr/local` on Intel. The Task tap
   needs a Homebrew release that supports `brew trust`.
3. Keep this checkout at a permanent location outside your home directory's
   root, such as `~/Development/dotfiles`.
4. Bootstrap mise, review and trust [mise.toml](mise.toml), then install the
   project tools and dependencies:

```sh
brew install mise
mise trust
mise install
mise exec -- task setup
```

Run these commands from the repository root after initializing Homebrew's PATH.
`mise exec` selects the project tools without requiring shell activation.
If mise is already active in your shell, you can use `task` directly.
`mise install` installs the pinned runtimes and tools, but does not provision
your Mac. Automatic tool installation during `mise exec` is disabled.

[pyproject.toml](pyproject.toml) pins Ansible core 2.22.0 and ansible-lint 26.10.1.
[uv.lock](uv.lock) also locks their transitive Python dependencies. `task sync`
uses `uv sync --locked` to create or update `.venv`, including the default
development dependency group. No pip or manual virtualenv activation is needed.
uv resolves `python` from PATH after mise activates the project tools and does
not download another Python. This keeps the configuration readable during
`mise trust`, before Python has been installed.

[collections.yml](collections.yml) retains the exact Galaxy collection pins
for community.general and its dependency. These are Ansible collections, not
Python packages, so uv cannot install them. `task collections` uses
`ansible-galaxy` from the uv environment and installs into `.ansible/collections`.
Task sets the collection path for every Ansible command.

`task setup` checks out the Oh my tmux! submodule, then runs Python
synchronization before collection installation.
Other tasks do not install dependencies or silently update the lockfile.
Before any Ansible command, a shared prerequisite runs
`uv sync --check --locked --offline`. It refuses an outdated lockfile or
environment without changing either. Run setup again after dependency changes.
To change Python dependencies, edit
[pyproject.toml](pyproject.toml), run `mise exec -- task lock`, and commit both
the manifest and [uv.lock](uv.lock). Keep the core version assertions in
[playbook.yml](playbook.yml), [ubuntu.yml](ubuntu.yml),
[cachyos.yml](cachyos.yml), and [bazzite.yml](bazzite.yml) aligned if you
change Ansible core.

Homebrew packages use `state: present`, not `latest`. Reruns do not request
upgrades of installed tools. New installs use the versions Homebrew currently
offers and may install or upgrade required dependencies. Automatic Homebrew
updates and install cleanup are disabled during the play.
Run `brew update` yourself before setup if package metadata needs refreshing.

## Run on macOS

Review [vars.yml](vars.yml) and [playbook.yml](playbook.yml) first. Then:

```sh
mise exec -- task --list
mise exec -- task plan
mise exec -- task apply
```

`plan` uses Ansible's `--check --diff`; it is not an installation. `apply` is
the only task that provisions the Mac. Both accept extra Ansible arguments
after `--`, for example `mise exec -- task apply -- --diff`.
The default `task` command only lists tasks.

The terminal font cask uses Homebrew's `--adopt` option. It adopts existing
byte-identical font files and installs any missing ones without overwriting
different files. This option applies only to `font-sauce-code-pro-nerd-font`.
Once adopted, Homebrew manages those fonts, including removing them if you
uninstall the cask.

The playbook does not force Homebrew to overwrite conflicting installations.
If existing fonts differ from the cask's files, back them up and resolve the
conflict before retrying. Docker executables previously installed by Docker
Desktop can also conflict.
Git checkouts also refuse to discard local modifications. Back up or reconcile
existing non-Git framework directories before retrying a failed clone.

Open a new Zsh session after setup. Run `gh auth login` and `copilot` yourself
to authenticate. Run `deja import` only if you want to import existing history.
Use an existing Docker daemon or configure a remote Docker context separately.
The installed clients alone cannot run containers.

## Ubuntu setup

[ubuntu.yml](ubuntu.yml) supports Ubuntu 26.04 on amd64 and arm64. It shares
the shell framework pins, configuration and Git links, and backups with the
MacBook playbook through [vars.yml](vars.yml) and
[tasks/terminal.yml](tasks/terminal.yml).

[vars.ubuntu.yml](vars.ubuntu.yml) defines the Ubuntu packages and release pins.
[vars.linux.yml](vars.linux.yml) holds the user-local install paths and the
Deja and OpenSpec pins it shares with CachyOS:

- Ubuntu APT packages supply Git, gh, delta, tmux, Zsh, syntax highlighting,
  fzf, eza, ripgrep, Node.js, npm, OpenSSL, and basic developer utilities.
- The bootstrap installs mise from its official PPA. The same
  [mise.toml](mise.toml) selects Python 3.13, uv, and Task for this project.
  System Python remains Ubuntu's version and runs Ansible's target modules,
  including `python3-apt`. The controller still uses the pinned uv environment.
- Docker's signed Ubuntu repository supplies only `docker-ce-cli`,
  `docker-compose-plugin`, and `docker-buildx-plugin`. The playbook does not
  install a daemon, enable services, change group membership, or edit Docker
  credentials. The packages provide plugin discovery without user plugin links.
- Pinned, SHA-256-verified upstream downloads supply Deja, Task, kubectl,
  and SauceCodePro Nerd Font. CLI releases live under
  `~/.local/share/dotfiles/`, with backed-up links in `~/.local/bin`.
  The font installs under `~/.local/share/fonts/`.
- Pinned Copilot CLI and OpenSpec npm packages use a dedicated user-owned
  prefix under `~/.local/share/dotfiles/npm`. They do not need sudo or change
  your npm configuration. Their commands are linked into `~/.local/bin`.

The shared Zsh files use Ubuntu's mise and syntax-highlighting paths, add
`~/.local/bin` to PATH, and omit the macOS plugin on Linux. They retain the
Homebrew paths and macOS plugin on Macs. Ubuntu gets the shared Ghostty
configuration but no macOS `Library` configuration.

Desktop applications, service authentication, history import, and changing
your login shell remain manual. Existing desktop apps and Docker daemons are
not removed. APT refuses package removals instead of replacing conflicting
Docker installations.

### Bootstrap

Use your normal sudo-enabled user. Keep this checkout in a permanent location
such as `~/Development/dotfiles`, not directly in the home directory.
Enable Universe and install [mise's official PPA](https://mise.jdx.dev/installing-mise.html#apt):

```sh
sudo apt update
sudo apt install --yes software-properties-common ca-certificates git curl python3-apt
sudo add-apt-repository --yes universe
sudo add-apt-repository --yes ppa:jdxcode/mise
sudo apt update
sudo apt install --yes mise
```

From the repository root, review and trust the mise configuration, then:

```sh
mise trust
mise install
mise exec -- task setup
mise exec -- task ubuntu:plan
mise exec -- task ubuntu:apply
```

Both Ubuntu tasks prompt for your sudo password and accept extra Ansible
arguments after `--`. Only the package block escalates privileges. The
unqualified `task plan` and `task apply` still target macOS.

Start `zsh` after setup. To make it your login shell, run
`chsh -s /usr/bin/zsh` yourself and log in again. Authenticate with
`gh auth login` and `copilot` yourself. Run `deja import` only if desired.
Docker needs a separately configured local or remote daemon.

APT uses `state: present` and does not request upgrades of existing packages.
It refreshes metadata when the cache is over an hour old or the Docker source
changes. New packages can bring required dependencies. Direct downloads and
npm packages converge to their configured versions. Update both the version
and checksums when changing a downloaded release. Choose a kubectl version
within one minor version of your cluster.

### Ubuntu validation

`mise exec -- task validate` covers all four playbooks and their shared tasks.
It checks syntax and lint, not installation. When `ubuntu:plan` predicts changes
to Docker's signing key or repository, it reports that Docker package checks are
deferred: check mode cannot add the repository or refresh its package index.
`ubuntu:apply` configures the repository and installs the clients normally;
subsequent plans check the packages when the key and repository are unchanged.
Downloads are deferred when their destination directories do not yet exist.
Archive extraction is deferred when its destination directory is missing or its
download is deferred or would change. npm package checks are deferred when
`/usr/bin/npm` is missing. The plan explains these limitations; it does not
create directories or install prerequisites to make a dry run succeed.
Existing prerequisites still allow checks, but check mode cannot fully predict
a fresh installation or validate new downloads, and network or package errors
can still fail the plan.

Run the isolated Ubuntu check-mode regression tests with:

```sh
mise exec -- uv run --no-sync --offline python -m unittest discover -s tests
```

These use temporary directories and a local HTTP server, not real system
package installations or external downloads.

Both playbooks passed offline syntax checks and ansible-lint with the pinned
Ansible core 2.22.0, ansible-lint 26.10.1, and community.general 14.0.0 in a
network-denied macOS sandbox. Zsh syntax checks and six targeted checks passed,
covering sandbox isolation, amd64/arm64 download configuration, sudo scope,
Task routing, unchanged macOS task parameters, and repeated Linux PATH setup.

Before relying on this setup, run it twice on an approved disposable Ubuntu
26.04 machine. With unchanged inputs and a fresh APT cache, the second run
should report `changed=0`. Check the backup cases below and confirm
`docker --version`, `docker compose version`, `docker buildx version`,
`kubectl version --client`, `deja --version`, `task --version`,
`copilot --version`, and `openspec --version`. Confirm that
`fc-match 'SauceCodePro Nerd Font Mono'` resolves the installed font.
No Ubuntu provisioning or second-run convergence has been tested here.

## CachyOS setup

[cachyos.yml](cachyos.yml) supports CachyOS on x86_64. Ansible reports CachyOS
as Arch Linux, so the playbook checks `ID=cachyos` in `/etc/os-release`. It
shares the shell framework pins, configuration and Git links, and backups with
the other playbooks through [vars.yml](vars.yml) and
[tasks/terminal.yml](tasks/terminal.yml). It reuses Ubuntu's user-local Deja
and OpenSpec installs through [vars.linux.yml](vars.linux.yml).

[vars.cachyos.yml](vars.cachyos.yml) defines the packages:

- Native pacman packages supply Git, gh, delta, tmux, Zsh, syntax highlighting,
  fzf, eza, ripgrep, mise, Node.js, npm, Python, OpenSSL, Task, kubectl,
  SauceCodePro Nerd Font, and basic developer utilities. The Copilot CLI comes
  from the `github-copilot-cli` package in the `cachyos` repository.
- Arch names Task's executable `go-task`, so the playbook links it as
  `~/.local/bin/task`.
- The `docker`, `docker-compose`, and `docker-buildx` packages supply the
  daemon, client, and plugins. The playbook enables and starts
  `docker.service` and adds you to the `docker` group. That group grants
  root-equivalent access and takes effect after you log in again. Docker
  credentials and contexts are not edited.
- Deja and OpenSpec are not packaged, so they use the same pinned,
  SHA-256-verified download and user-owned npm prefix as Ubuntu.

The shared Zsh files use `/usr/bin/mise` and Arch's
`/usr/share/zsh/plugins/zsh-syntax-highlighting` path. An existing CachyOS
`~/.zshrc` is backed up and replaced by the repository link.

pacman uses `state: present` and does not refresh the sync databases, because
refreshing them without a full upgrade is an unsupported partial upgrade.
Run `sudo pacman -Syu` yourself before setup. pacman refuses conflicting
packages, such as an installed `nodejs-lts-*` in place of `nodejs`, instead of
replacing them. Resolve those conflicts before retrying.

### CachyOS bootstrap

Use your normal sudo-enabled user and a permanent checkout location:

```sh
sudo pacman -Syu --needed git mise python
```

From the repository root, review and trust the mise configuration, then:

```sh
mise trust
mise install
mise exec -- task setup
mise exec -- task cachyos:plan
mise exec -- task cachyos:apply
```

Both CachyOS tasks prompt for your sudo password and accept extra Ansible
arguments after `--`. Only the package, Docker service, and group tasks
escalate privileges. The plan defers Docker service and group checks until the
`docker` package is installed, and defers downloads and npm checks as
described in [Ubuntu validation](#ubuntu-validation).

CachyOS defaults to fish. Start `zsh` after setup, or run
`chsh -s /usr/bin/zsh` yourself and log in again. Log in again before using
Docker without sudo. Authenticate with `gh auth login` and `copilot` yourself.

On this CachyOS machine, `cachyos.yml` passed a check-mode run with privilege
escalation disabled. It has not been applied, and second-run convergence is
untested.

## Bazzite setup

[bazzite.yml](bazzite.yml) supports Bazzite on x86_64 and checks `ID=bazzite`
in `/etc/os-release`. Bazzite's image is immutable, so the playbook uses
Homebrew at `/home/linuxbrew/.linuxbrew`, as Bazzite recommends for CLI tools.
It does not layer packages with rpm-ostree, change system services, or use
sudo. It shares [tasks/homebrew.yml](tasks/homebrew.yml) with the MacBook
playbook and [tasks/terminal.yml](tasks/terminal.yml) with all playbooks.

[vars.bazzite.yml](vars.bazzite.yml) installs the same formulae as macOS
plus homebrew-core's `go-task`. The Task tap's cask runs a macOS-only
post-install step, so it is skipped. The `copilot-cli` and
`font-sauce-code-pro-nerd-font` casks install on Linux; the font goes
under `~/.local/share/fonts`. Docker plugin links point to Homebrew's
`docker-compose` and `docker-buildx`.

The shared Zsh files load Homebrew's environment and use its mise and syntax
highlighting when `HOMEBREW_PREFIX` contains mise.

### Bazzite bootstrap

Homebrew normally ships with Bazzite. The playbook stops if
`/home/linuxbrew/.linuxbrew/bin/brew` is missing. From the repository root:

```sh
brew install mise
mise trust
mise install
mise exec -- task setup
mise exec -- task bazzite:plan
mise exec -- task bazzite:apply
```

Neither Bazzite task prompts for a password. Packages use `state: present`
with automatic Homebrew updates disabled, as on macOS.

Bazzite recommends launching Zsh from your terminal profile instead of using
`chsh`. Set the profile's custom command to
`/home/linuxbrew/.linuxbrew/bin/zsh`. On Linux, the shared Zsh config sets
`SHELL` to Zsh when your login shell differs, so tmux also opens Zsh. No
Docker daemon is installed or
enabled. Use Podman's Docker-compatible socket or a separately configured
daemon or remote context. Authenticate with `gh auth login` and `copilot`
yourself.

`bazzite.yml` passed syntax checks and lint only. No Bazzite run has been
tested.

## Symlinks and backups

Edits through a managed configuration symlink change this checkout. Keep the
checkout in place. If you move it, rerun the playbook from its new location.

Before replacing a regular file or a different symlink, the playbook moves it
to a uniquely named private directory under
`~/.local/state/dotfiles/backups/`. Each backup is named `original`, and the
playbook prints its source and backup paths. It moves symlinks without following
them, including dangling links. Existing directories and special files cause
an error instead of being replaced. Correct links need no new backup.

Backups can contain private settings. They stay local and are not deleted
automatically. To restore one, remove only the corresponding managed symlink
and move its `original` backup back to the reported source path. If setup fails
after a backup, that backup remains available for recovery.

The backup mechanism covers replaced links and files. Selective Git settings
are managed in place rather than replacing or backing up the whole Git config.

## Oh my tmux!

[.tmux.conf](.tmux.conf) is a symlink to the upstream file in the
[vendor/oh-my-tmux](vendor/oh-my-tmux) submodule, so `~/.tmux.conf` resolves
to the pinned upstream commit. Don't edit that file. Put tmux settings in
[.tmux.conf.local](.tmux.conf.local), which starts from the upstream template
and adds two changes: Powerline separators, and `|` instead of `_` for
`split-window -h`.

To update upstream, review its changes, then commit the new submodule commit:

```sh
git -C vendor/oh-my-tmux fetch origin
git -C vendor/oh-my-tmux log --oneline HEAD..origin/master
git -C vendor/oh-my-tmux checkout origin/master
git diff --submodule=diff
git add vendor/oh-my-tmux
```

If the diff changes `vendor/oh-my-tmux/.tmux.conf.local`, copy any new
settings you want into [.tmux.conf.local](.tmux.conf.local). Running tmux
servers keep their loaded configuration until you press `prefix r` or
start a new server.

## Validation

The uv and Task workflow was checked in a temporary macOS sandbox with network
access denied and user data inaccessible. mise installed the pinned tools into
temporary storage; uv synchronized the locked dependencies there. Local
`ansible-doc` resolved the pinned core and collection modules. Playbook syntax
checking and ansible-lint passed with no lint findings.
The shared prerequisite rejected a stale lockfile, a missing virtual environment,
and an incomplete environment without installing packages or rewriting the lock.
A clean bootstrap was also checked with mise 2026.11.0, including configuration
evaluation before installing tools and uv's selection of mise-managed Python.

The pinned toolchain emits Ansible deprecation notices for the built-in
`oneline` and `tree` callbacks during linting. These notices are not suppressed.
No provisioning playbook was run against the Mac. First-run installation and
second-run convergence remain untested.

In an approved isolated validation environment with the pinned dependencies:

```sh
mise exec -- task validate
```

This checks the lockfile and environment, then runs `task syntax` and `task lint`
sequentially for all platforms. Both use the existing uv environment with
automatic synchronization disabled.
Validation runs offline and does not invoke `task setup` or contact the Mac
through a provisioning run. Ansible configuration and plugins can still
execute controller-side code, so use an approved isolated environment.

Syntax checks do not prove installation or backup behavior. On an approved
disposable Mac, run the playbook twice with the same inputs. The second run
should report `changed=0` when no package or configuration drift occurred.
Also check absent destinations, existing files, correct links, different links,
dangling links, paths with spaces, and directory collisions. Verify that every
displaced object has a recoverable backup and reruns do not add backups.

`--check --diff` is only a prediction and still queries Homebrew and Git.
It performs no backup moves. On a fresh machine, taps, Git, and other
prerequisites may not yet exist, so check mode can fail or provide incomplete
predictions. Missing link sources are allowed in check mode because earlier
package installs are only simulated; a real run requires regular source files.
Do not use check mode as proof that a fresh bootstrap will succeed.

After an approved real run, check clients without contacting a daemon:

```sh
docker --version
docker compose version
docker buildx version
kubectl version --client=true
```
