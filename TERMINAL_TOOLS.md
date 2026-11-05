# Terminal tools

Inventory refreshed on 2026-11-04 from the current Mac's Homebrew packages,
executable paths, active shell configuration, language package managers,
Docker CLI plugins, VS Code extensions, and system developer utilities. This
covers terminal and developer tooling, not all Mac applications or project-local
dependencies. Installations are confirmed on the machine, not inferred solely
from this repository's dotfiles.

## Automated CLI setup

[README.md](README.md) describes the Ansible setup in [playbook.yml](playbook.yml).
It installs CLI tools and the terminal font, then symlinks the configurations
with backups. It excludes desktop apps and VS Code extensions. Docker uses
standalone clients instead of Docker Desktop, and shell initialization uses
Homebrew's mise instead of the standalone copy.

Project commands use mise-pinned Python, uv, and Task. Python dependencies
live in [pyproject.toml](pyproject.toml) and [uv.lock](uv.lock); Galaxy collections
remain separate in [collections.yml](collections.yml). Use the bootstrap and
Task commands in [README.md](README.md), not the snapshot installation commands
below, to set up this automation project.

[ubuntu.yml](ubuntu.yml) provides the Ubuntu 26.04 equivalent using APT and
pinned upstream releases. See [Ubuntu setup](README.md#ubuntu-setup) for its
package sources, bootstrap, and platform differences. The inventory below
remains a snapshot of the Mac, not an Ubuntu package list.

The inventory below describes the Mac at snapshot time. The repository
configuration now includes the portability changes described in
[Configuration snapshots](#configuration-snapshots).

## Homebrew-installed tools

Homebrew is the package manager used for these tools.

### Formulae

| Package | Purpose |
| --- | --- |
| `git` | Version control |
| `gh` | GitHub CLI |
| `git-delta` | Syntax-highlighted Git diffs; command: `delta` |
| `tmux` | Terminal sessions, windows, and panes |
| `zsh` | Homebrew's Zsh, separate from the macOS-provided shell |
| `deja` | Predictive shell autosuggestions |
| `zsh-syntax-highlighting` | Highlights commands as they are typed |
| `fzf` | Fuzzy finder for the command line |
| `eza` | Directory listing tool; replacement for `ls` |
| `ripgrep` | Recursive text search; command: `rg` |
| `mise` | Runtime manager; a separate standalone copy supplies the active shell integration |
| `node` | JavaScript runtime, with `npm` and `npx` |
| `python@3.13` | Python runtime; commands: `python3.13` and `pip3.13` |
| `openspec` | Spec-driven development tooling for AI coding assistants |
| `openssl@3` | Cryptography and TLS tools at `/opt/homebrew/opt/openssl@3/bin/openssl` |

### Casks

| Package | Purpose |
| --- | --- |
| `copilot-cli` | GitHub Copilot terminal assistant; command: `copilot` |
| `docker-desktop` | Docker Desktop, Docker CLI, bundled CLI plugins, and `kubectl` |
| `go-task/tap/go-task` | Task runner installed from the `go-task/tap` tap; command: `task` |

After installing Homebrew, reinstall these tools with:

```sh
brew install git gh git-delta tmux zsh deja zsh-syntax-highlighting fzf eza ripgrep mise node python@3.13 openspec openssl@3
brew tap go-task/tap
brew install --cask copilot-cli docker-desktop go-task/tap/go-task
```

These commands install the available versions, not versions pinned to this
snapshot. The formula table includes explicitly requested packages, including
those that also serve as dependencies. Supporting packages are omitted because
Homebrew installs required dependencies automatically.

## Docker tooling

`docker` and `kubectl` are executable links in `/usr/local/bin` pointing into
`/Applications/Docker.app`. Docker Desktop also supplies launchers in
`~/.docker/bin`, including `docker-compose`.

The installed Docker CLI plugins in `~/.docker/cli-plugins` are:

```text
agent  ai  buildx  compose  debug  desktop  dhi  extension
init  mcp  model  offload  pass  sandbox  scout
```

Invoke them as `docker <plugin>`. `docker --version`, `docker compose version`,
`docker buildx version`, and `kubectl version --client=true` all succeeded.
The Kubernetes client also includes Kustomize. This confirms client tooling,
not a running Docker daemon or Kubernetes cluster.

## Other installed terminal-related components

These components were found outside Homebrew's installed package list.

| Component | Purpose / location |
| --- | --- |
| Oh My Zsh | Shell configuration and plugin framework at `~/.oh-my-zsh` |
| Powerlevel10k | Active Zsh prompt theme at `~/.oh-my-zsh/custom/themes/powerlevel10k` |
| Deja's Oh My Zsh integration | Custom plugin at `~/.oh-my-zsh/custom/plugins/deja`, alongside the Homebrew-installed tool |
| Oh my tmux! | gpakosz's tmux configuration at `~/.tmux.conf`, with overrides in `~/.tmux.conf.local` |
| Standalone mise | Executable at `~/.local/bin/mise`, used by `~/.zshrc`; separate from `/opt/homebrew/bin/mise` |
| Ghostty | Terminal application at `/Applications/Ghostty.app` |
| SauceCodePro Nerd Font | Patched Source Code Pro fonts in `~/Library/Fonts`; the repository's Ghostty config selects the Mono family |
| Visual Studio Code | Editor at `/Applications/Visual Studio Code.app`; `code` launcher at `/usr/local/bin/code` |
| VS Code's bundled ripgrep | Editor-private `rg` binary, separate from the Homebrew executable at `/opt/homebrew/bin/rg` |
| GitHub Copilot desktop app | `~/Applications/GitHub Copilot.app`, separate from the `copilot` CLI |
| Obsidian CLI | `obsidian` at `/usr/local/bin/obsidian`, linked into `/Applications/Obsidian.app` |
| Apple Command Line Tools | Installed at `/Library/Developer/CommandLineTools`; provides Clang, Swift, LLDB, Make, `xcrun`, and Apple's Python tooling |

The Homebrew commands above do not install these components, except for the
Homebrew copy of mise. Restore the apps, shell frameworks, and configuration
separately. Apple's Command Line Tools can be installed with `xcode-select --install`.

## System developer utilities

These developer utilities are available in `/usr/bin`. They come with macOS
and do not need separate Homebrew installation. This is not an exhaustive
inventory of base Unix commands.

| Commands | Purpose |
| --- | --- |
| `jq` | Query and transform JSON |
| `curl` | Transfer data over HTTP and other network protocols |
| `sqlite3` | SQLite database shell |
| `vim` | Terminal text editor |
| `ruby`, `gem`, `irb` | System Ruby interpreter, RubyGems package manager, and interactive Ruby shell |
| `bundle`, `bundler`, `rake` | Ruby dependency management and task runner |
| `rdoc`, `ri` | Generate and browse Ruby documentation |
| `perl` | Perl interpreter |

Homebrew also has `curl` and `sqlite` installed, but the unqualified `curl`
and `sqlite3` commands currently resolve to `/usr/bin`.

## VS Code extensions

`code --list-extensions` reported the following extensions. These are editor
components, not standalone installations of the tools or runtimes they support.

| Purpose | Extension IDs |
| --- | --- |
| Python, debugging, language analysis, and environments | `ms-python.python`, `ms-python.debugpy`, `ms-python.vscode-pylance`, `ms-python.vscode-python-envs` |
| Containers | `ms-azuretools.vscode-containers` |
| Remote development | `ms-vscode-remote.remote-ssh`, `ms-vscode-remote.remote-ssh-edit`, `ms-vscode-remote.remote-wsl`, `ms-vscode.remote-explorer` |
| PowerShell | `ms-vscode.powershell` |
| HTTP API client | `rangav.vscode-thunder-client` |
| Formatting, spelling, and diagnostics | `esbenp.prettier-vscode`, `streetsidesoftware.code-spell-checker`, `usernamehw.errorlens` |
| Editing helpers | `christian-kohler.path-intellisense`, `chunsen.bracket-select`, `geeebe.duplicate` |
| Themes and appearance | `dracula-theme.theme-dracula`, `johnpapa.vscode-peacock`, `vscode-icons-team.vscode-icons` |

Restore an extension with `code --install-extension <extension-id>`. This does
not restore editor settings or profile configuration.

## Active shell configuration

The active `~/.zshrc` enables:

```zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_TMUX_AUTOSTART="false"
plugins=(git docker kubectl python tmux macos deja)
```

It also sources `~/.p10k.zsh` when present and loads syntax highlighting from:

```zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

The shell initializes fzf and the standalone mise executable with:

```zsh
eval "$(fzf --zsh)"
eval "$("$HOME/.local/bin/mise" activate zsh)"
```

`FZF_DEFAULT_OPTS` configures a reverse layout and custom colors. Deja has
custom key bindings, including Ctrl-N to cycle suggestions.

The active `~/.zprofile` adds Docker's user CLI directory to PATH, then
initializes Homebrew. Written with `$HOME` in place of the local username:

```zsh
export PATH="$PATH:$HOME/.docker/bin"
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

The `/opt/homebrew` paths reflect this Mac's Homebrew installation. Adjust them
if Homebrew uses a different prefix on a future machine.

Git uses `delta` as its pager through `~/.gitconfig`. Ghostty reads
`~/.config/ghostty/config` and uses the custom Dracula theme file at
`~/.config/ghostty/themes/dracula`. On this Mac, it also reads
`~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`,
which repeats the font family and size settings.

## Configuration snapshots

These files capture the shell and terminal configuration as of 2026-11-04,
with the Ansible setup changes noted below:

| Repository file | Restore location | Contents |
| --- | --- | --- |
| [.zshrc](.zshrc) | `~/.zshrc` | Oh My Zsh plugins, Powerlevel10k loading, history, key bindings, fzf, and mise activation |
| [.zprofile](.zprofile) | `~/.zprofile` | Docker CLI PATH and Homebrew initialization |
| [.p10k.zsh](.p10k.zsh) | `~/.p10k.zsh` | Generated Powerlevel10k prompt with customized Dracula colors |
| [.tmux.conf](.tmux.conf) | `~/.tmux.conf` | Symlink to Oh my tmux! in the [vendor/oh-my-tmux](vendor/oh-my-tmux) submodule |
| [.tmux.conf.local](.tmux.conf.local) | `~/.tmux.conf.local` | Local tmux settings: Powerline separators, and `\|` instead of `_` for `split-window -h` |
| [Ghostty config](.config/ghostty/config) | `~/.config/ghostty/config` | Font family, size 14, and Dracula theme selection |
| [Ghostty Dracula theme](.config/ghostty/themes/dracula) | `~/.config/ghostty/themes/dracula` | Custom palette and terminal colors |
| [Ghostty native config](.config/ghostty/config.ghostty) | `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` | Comment-only file that leaves settings in the shared config |

On 2026-11-05, Oh my tmux! moved from a 2018 copy to a submodule pinned to
upstream commit `58a3dcc`. The 2018 copy had changed `_` to `|` directly in
`.tmux.conf`. [.tmux.conf.local](.tmux.conf.local) was rebuilt from the
current upstream template, and that binding moved there with the Powerline
separators.
The Zsh files use `$HOME`, detect Homebrew at its standard Apple Silicon or
Intel prefix, and activate Homebrew's mise. Deja key bindings are configured
before its plugin loads, and syntax highlighting loads last. Oh My Zsh
automatic updates are disabled because Ansible manages its pinned revision.
The repository's Ghostty config intentionally
uses `SauceCodePro Nerd Font Mono` instead of the live config's
`SourceCodePro Mono`, which is not the installed family name. The duplicate
macOS-specific Ghostty settings are consolidated into this one repository file.

The copied templates retain their upstream licenses:
[Oh My Zsh](licenses/oh-my-zsh-MIT.txt) and
[Powerlevel10k](licenses/powerlevel10k-MIT.txt). Oh my tmux! keeps its
[MIT](vendor/oh-my-tmux/LICENSE.MIT) and
[WTFPL](vendor/oh-my-tmux/LICENSE.WTFPLv2) licenses in its submodule.

### Source Code Pro Nerd Font

Nerd Fonts lists the patched Source Code Pro family as **SauceCodePro**.
The installed fonts report Nerd Fonts 3.5.1. Font binaries are not stored
in this repository.

1. Open the [Nerd Fonts downloads page](https://www.nerdfonts.com/font-downloads)
   and select SauceCodePro. To match this snapshot, use the
   [3.5.1 SourceCodePro archive](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/SourceCodePro.zip).
2. Extract the archive and install the `SauceCodeProNerdFontMono-*.ttf` files
   with macOS Font Book, or copy them into `~/Library/Fonts`. Include the
   regular, bold, italic, and bold italic styles; the other Mono weights
   can be installed too.
3. Use `font-family = "SauceCodePro Nerd Font Mono"` in Ghostty, as the
   repository config does. Restart Ghostty after installing the fonts.

### Restoring the configuration

Install the Homebrew tools above and Ghostty first. Restore Oh My Zsh at
`~/.oh-my-zsh`, Powerlevel10k at `~/.oh-my-zsh/custom/themes/powerlevel10k`,
and the Deja integration at `~/.oh-my-zsh/custom/plugins/deja`. These
frameworks and plugins are not included in the config snapshots.

On macOS, the repository Zsh config uses Homebrew's mise and syntax-highlighting
paths. On Ubuntu, it uses `/usr/bin/mise` and `/usr/share/zsh-syntax-highlighting`,
adds `~/.local/bin` to PATH, and omits the macOS plugin. Neither setup needs the
standalone mise executable. Install the font described above before using the
Ghostty config.

Back up existing files, then run these commands from the repository root.
`.tmux.conf` is a symlink into the Oh my tmux! submodule, so run
`git submodule update --init` first; `cp` copies the symlink's target.
`cp -i` prompts before overwriting an existing file:

```sh
cp -i .zshrc .zprofile .p10k.zsh .tmux.conf .tmux.conf.local "$HOME/"
mkdir -p "$HOME/.config/ghostty/themes"
cp -i .config/ghostty/config "$HOME/.config/ghostty/config"
cp -i .config/ghostty/themes/dracula "$HOME/.config/ghostty/themes/dracula"
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
cp -i .config/ghostty/config.ghostty "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
```

If `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`
already exists, back it up before replacing it with the comment-only file
above. Ghostty also loads this location; leftover settings can add fallback
font families or override the font size. Ansible makes this backup automatically.

Open a new terminal session after restoring. The repository copies do not
change the running Mac configuration until you install them. Manual copies
are not synchronized back to this repository. Ansible uses symlinks instead,
so edits through those links change the repository files.

## Accuracy and restoration notes

- With Homebrew first on PATH, `eza` and `rg` resolve to
  `/opt/homebrew/bin/eza` and `/opt/homebrew/bin/rg`. VS Code also bundles
  its own `rg`, so an editor session can resolve a different copy.
- `python3` and `pip3` currently resolve to `/usr/bin`, not Homebrew's Python.
  Use `python3.13` and `pip3.13` for the Homebrew installation. Similarly,
  `openssl` resolves to `/usr/bin/openssl`; use the explicit Homebrew path
  above for OpenSSL 3.
- Both mise installations report no managed runtimes. Restoring only the
  Homebrew package will not recreate `~/.local/bin/mise`. The repository
  shell initialization now uses the Homebrew copy instead.
- The global npm inventory contains only npm itself. Homebrew Python's package
  inventory contains only pip and wheel. No additional CLI tools were found
  in those package inventories.
- Only the shell and terminal configs listed above were refreshed. Git and
  editor configs were not copied, and unrelated repository files were left
  as they were.
- The restored shell uses `fzf --zsh`; it does not source the repository's
  legacy `.fzf.zsh` file or the old `.addons` directory.
- Credentials, shell history, application state, font binaries, and installed
  framework or plugin directories are not part of this configuration backup.
