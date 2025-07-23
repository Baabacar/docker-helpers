
## 🇬🇧 `README.en.md`


# Docker Helpers Scripts 🐳

A collection of useful scripts to simplify Docker management tasks including image publishing, container/volume/image cleanup, and more.

![Docker Logo](https://www.docker.com/wp-content/uploads/2022/03/vertical-logo-monochromatic.png)

## Features ✨

- **Interactive Docker Image Publishing** 📤
  - Select multiple local images to publish
  - Customize registry, username and tag
  - Dry-run mode available
  - Comprehensive progress reporting

- **Docker Resource Cleanup** 🧹
  - Interactive selection of resources to delete
  - Manage containers, images, and volumes
  - Option to delete all resources or specific ones
  - Safety prompts before destructive actions

- **User-Friendly Interface** 🖥️
  - Color-coded output for better visibility
  - Interactive menus using `fzf`
  - Verbose mode for debugging
  - Cross-platform support (Linux, macOS, Windows)

## Installation ⚙️

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/install.sh | bash
```

### Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Baabacar/docker-helpers.git
   ```

2. Make the scripts executable:
   ```bash
   chmod +x docker-helpers/scripts/*.sh
   ```

3. Add to your PATH or run directly:
   ```bash
   sudo ln -s $(pwd)/docker-helpers/scripts/docker-helper.sh /usr/local/bin/docker-helper
   ```

## Usage 🚀

Run the main script:
```bash
docker-helper
```

You'll see an interactive menu with these options:

1. **🐳 Publish Images** - Publish local images to a Docker registry
2. **🗑️ Delete** - Clean up Docker resources (containers, images, volumes)
3. **🚪 Exit** - Quit the program

### Publish Images Workflow

1. Enter your Docker registry username
2. Select images from an interactive list
3. Choose a tag (default: latest)
4. Optionally enable dry-run mode
5. Review summary and confirm
6. Script handles tagging and pushing automatically

### Cleanup Workflow

1. Choose resource type (Containers, Images, Volumes)
2. Select specific items or "All"
3. Confirm deletion
4. Script performs cleanup and returns to main menu

## Requirements 📋

- Docker installed and running
- `fzf` (fuzzy finder) - will be installed automatically if missing
- Bash 4.0 or newer

## Uninstallation 🗑️

To remove the scripts:

```bash
curl -fsSL https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/uninstall.sh | bash
```

Or manually:
```bash
rm -f ~/.local/bin/docker-helper.sh
```

## License 📄

MIT License - see [LICENSE](../LICENSE) for details.

---

Made with ❤️ by [Betzalel75]

