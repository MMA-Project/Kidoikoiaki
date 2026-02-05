# Kidoikoiaki - Application de Partage de Dépenses

Application web type Tricount permettant de gérer des listes de dépenses partagées.

## 🏗️ Architecture

```
kidoikoiaki/
├── backend/          # API Express + TypeScript
│   ├── src/
│   │   ├── blob/     # Service Azure Blob Storage
│   │   ├── db/       # Connexion Azure SQL Database
│   │   ├── routes/   # Routes API REST
│   │   ├── services/ # Logique métier (calcul des soldes)
│   │   └── types/    # Types TypeScript
│   └── .env          # Variables d'environnement
│
├── front/            # Frontend Vite + React + TypeScript + Tailwind
│   └── src/
│       ├── api/      # Client API + TanStack Query hooks
│       ├── components/
│       ├── pages/
│       └── types/
│
├── Makefile          # Commandes de développement
└── README.md
```

## 🚀 Démarrage Rapide

### Prérequis

- Node.js 18+
- Azure CLI connecté (`az login`)
- Accès à Azure SQL Database et Blob Storage
- Make (optionnel, pour utiliser le Makefile)

### Avec Make (recommandé)

```bash
# Installer toutes les dépendances
make install

# Lancer en développement (backend + frontend)
make dev
```

### Sans Make

#### Backend

```bash
cd backend
npm install
npm run dev
# → http://localhost:3001
```

#### Frontend

```bash
cd front
npm install
npm run dev
# → http://localhost:5173
```

Le backend démarre sur http://localhost:3001

### 2. Configuration Frontend

```bash
cd front

# Installer les dépendances
npm install

# Lancer en développement
npm run dev
```

Le frontend démarre sur http://localhost:5173

## 📝 API Endpoints

### Listes

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/lists` | Récupérer toutes les listes |
| GET | `/api/lists/:id` | Récupérer une liste avec ses détails |
| POST | `/api/lists` | Créer une nouvelle liste |
| PUT | `/api/lists/:id` | Modifier une liste |
| DELETE | `/api/lists/:id` | Supprimer une liste |

### Participants

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/participants?listId=xxx` | Participants d'une liste |
| POST | `/api/participants` | Ajouter un participant |
| PUT | `/api/participants/:id` | Modifier un participant |
| DELETE | `/api/participants/:id` | Supprimer un participant |

### Dépenses

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/expenses?listId=xxx` | Dépenses d'une liste |
| GET | `/api/expenses/:id` | Détail d'une dépense |
| POST | `/api/expenses` | Créer une dépense (avec image optionnelle) |
| DELETE | `/api/expenses/:id` | Supprimer une dépense |

### Soldes

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/balances/:listId` | Calcul des soldes et remboursements |

## 💰 Algorithme de Répartition

L'algorithme de calcul des remboursements:

1. **Calcul des soldes**: Pour chaque participant, on calcule:
   - Ce qu'il a payé au total
   - Ce qu'il devrait (part de chaque dépense où il participe)
   - Son solde = payé - dû

2. **Minimisation des transactions**: 
   - Algorithme glouton (greedy)
   - Matching entre le plus gros débiteur et le plus gros créditeur
   - Répète jusqu'à équilibre

Exemple de résultat:
```json
{
  "transactions": [
    { "from": "Alice", "to": "Bob", "amount": 20.00 },
    { "from": "Charlie", "to": "Alice", "amount": 10.00 }
  ]
}
```

## 🔧 Variables d'Environnement

Backend (`.env`):
```env
# Azure SQL Database
AZURE_SQL_SERVER=your-server.database.windows.net
AZURE_SQL_DATABASE=your-database

# Azure Blob Storage
AZURE_STORAGE_ACCOUNT_NAME=yourstorageaccount
AZURE_STORAGE_CONTAINER_NAME=files

# Server
PORT=3001
```

## 🛠️ Technologies

### Backend
- Node.js + Express
- TypeScript
- Azure SQL Database (mssql)
- Azure Blob Storage (@azure/storage-blob)
- Azure Identity (@azure/identity)
- Multer (upload de fichiers)

### Frontend
- React 19
- TypeScript
- Vite
- **Tailwind CSS** (styling)
- **TanStack Query** (gestion d'état serveur)
- **Framer Motion** (animations)

## ✅ Fonctionnalités

- [x] Création/modification/suppression de listes
- [x] Gestion des participants
- [x] Ajout de dépenses avec titre, montant, payeur, participants
- [x] Upload d'images (reçus/factures) vers Azure Blob
- [x] Calcul automatique des soldes
- [x] Calcul optimisé des remboursements (min transactions)
- [x] Interface utilisateur responsive

## 📦 Structure de la Base de Données

```sql
-- Listes de dépenses
Lists (id, name, description, createdAt, updatedAt)

-- Participants d'une liste
Participants (id, listId, name, createdAt)

-- Dépenses
Expenses (id, listId, title, amount, payerId, imageUrl, createdAt)

-- Association dépenses <-> participants concernés
ExpenseParticipants (expenseId, participantId)
```

## 🧪 Test de l'API

```bash
# Health check
curl http://localhost:3001/api/health

# Créer une liste
curl -X POST http://localhost:3001/api/lists \
  -H "Content-Type: application/json" \
  -d '{"name": "Vacances 2026", "description": "Dépenses vacances été"}'

# Ajouter un participant
curl -X POST http://localhost:3001/api/participants \
  -H "Content-Type: application/json" \
  -d '{"listId": "xxx", "name": "Alice"}'
```
