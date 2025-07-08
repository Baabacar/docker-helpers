#!/bin/bash

# # Vérifie si fzf est installé
# if ! command -v fzf &> /dev/null; then
#     echo "⚠️  fzf n'est pas installé. Installe-le avec : sudo apt install fzf"
#     exit 1
# fi

# clear
echo "👋 Bonjour ! Que voulez-vous faire ?"

main_action=$(printf "🧹 Supprimer\n📦 Images Docker\n🚪 Quitter" | fzf --height=40% --layout=reverse --border --prompt="Choisissez une action > ")

case "$main_action" in
  "🧹 Supprimer")
    selected=$(printf "Containers\nImages\nVolumes\nTout" | fzf -m  --height=40% --layout=reverse --border --prompt="Quelles ressources Docker voulez-vous supprimer ? > ")
    echo "🧨 Nettoyage en cours..."

    for opt in $selected; do
      case $opt in
        Containers) docker container prune -f ;;
        Images) docker image prune -a -f ;;
        Volumes) docker volume prune -f ;;
        Tout) docker system prune -a --volumes -f ;;
      esac
    done
    ;;

  "📦 Images Docker")
  echo "📋 Récupération des images disponibles..."
  
  # Format : image_id|repository:tag (taille)
  docker images --format '{{.ID}}|{{.Repository}}:{{.Tag}} ({{.Size}})' > /tmp/docker_images_list.txt

  if [[ ! -s /tmp/docker_images_list.txt ]]; then
    echo "❌ Aucune image Docker trouvée."
    exit 1
  fi

  # Affichage à l'utilisateur sans l'image ID
  display_list=$(awk -F"|" '{print $2}' /tmp/docker_images_list.txt)
  
  # Sélection
  selected=$(echo "$display_list" | fzf -m --height=40% --layout=reverse --border --prompt="Choisissez les images à supprimer > ")

  echo "🧽 Suppression des images sélectionnées..."

  while IFS= read -r line; do
    # Retrouver l'image ID correspondant au choix sélectionné
    image_id=$(grep "$line" /tmp/docker_images_list.txt | cut -d"|" -f1)
    
    if [[ -n "$image_id" ]]; then
      echo "🗑️ Suppression de : $line (ID: $image_id)"
      docker rmi "$image_id"
    fi
  done <<< "$selected"
  ;;


  "🚪 Quitter")
    echo "👋 À bientôt !"
    exit 0
    ;;

  *)
    echo "❌ Action inconnue. Bye."
    exit 1
    ;;
esac
