# CRUD Master 🌐

Ce projet implémente une infrastructure de microservices avec une passerelle API connectée à deux services distincts : un service d'inventaire de films et un service de facturation. L'architecture utilise des communications HTTP et un système de file d'attente de messages, le tout encapsulé dans différentes machines virtuelles.

## 🔧 Stack Technique

- **Node.js & Express.js** (Framework web)
- **PostgreSQL** (Base de données)
- **RabbitMQ** (File d'attente de messages)
- **VirtualBox** (Virtualisation)
- **Vagrant** (Gestion des VMs)
- **PM2** (Gestionnaire de processus Node.js)
- **Ansible** (Automatisation)

## 📜 Sommaire
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [API Endpoints](#api-endpoints)
- [Tests](#tests)
- [Structure du Projet](#structure-du-projet)

## 🏗 Architecture

Le projet se compose de trois services principaux :

1. **API Gateway** (Port 8080)
   - Route les requêtes HTTP vers le service Inventory
   - Gère les messages RabbitMQ vers le service Billing

2. **Inventory Service** (Port 8081)
   - API CRUD pour la gestion des films
   - Base de données PostgreSQL (movies_db)

3. **Billing Service** (Port 8082)
   - Traitement des commandes via RabbitMQ
   - Base de données PostgreSQL (orders_db)

## ⚙️ Prérequis

- VirtualBox
- Vagrant
- Postman
- Rabbitmq

## 🚀 Installation

1. Cloner le repository :
```bash
git clone https://learn.zone01dakar.sn/git/edieng/crud-master.git 
cd crud-master
```

2. Lancer les machines virtuelles :
```bash
vagrant up
```

3. Vérifier le statut des VMs :
```bash
vagrant status
```

## 🛠 Configuration

### Variables d'Environnement
Le fichier `.env` contient les configurations nécessaires :

```bash
DB_USER=kendi
DB_PASSWORD=kendi
POSTGRES_HOST=localhost
API_GATEWAY_PORT=8080
INVENTORY_PORT=8081
BILLING_PORT=8082
RABBITMQ_HOST=localhost
```

## 📡 API Endpoints

### Service Inventory

- `GET /api/movies` - Liste tous les films
- `GET /api/movies?title=[name]` - Recherche par titre
- `POST /api/movies` - Crée un nouveau film
- `DELETE /api/movies` - Supprime tous les films
- `GET /api/movies/:id` - Récupère un film par ID
- `PUT /api/movies/:id` - Met à jour un film
- `DELETE /api/movies/:id` - Supprime un film

### Service Billing

- `POST /api/billing` - Crée une nouvelle commande
```json
{
  "user_id": "3",
  "number_of_items": "5",
  "total_amount": "180"
}
```

## 🧪 Tests

Utiliser Postman pour tester les endpoints. Une collection Postman est fournie dans le projet `crud-master-collection.json`.

### Test de Résilience RabbitMQ

1. Arrêter le service Billing :
```bash
vagrant ssh billing-vm
sudo pm2 stop billing-app
```

2. Envoyer des messages
3. Redémarrer le service pour vérifier le traitement différé

## 📁 Structure du Projet

```console
.
├── config.yaml
├── Docs
│   ├── instructions
│   │   ├── audit.md
│   │   └── Readme.md
│   └── ressources
│       ├── note.md
│       └── with-ansible-vagrantfile.md
├── makefile
├── postman
│   └──  crud-master-collection.json
├── README.md
├── scripts
│   ├── ansible
│   │   ├── group_vars
│   │   │   └── all.yml
│   │   ├── inventory
│   │   │   └── hosts.yml
│   │   ├── roles
│   │   │   ├── api-gateway
│   │   │   │   └── tasks
│   │   │   │       └── main.yml
│   │   │   ├── billing-app
│   │   │   │   └── tasks
│   │   │   │       └── main.yml
│   │   │   ├── common
│   │   │   │   └── tasks
│   │   │   │       └── main.yml
│   │   │   └── inventory-app
│   │   │       └── tasks
│   │   │           └── main.yml
│   │   └── site.yml
│   └── shell
│       ├── api-gateway.sh
│       ├── billing-app.sh
│       └── inventory-app.sh
├── src
│   ├── api-gateway
│   │   ├── package.json
│   │   ├── package-lock.json
│   │   └── server.js
│   ├── billing-app
│   │   ├── consumer.js
│   │   ├── package.json
│   │   ├── package-lock.json
│   │   └── server.js
│   └── inventory-app
│       ├── package.json
│       ├── package-lock.json
│       ├── queries.js
│       └── server.js
├── Task
│   └── task.todo
└── Vagrantfile


```

📌 "Be curious and never stop searching!" `<br/>
                                         Babacar Ndiaye


## 👥 Contributeurs 

- [edieng](https://learn.zone01dakar.sn/git/edieng)
- [babacandiaye](https://learn.zone01dakar.sn/git/babacandiaye)

## 📜 Licence 

Ce projet est sous licence ZONE01 - voir le fichier [LICENSE](LICENSE) pour plus de détails.

#### *Toute réutilisation sans accord est passible d'une amende lourd*

---

<a href="#top">Retour en haut ↑</a>