#!/bin/bash

#Nettoyer les ressources Docker
function clean_docker_resources() {
    selected=$(printf "📦 Containers\n🗂️ Images\n💾 Volumes\n🗑️ Tout\n↩️ Retour" | fzf -m --height=40% --layout=reverse --border --prompt="Quelles ressources Docker voulez-vous supprimer ? > ")
    
    if [[ "$selected" == "↩️ Retour" ]]; then
        main
        return
    fi

    echo "🧨 Nettoyage en cours..."

    while IFS= read -r opt; do
        case "$opt" in
            "📦 Containers")  manage_docker_containers ;;
            "🗂️ Images") manage_docker_images ;;
            "💾 Volumes") manage_docker_volumes ;;
            "🗑️ Tout") docker system prune -a --volumes -f ;;
        esac
    done <<< "$selected"

    main
}

# Container Docker
function manage_docker_containers() {
    echo "📋 Récupération des containers disponibles..."
    
    docker ps -a --format '{{.ID}}|{{.Names}} ({{.Status}})' > /tmp/docker_containers_list.txt

    if [[ ! -s /tmp/docker_containers_list.txt ]]; then
        echo "❌ Aucun container Docker trouvé."
        clean_docker_resources
        return
    fi

    display_list=$(awk -F"|" '{print $2}' /tmp/docker_containers_list.txt)
    
    selected=$(echo -e "🗑️ Tout\n↩️ Retour\n$display_list" | fzf -m --height=40% --layout=reverse --border --prompt="Choisissez les containers à supprimer > ")

    if [[ "$selected" == "↩️ Retour" ]]; then
        clean_docker_resources
        return
    fi

    if [[ "$selected" == "🗑️ Tout" ]]; then
        echo "🧨 Suppression de tous les containers..."
        docker rm $(docker ps -aq) -f
        clean_docker_resources
        return
    fi

    echo "🧽 Suppression des containers sélectionnés..."

    while IFS= read -r line; do
        container_id=$(grep "$line" /tmp/docker_containers_list.txt | cut -d"|" -f1)
        
        if [[ -n "$container_id" ]]; then
            echo "🗑️ Suppression de : $line (ID: $container_id)"
            docker rm "$container_id" -f
        fi
    done <<< "$selected"

    clean_docker_resources
}

# Volumes Docker
function manage_docker_volumes() {
    echo "📋 Récupération des volumes disponibles..."
    
    docker volume ls --format '{{.Name}}|{{.Driver}}' > /tmp/docker_volumes_list.txt

    if [[ ! -s /tmp/docker_volumes_list.txt ]]; then
        echo "❌ Aucun volume Docker trouvé."
        clean_docker_resources
        return
    fi

    display_list=$(awk -F"|" '{print $1}' /tmp/docker_volumes_list.txt)
    
    selected=$(echo -e "🗑️ Tout\n↩️ Retour\n$display_list" | fzf -m --height=40% --layout=reverse --border --prompt="Choisissez les volumes à supprimer > ")

    if [[ "$selected" == "↩️ Retour" ]]; then
        clean_docker_resources
        return
    fi

    if [[ "$selected" == "🗑️ Tout" ]]; then
        echo "🧨 Suppression de tous les volumes..."
        docker volume rm $(docker volume ls -q)
        clean_docker_resources
        return
    fi

    echo "🧽 Suppression des volumes sélectionnés..."

    while IFS= read -r volume; do
        if [[ -n "$volume" ]]; then
            echo "🗑️ Suppression du volume : $volume"
            docker volume rm "$volume"
        fi
    done <<< "$selected"

    clean_docker_resources
}

# Images Docker
function manage_docker_images() {
    echo "📋 Récupération des images disponibles..."
    
    docker images --format '{{.ID}}|{{.Repository}}:{{.Tag}} ({{.Size}})' > /tmp/docker_images_list.txt

    if [[ ! -s /tmp/docker_images_list.txt ]]; then
        echo "❌ Aucune image Docker trouvée."
        clean_docker_resources
        return
    fi

    display_list=$(awk -F"|" '{print $2}' /tmp/docker_images_list.txt)
    
    selected=$(echo -e "🗑️ Tout\n↩️ Retour\n$display_list" | fzf -m --height=40% --layout=reverse --border --prompt="Choisissez les images à supprimer > ")

    if [[ "$selected" == "↩️ Retour" ]]; then
        clean_docker_resources
        return
    fi

    if [[ "$selected" == "🗑️ Tout" ]]; then
        echo "🧨 Suppression de toutes les images..."
        docker rmi $(docker images -q) -f
        clean_docker_resources
        return
    fi

    echo "🧽 Suppression des images sélectionnées..."

    while IFS= read -r line; do
        image_id=$(grep "$line" /tmp/docker_images_list.txt | cut -d"|" -f1)
        
        if [[ -n "$image_id" ]]; then
            echo "🗑️ Suppression de : $line (ID: $image_id)"
            docker rmi "$image_id"
        fi
    done <<< "$selected"

    clean_docker_resources
}

# Docker Compose
function manage_docker_compose() {
  echo "🚧 Fonctionnalité en cours de construction..."
  selected=$(printf "↩️ Retour" | fzf --height=40% --layout=reverse --border --prompt="Cette fonctionnalité n'est pas encore disponible.\n Que voulez-vous faire ? > ")

  if [[ "$selected" == "↩️ Retour" ]]; then
    main
    return
  fi
}

# Quitter le programme
function exit_program() {
    echo "👋 À bientôt !"
    exit 0
}

function main() {
    echo "👋 Bonjour ! Que voulez-vous faire ?"

    main_action=$(printf "🗑️ Supprimer\n🐳 Docker-Compose\n🚪 Quitter" | fzf --height=40% --layout=reverse --border --prompt="Choisissez une action > ")

    case "$main_action" in
        "🗑️ Supprimer")
            clean_docker_resources
            ;;
        "🐳 Docker-Compose")
            manage_docker_compose
            ;;
        "Quitter")
            exit_program
            ;;
        *)
            echo "❌ Action inconnue. Bye."
            exit 1
            ;;
    esac
}

main