#!/bin/bash

function check_os() {
  case "$(uname -s)" in
    Linux*)     echo "LINUX";;
    Darwin*)    echo "MAC";;
    CYGWIN*)    echo "WINDOWS";;
    MINGW*)    echo "WINDOWS";;
    *)         echo "UNKNOWN";;
  esac
}

function check_fzf() {
  if ! command -v fzf &> /dev/null; then
    echo "❌ fzf is not installed on your system."
    read -p "📥 Do you want to install fzf now? (y/n): " choice
    
    OS=$(check_os)
    case "$choice" in
      y|Y|yes|YES)
        echo "🚀 Installing fzf for $OS..."
        case "$OS" in
          "LINUX")
            if command -v apt &> /dev/null; then
              sudo apt update && sudo apt install -y fzf
            elif command -v dnf &> /dev/null; then
              sudo dnf install -y fzf
            elif command -v yum &> /dev/null; then
              sudo yum install -y fzf
            elif command -v pacman &> /dev/null; then
              sudo pacman -S fzf
            else
              echo "❌ Manual installation required for your Linux distribution."
              echo "📝 Follow the instructions: https://github.com/junegunn/fzf#installation"
              exit 1
            fi
            ;;
          "MAC")
            if command -v brew &> /dev/null; then
              brew install fzf
              # Install keyboard shortcuts
              $(brew --prefix)/opt/fzf/install
            else
              echo "❌ Homebrew is not installed."
              echo "📝 Install Homebrew first: https://brew.sh"
              exit 1
            fi
            ;;
          "WINDOWS")
              if command -v scoop &> /dev/null; then
                  # Check for admin rights
                  if [[ "$(id -u)" != "0" ]]; then
                      echo "🔐 Requesting administrator privileges..."
                      powershell.exe -Command "Start-Process scoop -Verb RunAs -ArgumentList 'install fzf' -Wait"
                  else
                      scoop install fzf
                  fi
              elif command -v choco &> /dev/null; then
                  # Chocolatey always requires admin rights
                  echo "🔐 Requesting administrator privileges..."
                  powershell.exe -Command "Start-Process chocolatey -Verb RunAs -ArgumentList 'install fzf -y' -Wait"
              else
                  echo "❌ Manual installation required for Windows."
                  echo "📝 Installation options:"
                  echo "1. Scoop (recommended):"
                  echo "   - Open PowerShell as administrator"
                  echo "   - Set-ExecutionPolicy RemoteSigned -scope CurrentUser"
                  echo "   - iwr -useb get.scoop.sh | iex"
                  echo "   - scoop install fzf"
                  echo "2. Chocolatey:"
                  echo "   - Open PowerShell as administrator"
                  echo "   - choco install fzf -y"
                  echo "3. Manual: https://github.com/junegunn/fzf#windows"
                  exit 1
              fi
              ;;
          *)
            echo "❌ Unsupported operating system."
            echo "📝 Manual installation: https://github.com/junegunn/fzf#installation"
            exit 1
            ;;
        esac
        ;;
      *)
        echo "❌ fzf is required to use this script."
        echo "📝 More information: https://github.com/junegunn/fzf#installation"
        exit 1
        ;;
    esac
  fi
}

# Clean Docker resources
function clean_docker_resources() {
  selected=$(printf "📦 Containers\n🗂️ Images\n💾 Volumes\n🗑️ All\n↩️ Back" | fzf -m --height=40% --layout=reverse --border --prompt="Which Docker resources do you want to delete? > ")
  
  if [[ "$selected" == "↩️ Back" ]]; then
    main
    return
  fi

  echo "🧨 Cleaning in progress..."

  while IFS= read -r opt; do
    case "$opt" in
      "📦 Containers")  manage_docker_containers ;;
      "🗂️ Images") manage_docker_images ;;
      "💾 Volumes") manage_docker_volumes ;;
      "🗑️ All") docker system prune -a --volumes -f ;;
    esac
  done <<< "$selected"

  main
}

# Docker Containers
function manage_docker_containers() {
  echo "📋 Fetching available containers..."
  
  docker ps -a --format '{{.ID}}|{{.Names}} ({{.Status}})' > /tmp/docker_containers_list.txt

  if [[ ! -s /tmp/docker_containers_list.txt ]]; then
    echo "❌ No Docker containers found."
    clean_docker_resources
    return
  fi

  display_list=$(awk -F"|" '{print $2}' /tmp/docker_containers_list.txt)
  
  selected=$(echo -e "🗑️ All\n↩️ Back\n$display_list" | fzf -m --height=40% --layout=reverse --border --prompt="Select containers to delete > ")

  if [[ "$selected" == "↩️ Back" ]]; then
    clean_docker_resources
    return
  fi

  if [[ "$selected" == "🗑️ All" ]]; then
    echo "🧨 Deleting all containers..."
    docker rm $(docker ps -aq) -f
    clean_docker_resources
    return
  fi

  echo "🧽 Deleting selected containers..."

  while IFS= read -r line; do
    container_id=$(grep "$line" /tmp/docker_containers_list.txt | cut -d"|" -f1)
    
    if [[ -n "$container_id" ]]; then
      echo "🗑️ Deleting: $line (ID: $container_id)"
      docker rm "$container_id" -f
    fi
  done <<< "$selected"

  clean_docker_resources
}

# Docker Volumes
function manage_docker_volumes() {
  echo "📋 Fetching available volumes..."
  
  docker volume ls --format '{{.Name}}|{{.Driver}}' > /tmp/docker_volumes_list.txt

  if [[ ! -s /tmp/docker_volumes_list.txt ]]; then
    echo "❌ No Docker volumes found."
    clean_docker_resources
    return
  fi

  display_list=$(awk -F"|" '{print $1}' /tmp/docker_volumes_list.txt)
  
  selected=$(echo -e "🗑️ All\n↩️ Back\n$display_list" | fzf -m --height=40% --layout=reverse --border --prompt="Select volumes to delete > ")

  if [[ "$selected" == "↩️ Back" ]]; then
    clean_docker_resources
    return
  fi

  if [[ "$selected" == "🗑️ All" ]]; then
    echo "🧨 Deleting all volumes..."
    docker volume rm $(docker volume ls -q)
    clean_docker_resources
    return
  fi

  echo "🧽 Deleting selected volumes..."

  while IFS= read -r volume; do
    if [[ -n "$volume" ]]; then
      echo "🗑️ Deleting volume: $volume"
      docker volume rm "$volume"
    fi
  done <<< "$selected"

  clean_docker_resources
}

# Docker Images
function manage_docker_images() {
  echo "📋 Fetching available images..."
  
  docker images --format '{{.ID}}|{{.Repository}}:{{.Tag}} ({{.Size}})' > /tmp/docker_images_list.txt

  if [[ ! -s /tmp/docker_images_list.txt ]]; then
    echo "❌ No Docker images found."
    clean_docker_resources
    return
  fi

  display_list=$(awk -F"|" '{print $2}' /tmp/docker_images_list.txt)
  
  selected=$(echo -e "🗑️ All\n↩️ Back\n$display_list" | fzf -m --height=40% --layout=reverse --border --prompt="Select images to delete > ")

  if [[ "$selected" == "↩️ Back" ]]; then
    clean_docker_resources
    return
  fi

  if [[ "$selected" == "🗑️ All" ]]; then
    echo "🧨 Deleting all images..."
    docker rmi $(docker images -q) -f
    clean_docker_resources
    return
  fi

  echo "🧽 Deleting selected images..."

  while IFS= read -r line; do
    image_id=$(grep "$line" /tmp/docker_images_list.txt | cut -d"|" -f1)
    
    if [[ -n "$image_id" ]]; then
      echo "🗑️ Deleting: $line (ID: $image_id)"
      docker rmi "$image_id"
    fi
  done <<< "$selected"

  clean_docker_resources
}

# Docker Compose
function manage_docker_compose() {
  echo "🚧 Feature under construction..."
  selected=$(printf "↩️ Back" | fzf --height=40% --layout=reverse --border --prompt="This feature is not yet available.\n What do you want to do? > ")

  if [[ "$selected" == "↩️ Back" ]]; then
  main
  return
  fi
}

# Exit the program
function exit_program() {
  echo "👋 See you soon!"
  exit 0
}

function main() {
  check_fzf

  echo "👋 Hello! What would you like to do?"

  main_action=$(printf "🗑️ Delete\n🐳 Docker-Compose\n🚪 Exit" | fzf --height=40% --layout=reverse --border --prompt="Choose an action > ")

  case "$main_action" in
    "🐳 Docker-Compose")
      manage_docker_compose
      ;;
    "🗑️ Delete")
      clean_docker_resources
      ;;
    "🚪 Exit")
      exit_program
      ;;
    *)
      echo "❌ Unknown action. Bye."
      exit 1
      ;;
  esac
}

main