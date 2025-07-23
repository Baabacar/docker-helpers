#!/bin/bash


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
# Default variables
PUBLISH_USERNAME="" 
PUBLISH_TAG="latest"
PUBLISH_REGISTRY=""
DRY_RUN=false
VERBOSE=false
IMAGES=()

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

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
    log_warning "❌ fzf is not installed on your system."
    read -p "📥 Do you want to install fzf now? (y/n): " choice
    
    OS=$(check_os)
    case "$choice" in
      y|Y|yes|YES)
        log "🚀 Installing fzf for $OS..."
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
              log_error "❌ Manual installation required for your Linux distribution."
              log "📝 Follow the instructions: https://github.com/junegunn/fzf#installation"
              exit 1
            fi
            ;;
          "MAC")
            if command -v brew &> /dev/null; then
              brew install fzf
              # Install keyboard shortcuts
              $(brew --prefix)/opt/fzf/install
            else
              log_error "❌ Homebrew is not installed."
              log "📝 Install Homebrew first: https://brew.sh"
              exit 1
            fi
            ;;
          "WINDOWS")
              if command -v scoop &> /dev/null; then
                  # Check for admin rights
                  if [[ "$(id -u)" != "0" ]]; then
                      log_warning "🔐 Requesting administrator privileges..."
                      powershell.exe -Command "Start-Process scoop -Verb RunAs -ArgumentList 'install fzf' -Wait"
                  else
                      scoop install fzf
                  fi
              elif command -v choco &> /dev/null; then
                  # Chocolatey always requires admin rights
                  log_warning "🔐 Requesting administrator privileges..."
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
            log_error "❌ Unsupported operating system."
            log "📝 Manual installation: https://github.com/junegunn/fzf#installation"
            exit 1
            ;;
        esac
        ;;
      *)
        log_error "❌ fzf is required to use this script."
        log "📝 More information: https://github.com/junegunn/fzf#installation"
        exit 1
        ;;
    esac
  fi
}

function show_single_choice() {
    local custom_prompt="$1"
    shift 
    local items=("$@") 

    local final_prompt="$custom_prompt"
    if [[ -z "$final_prompt" ]]; then
        final_prompt="Choose an action > " 
    fi

    local selected_item

    selected_item=$(printf "%s\n" "${items[@]}" | fzf \
        --height=40% \
        --layout=reverse \
        --border \
        --prompt="$final_prompt")

    echo "$selected_item"
}

function show_checkboxes() {
    local items=("$@")
    local selected=()

    local selected_items=$(printf "%s\n" "${items[@]}" | fzf \
        --multi \
        --height=40% \
        --layout=reverse \
        --border \
        --prompt="Select items (Tab/Space to toggle, Enter to confirm) > " \
        --bind 'space:toggle' \
        --preview 'echo "Selected items:"; echo {}' \
        --preview-window=right:30%:wrap)

    while IFS= read -r line; do
        selected+=("$line")
    done <<< "$selected_items"
    
    printf "%s\n" "${selected[@]}"
}

# Clean Docker resources
function clean_docker_resources() {
  local prompt_message="Which Docker resources do you want to delete? > "
      local options=("📦 Containers" "🗂️ Images" "💾 Volumes" "↩️ Back")
      
      local selected=$(show_single_choice "$prompt_message" "${options[@]}")
  
  if [[ "$selected" == "↩️ Back" ]]; then
    main
    return
  fi

  log "🧨 Cleaning in progress..."

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
  log "📋 Fetching available containers..."
  
  docker ps -a --format '{{.ID}}|{{.Names}} ({{.Status}})' > /tmp/docker_containers_list.txt

  if [[ ! -s /tmp/docker_containers_list.txt ]]; then
    log "❌ No Docker containers found."
    clean_docker_resources
    return
  fi

  local containers=()
  while IFS= read -r line; do
    containers+=("$(echo "$line" | cut -d"|" -f2)")
  done < /tmp/docker_containers_list.txt
  
  local options=("🗑️ All" "↩️ Back" "${containers[@]}")
  local selected=$(show_checkboxes "${options[@]}")
  
  if [[ "$selected" == *"↩️ Back"* ]]; then
    clean_docker_resources
    return
  fi

  if [[ "$selected" == *"🗑️ All"* ]]; then
    log_warning "🧨 Deleting all containers..."
    docker rm $(docker ps -aq) -f
    clean_docker_resources
    return
  fi

  log "🧽 Deleting selected containers..."

  for line in $selected; do
    container_id=$(grep "$line" /tmp/docker_containers_list.txt | cut -d"|" -f1)
    
    if [[ -n "$container_id" ]]; then
      log "🗑️ Deleting: $line (ID: $container_id)"
      docker rm "$container_id" -f
    fi
  done

  clean_docker_resources
}

# Docker Volumes
function manage_docker_volumes() {
  log "📋 Fetching available volumes..."
  
  docker volume ls --format '{{.Name}}|{{.Driver}}' > /tmp/docker_volumes_list.txt

  if [[ ! -s /tmp/docker_volumes_list.txt ]]; then
    log "❌ No Docker volumes found."
    clean_docker_resources
    return
  fi

  local volumes=()
  while IFS= read -r line; do
    volumes+=("$(echo "$line" | cut -d"|" -f1)")
  done < /tmp/docker_volumes_list.txt
  
  local options=("🗑️ All" "↩️ Back" "${volumes[@]}")
  local selected=$(show_checkboxes "${options[@]}")
  
  if [[ "$selected" == *"↩️ Back"* ]]; then
    clean_docker_resources
    return
  fi

  if [[ "$selected" == *"🗑️ All"* ]]; then
    log_warning "🧨 Deleting all volumes..."
    docker volume rm $(docker volume ls -q)
    clean_docker_resources
    return
  fi

  log "🧽 Deleting selected volumes..."

  for volume in $selected; do
    if [[ -n "$volume" ]]; then
      log "🗑️ Deleting volume: $volume"
      docker volume rm "$volume"
    fi
  done

  clean_docker_resources
}

# Docker Images
function manage_docker_images() {
  log "📋 Fetching available images..."
  
  docker images --format '{{.ID}}|{{.Repository}}:{{.Tag}} ({{.Size}})' > /tmp/docker_images_list.txt

  if [[ ! -s /tmp/docker_images_list.txt ]]; then
    log "❌ No Docker images found."
    clean_docker_resources
    return
  fi

  local images=()
  while IFS= read -r line; do
    images+=("$(echo "$line" | cut -d"|" -f2)")
  done < /tmp/docker_images_list.txt
  
  local options=("🗑️ All" "↩️ Back" "${images[@]}")
  local selected=$(show_checkboxes "${options[@]}")
  
  if [[ "$selected" == *"↩️ Back"* ]]; then
    clean_docker_resources
    return
  fi

  if [[ "$selected" == *"🗑️ All"* ]]; then
    log_warning "🧨 Deleting all images..."
    docker rmi $(docker images -q) -f
    clean_docker_resources
    return
  fi

  log "🧽 Deleting selected images..."

  for line in $selected; do
    image_id=$(grep "$line" /tmp/docker_images_list.txt | cut -d"|" -f1)
    
    if [[ -n "$image_id" ]]; then
      log "🗑️ Deleting: $line (ID: $image_id)"
      docker rmi "$image_id"
    fi
  done

  clean_docker_resources
}

# Docker Compose
function manage_docker_compose() {
  log "🚧 Feature under construction..."
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

# Docker registry manager
# Check Docker installation and status
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé."
        return 1 
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker n'est pas en cours d'exécution."
        return 1 
    fi
    return 0
}
# Check docker login
check_docker_login_status() {
    local username_to_check="$1"
    if docker info | grep -q "Username: ${username_to_check}"; then
        return 0
    fi
    
    if docker info | grep -q "Username"; then
        log_warning "Vous êtes connecté à Docker Hub avec un autre compte."
        log "Veuillez vous déconnecter ('docker logout') ou re-vous connecter avec '$username_to_check'."
        return 1
    fi
    return 1
}

# Tag images
tag_image() {
    local source_image=$1
    local target_image=$2
    local dry_run_mode=$3 

    log_verbose "Tagging $source_image as $target_image"

    if [ "$dry_run_mode" = true ]; then
        log "DRY RUN: docker tag $source_image $target_image"
        return 0
    fi

    if docker tag "$source_image" "$target_image"; then
        log_verbose "Successfully tagged $source_image as $target_image"
        return 0
    else
        log_error "Failed to tag $source_image as $target_image"
        return 1
    fi
}

# Push images
push_image() {
    local image=$1
    local dry_run_mode=$2

    log "Pushing $image..."

    if [ "$dry_run_mode" = true ]; then
        log "DRY RUN: docker push $image"
        return 0
    fi

    if docker push "$image"; then
        log_success "Successfully pushed $image"
        return 0
    else
        log_error "Failed to push $image"
        return 1
    fi
}

# Publisher
function manage_docker_publish() {
    log "🚀 Managing Docker Image Publishing..."

    # 1. Check Docker
    if ! check_docker; then
        main 
        return
    fi

    # 2.0 Ask for the Docker Registry username
    read -p "Please enter your Docker Hub registry (or leave empty to use Docker Hub): " PUBLISH_REGISTRY
    if [[ -z "$PUBLISH_REGISTRY" ]]; then
        PUBLISH_REGISTRY="docker.io"
    fi
    
    # 2.1 Ask for the registry
    read -p "Please enter your Docker Hub username (or leave empty to cancel): " PUBLISH_USERNAME
    if [[ -z "$PUBLISH_USERNAME" ]]; then
        log_warning "🚫 Docker Hub username not provided. Returning to main menu."
        main
        return
    fi
   
    # 3. Check Docker Hub connection with the provided username
    if ! check_docker_login_status "$PUBLISH_USERNAME"; then
        log_warning "Vous n'êtes pas actuellement connecté à Docker Hub avec le compte '$PUBLISH_USERNAME'."
        log "Veuillez vous connecter manuellement (docker login) ou assurez-vous que les informations d'identification sont configurées."
        read -p "Continue anyway? (y/N): " confirm_continue
        if [[ ! "$confirm_continue" =~ ^[Yy]$ ]]; then
            log "Opération annulée. Retour au menu principal."
            main
            return
        fi
    fi

    # 4. List locally available images
    log "📋 Fetching local Docker images..."
    # Exclude images with `<none>:<none>` tags or base images (like untagged busybox, alpine, etc.)
    # Format "REPOSITORY:TAG"
    local local_images_raw=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -v '<none>:<none>' | grep -v '^<none>:' | sort -u)

    local images_to_select=()
    while IFS= read -r line; do
        if [[ "$line" != "busybox:latest" && "$line" != "alpine:latest" && "$line" != "hello-world:latest" ]]; then
            images_to_select+=("$line")
        fi
    done <<< "$local_images_raw"

    if [ ${#images_to_select[@]} -eq 0 ]; then
        log_warning "❌ No suitable Docker images found locally to publish."
        main
        return
    fi

    # 5. Select images to publish using fzf (multi-selection)
    local selected_images=$(show_checkboxes "${images_to_select[@]}")

    if [[ -z "$selected_images" ]]; then
        log_warning "🚫 No images selected for publishing. Returning to main menu."
        main
        return
    fi

    # 6. Ask for an optional tag
    read -p "Enter a tag for the images (default: $PUBLISH_TAG): " user_tag
    if [[ -n "$user_tag" ]]; then
        PUBLISH_TAG="$user_tag"
    fi

    # 7. Ask if it's a dry-run
    read -p "Perform a dry run? (y/N): " dry_run_choice
    if [[ "$dry_run_choice" =~ ^[Yy]$ ]]; then
        DRY_RUN=true
    else
        DRY_RUN=false
    fi

    # 8. Display summary and request final confirmation
    log "=== PUBLISH SUMMARY ==="
    log "Registry: $PUBLISH_REGISTRY"
    log "Username: $PUBLISH_USERNAME"
    log "Tag: $PUBLISH_TAG"
    log "Images to publish: $(echo "$selected_images" | wc -l)"
    log "Selected images:"
    while IFS= read -r img; do
        IMAGES+=("$img")
        log "  - $img"
    done <<< "$selected_images"
    if [ "$DRY_RUN" = true ]; then
        log_warning "MODE DRY RUN - No actions will be performed."
    fi
    echo ""

    if [ "$DRY_RUN" = false ]; then
        read -p "Continue with publishing? (y/N): " confirm_publish
        if [[ ! "$confirm_publish" =~ ^[Yy]$ ]]; then
            log "Publishing cancelled. Returning to main menu."
            main
            return
        fi
    fi

    # 9. Process selected images
    local success_count=0
    local failed_images=()

    log "=== STARTING PUBLISH PROCESS ==="

    for image in "${IMAGES[@]}"; do
        if [[ -z "$image" ]]; then
            continue
        fi
    
        log "Processing image: $image"
    
        local base_image_name=$(echo "$image" | cut -d':' -f1)
    
        local target_image_with_tag="$PUBLISH_REGISTRY/$PUBLISH_USERNAME/$base_image_name:$PUBLISH_TAG"
    
        log_verbose "Target image: $target_image_with_tag"
    
        if ! tag_image "$image" "$target_image_with_tag" "$DRY_RUN"; then
            failed_images+=("$image")
            continue
        fi
    
        if push_image "$target_image_with_tag" "$DRY_RUN"; then
            ((success_count++))
        else
            failed_images+=("$image")
        fi
        echo ""
    done


    # 10. Final summary
    log "=== PUBLISH SUMMARY ==="
    log_success "Images successfully pushed: $success_count/$(echo "$selected_images" | wc -l)"

    if [ ${#failed_images[@]} -gt 0 ]; then
        log_error "Failed images: ${#failed_images[@]}"
        for failed_img in "${failed_images[@]}"; do
            log_error "  - $failed_img"
        done
    else
        log_success "All selected images pushed successfully!"
    fi

    main
}

function main() {
  check_fzf

    local prompt_message="👋 Hello! What would you like to do? --- Choose an action > "
    local options=("🐳 Publish Images" "🗑️ Delete" "🚪 Exit")
    local selected=$(show_single_choice "$prompt_message" "${options[@]}")
  
    case "$selected" in
      "🐳 Publish Images")
        manage_docker_publish
        ;;
      "🗑️ Delete")
        clean_docker_resources
        ;;
      "🚪 Exit")
        exit_program
        ;;
      *)
      if [[ -z "$selected" ]]; then
          log "🚫 No action selected. Exiting."
      else
          log_error "❌ Unknown action: '$selected'. Exiting."
      fi
      exit 1
      ;;
    esac
}

VERBOSE=false
DRY_RUN=false

main