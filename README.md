# Docker Helper 🐳

![Docker Logo](https://www.docker.com/wp-content/uploads/2022/03/Moby-logo.png)
![License: MIT](https://img.shields.io/badge/license-MIT-blue)
![Shell Script](https://img.shields.io/badge/script-bash-yellow?logo=gnubash)

An interactive command-line tool to simplify the management of your Docker resources.

## 💡 Why Docker Helper?

Born out of frustration with repetitive Docker tasks, this tool addresses:
* Tedious searches for container/image IDs
* Typing long Docker commands
* Risk of errors during system cleanup
* Wasting time on routine tasks

## 📋 Key Features

* 📦 Intuitive Docker container management
* 🗂️ Smart image cleanup
* 💾 Volume organization
* 🎯 Interactive interface with fzf
* 🔄 Multi-distribution Linux compatibility

## ⚙️ Prerequisites

* Docker Engine installed
* fzf (automatic installation offered)
* Supported Linux systems:
    * Debian/Ubuntu (apt)
    * RHEL/CentOS (yum/dnf)
    * Arch Linux (pacman)


---

## ⚙️ Installation

**curl :**

```bash
curl -fsSL https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/install.sh | sh
````

**wget :**

```bash
wget -qO- https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/install.sh | sh
```

---

## 🧹 Désinstallation / Uninstallation

**curl :**

```bash
curl -fsSL https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/uninstall.sh | sh
```

**wget :**

```bash
wget -qO- https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/uninstall.sh | sh
```

---


## 🚀 Manual Installation Guide

1. Clone the project:
        ```bash
        git clone https://github.com/Baabacar/docker-helper.git
        cd docker-helper
        ```

2. Configuration:
        ```bash
        chmod +x docker-helper.sh
        ```

## 📖 Usage Guide

### Quick Start
```bash
./docker-helper.sh
```

### Main Menu

| Command | Action |
|---------|--------|
| 🗑️ Delete | Manage/Delete Docker resources |
| 🐳 Publish Images | Push multiple Docker images at once to Docker Hub or any other OCI-compatible registry. |
| 🚪 Exit | Exit the program |

### Practical Examples

#### Container Cleanup
```bash
# Classic method
docker ps -a
docker rm -f $(docker ps -aq)

# With Docker Helper
./docker-helper.sh
# → 🗑️ Delete → 📦 Containers → Select → Enter
```

#### Image Management
```bash
# Classic method
docker images
docker rmi <image-id>

# With Docker Helper
./docker-helper.sh
# → 🗑️ Delete → 🗂️ Images → Select → Enter
```

## 🎯 Roadmap

<input disabled="" type="checkbox"> Advanced Docker Compose support  <br/>
<input disabled="" type="checkbox"> Lightweight web interface <br/>
<input disabled="" type="checkbox"> Real-time monitoring <br/>
<input disabled="" type="checkbox"> Docker network management <br/>
<input disabled="" type="checkbox"> Automation mode (batch) <br/>

## 🤝 Contribution

1. Fork the project
2. Create a branch
        ```bash
        git checkout -b feature/new-feature
        ```

3. Commit
        ```bash
        git commit -m 'feat: clear description'
        ```

4. Push
        ```bash
        git push origin feature/new-feature
        ```

### Code Convention

```bash
# Typical function structure
function descriptive_name() {
        echo "🔄 Processing..."
        
        # Error handling
        if [[ $? -ne 0 ]]; then
                echo "❌ Error: Description"
                return 1
        fi
}
```


---

## 🌐 Language / Langue

For more details about the project, please read the README in your preferred language:

Pour plus de détails sur le projet, veuillez lire le README dans votre langue préférée :

* [English / Anglais](docs/README.en.md)
* [Français / French](docs/README.fr.md)

---


## 👤 Authors

* **Babacar Ndiaye** – [GitHub Profile](https://github.com/Baabacar)

## 👥 Contributors

* [Betzalel75](https://github.com/Betzalel75)

## 📄 License / Licence

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus d'informations.

## 💭 Quote

> "Be curious and never stop searching!" - Babacar Ndiaye

---

[⬆️ Back to top](#docker-helper-)