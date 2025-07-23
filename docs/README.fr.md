

## 🇫🇷 `README.fr.md`


# Docker Helpers Scripts 🐳

Une collection de scripts utiles pour simplifier la gestion de Docker, incluant la publication d'images, le nettoyage des conteneurs/volumes/images et plus encore.

![Logo Docker](https://www.docker.com/wp-content/uploads/2022/03/vertical-logo-monochromatic.png)

## Fonctionnalités ✨

- **Publication interactive d'images Docker** 📤
  - Sélection multiple d'images locales à publier
  - Personnalisation du registre, nom d'utilisateur et tag
  - Mode dry-run disponible
  - Rapports de progression détaillés

- **Nettoyage des ressources Docker** 🧹
  - Sélection interactive des ressources à supprimer
  - Gestion des conteneurs, images et volumes
  - Option pour tout supprimer ou sélectionner des éléments spécifiques
  - Confirmation avant les actions destructives

- **Interface conviviale** 🖥️
  - Sortie colorée pour une meilleure lisibilité
  - Menus interactifs utilisant `fzf`
  - Mode verbeux pour le débogage
  - Support multiplateforme (Linux, macOS, Windows)

## Installation ⚙️

### Installation rapide

```bash
curl -fsSL https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/install.sh | bash
```

### Installation manuelle

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/Baabacar/docker-helpers.git
   ```

2. Rendre les scripts exécutables :
   ```bash
   chmod +x docker-helpers/scripts/*.sh
   ```

3. Ajouter au PATH ou exécuter directement :
   ```bash
   sudo ln -s $(pwd)/docker-helpers/scripts/docker-helper.sh /usr/local/bin/docker-helper
   ```

## Utilisation 🚀

Lancer le script principal :
```bash
docker-helper
```

Vous verrez un menu interactif avec ces options :

1. **🐳 Publier des images** - Publier des images locales vers un registre Docker
2. **🗑️ Supprimer** - Nettoyer les ressources Docker (conteneurs, images, volumes)
3. **🚪 Quitter** - Quitter le programme

### Workflow de publication d'images

1. Entrer votre nom d'utilisateur Docker
2. Sélectionner des images dans une liste interactive
3. Choisir un tag (par défaut : latest)
4. Optionnellement activer le mode dry-run
5. Vérifier le résumé et confirmer
6. Le script gère automatiquement le tagging et le push

### Workflow de nettoyage

1. Choisir le type de ressource (Conteneurs, Images, Volumes)
2. Sélectionner des éléments spécifiques ou "Tout"
3. Confirmer la suppression
4. Le script effectue le nettoyage et retourne au menu principal

## Prérequis 📋

- Docker installé et en cours d'exécution
- `fzf` (fuzzy finder) - sera installé automatiquement si absent
- Bash 4.0 ou plus récent

## Désinstallation 🗑️

Pour supprimer les scripts :

```bash
curl -fsSL https://raw.githubusercontent.com/Baabacar/docker-helpers/main/scripts/uninstall.sh | bash
```

Ou manuellement :
```bash
rm -f ~/.local/bin/docker-helper.sh
```

## Licence 📄

Licence MIT - voir [LICENCE](../LICENSE) pour les détails.

---

Fait avec ❤️ par [Betzalel75]