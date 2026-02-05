.PHONY: install install-backend install-frontend dev dev-backend dev-frontend build clean seed help bicep-deploy bicep-validate docker-build docker-push

# Default target
help:
	@echo "Kidoikoiaki - Makefile Commands"
	@echo ""
	@echo "📦 Setup & Development:"
	@echo "  make install          Install all dependencies (backend + frontend)"
	@echo "  make install-backend  Install backend dependencies only"
	@echo "  make install-frontend Install frontend dependencies only"
	@echo "  make dev              Run both backend and frontend in development mode"
	@echo "  make dev-backend      Run backend only in development mode"
	@echo "  make dev-frontend     Run frontend only in development mode"
	@echo "  make build            Build both backend and frontend for production"
	@echo "  make seed             Reset and seed the database with sample data"
	@echo "  make clean            Remove node_modules and build artifacts"
	@echo ""
	@echo "🐳 Docker & Registry:"
	@echo "  make docker-build ENV=<env>      Build backend Docker image"
	@echo "  make docker-build-frontend ENV=<env> Build frontend Docker image"
	@echo "  make docker-push ENV=<env>       Push images to Azure Container Registry"
	@echo ""
	@echo "☁️  Azure Deployment:"
	@echo "  make bicep-validate ENV=<env>    Validate Bicep templates"
	@echo "  make bicep-deploy ENV=<env>      Deploy infrastructure with Bicep"
	@echo "  make bicep-setup-rbac ENV=<env>  Setup RBAC roles"
	@echo "  make bicep-logs ENV=<env>        View App Service logs"
	@echo "  make bicep-destroy ENV=<env>     Delete all resources"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - Node.js 18+"
	@echo "  - Docker"
	@echo "  - Azure CLI logged in (az login)"
	@echo ""

# Install all dependencies
install: install-backend install-frontend
	@echo "✅ All dependencies installed"

install-backend:
	@echo "📦 Installing backend dependencies..."
	cd backend && npm install

install-frontend:
	@echo "📦 Installing frontend dependencies..."
	cd front && npm install

# Development mode
dev:
	@echo "🚀 Starting development servers..."
	@echo "Backend: http://localhost:3001"
	@echo "Frontend: http://localhost:5173"
	@make -j2 dev-backend dev-frontend

dev-backend:
	@echo "🔧 Starting backend..."
	cd backend && npm run dev

dev-frontend:
	@echo "🎨 Starting frontend..."
	cd front && npm run dev

# Build for production
build: build-backend build-frontend
	@echo "✅ Build complete"

build-backend:
	@echo "🔨 Building backend..."
	cd backend && npm run build

build-frontend:
	@echo "🔨 Building frontend..."
	cd front && npm run build

# Docker commands
.PHONY: build-backend build-frontend

ACR_NAME ?= kdkacr
ENV ?= dev
BACKEND_IMAGE = $(ACR_NAME).azurecr.io/kidoikoiaki-backend:latest
FRONTEND_IMAGE = $(ACR_NAME).azurecr.io/kidoikoiaki-frontend:latest

docker-build:
	@echo "🐳 Building backend Docker image for $(ENV)..."
	docker build -f Dockerfile -t $(BACKEND_IMAGE) .
	@echo "✅ Image built: $(BACKEND_IMAGE)"

docker-build-frontend:
	@echo "🐳 Building frontend Docker image for $(ENV)..."
	docker build -f Dockerfile.frontend -t $(FRONTEND_IMAGE) .
	@echo "✅ Image built: $(FRONTEND_IMAGE)"

docker-push: docker-build docker-build-frontend
	@echo "📤 Pushing images to ACR ($(ACR_NAME))..."
	az acr login --name $(ACR_NAME)
	docker push $(BACKEND_IMAGE)
	docker push $(FRONTEND_IMAGE)
	@echo "✅ Images pushed"

# Bicep commands
.PHONY: bicep-validate bicep-deploy bicep-setup-rbac bicep-logs bicep-destroy

RESOURCE_GROUP = kdk-$(ENV)-rg

bicep-validate:
	@echo "✅ Validating Bicep templates for $(ENV)..."
	az bicep build-params --file bicep/parameters.$(ENV).biceparam
	az deployment group validate \
		--resource-group $(RESOURCE_GROUP) \
		--template-file bicep/main.bicep \
		--parameters @bicep/parameters.$(ENV).biceparam
	@echo "✅ Templates are valid"

bicep-deploy: bicep-validate docker-push
	@echo "🚀 Deploying to $(ENV) environment..."
	az deployment group create \
		--resource-group $(RESOURCE_GROUP) \
		--template-file bicep/main.bicep \
		--parameters @bicep/parameters.$(ENV).biceparam \
		--parameters backendImageUri=$(BACKEND_IMAGE)
	@echo "✅ Deployment complete!"
	@make bicep-logs

bicep-setup-rbac:
	@echo "🔐 Setting up RBAC for $(ENV)..."
	chmod +x bicep/setup-rbac.sh
	./bicep/setup-rbac.sh $(ENV)

bicep-logs:
	@echo "📋 Fetching logs from backend (kdk-$(ENV)-backend)..."
	az webapp log tail --name kdk-$(ENV)-backend --resource-group $(RESOURCE_GROUP) || echo "App Service not yet available"

bicep-destroy:
	@echo "🗑️  WARNING: This will delete all resources in $(RESOURCE_GROUP)"
	@read -p "Are you sure? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		az group delete --name $(RESOURCE_GROUP) --yes; \
		echo "✅ Resource group deleted"; \
	else \
		echo "Cancelled"; \
	fi
	@echo "✅ Build complete"

build-backend:
	@echo "🔨 Building backend..."
	cd backend && npm run build

build-frontend:
	@echo "🔨 Building frontend..."
	cd front && npm run build

# Docker commands
.PHONY: build-backend build-frontend

ACR_NAME ?= kdkacr
ENV ?= dev
BACKEND_IMAGE = $(ACR_NAME).azurecr.io/kidoikoiaki-backend:latest
FRONTEND_IMAGE = $(ACR_NAME).azurecr.io/kidoikoiaki-frontend:latest

docker-build:
	@echo "🐳 Building backend Docker image for $(ENV)..."
	docker build -f Dockerfile -t $(BACKEND_IMAGE) .
	@echo "✅ Image built: $(BACKEND_IMAGE)"

docker-build-frontend:
	@echo "🐳 Building frontend Docker image for $(ENV)..."
	docker build -f Dockerfile.frontend -t $(FRONTEND_IMAGE) .
	@echo "✅ Image built: $(FRONTEND_IMAGE)"

docker-push: docker-build docker-build-frontend
	@echo "📤 Pushing images to ACR ($(ACR_NAME))..."
	az acr login --name $(ACR_NAME)
	docker push $(BACKEND_IMAGE)
	docker push $(FRONTEND_IMAGE)
	@echo "✅ Images pushed"

# Bicep commands
.PHONY: bicep-validate bicep-deploy bicep-setup-rbac bicep-logs bicep-destroy

RESOURCE_GROUP = kdk-$(ENV)-rg

bicep-validate:
	@echo "✅ Validating Bicep templates for $(ENV)..."
	az bicep build-params --file bicep/parameters.$(ENV).biceparam
	az deployment group validate \
		--resource-group $(RESOURCE_GROUP) \
		--template-file bicep/main.bicep \
		--parameters @bicep/parameters.$(ENV).biceparam
	@echo "✅ Templates are valid"

bicep-deploy: bicep-validate docker-push
	@echo "🚀 Deploying to $(ENV) environment..."
	az deployment group create \
		--resource-group $(RESOURCE_GROUP) \
		--template-file bicep/main.bicep \
		--parameters @bicep/parameters.$(ENV).biceparam \
		--parameters backendImageUri=$(BACKEND_IMAGE)
	@echo "✅ Deployment complete!"
	@make bicep-logs

bicep-setup-rbac:
	@echo "🔐 Setting up RBAC for $(ENV)..."
	chmod +x bicep/setup-rbac.sh
	./bicep/setup-rbac.sh $(ENV)

bicep-logs:
	@echo "📋 Fetching logs from backend (kdk-$(ENV)-backend)..."
	az webapp log tail --name kdk-$(ENV)-backend --resource-group $(RESOURCE_GROUP) || echo "App Service not yet available"

bicep-destroy:
	@echo "🗑️  WARNING: This will delete all resources in $(RESOURCE_GROUP)"
	@read -p "Are you sure? Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		az group delete --name $(RESOURCE_GROUP) --yes; \
		echo "✅ Resource group deleted"; \
	else \
		echo "Cancelled"; \
	fi
	@echo "✅ Build complete"

build-backend:
	@echo "🔨 Building backend..."
	cd backend && npm run build

build-frontend:
	@echo "🔨 Building frontend..."
	cd front && npm run build

# Seed database
seed:
	@echo "🌱 Seeding database..."
	cd backend && npm run seed

# Clean
clean:
	@echo "🧹 Cleaning..."
	rm -rf backend/node_modules backend/dist
	rm -rf front/node_modules front/dist
	@echo "✅ Cleaned"

# Alias for Windows users (using PowerShell)
dev-windows:
	@echo "🚀 Starting development servers (Windows)..."
	@echo "Run these commands in separate terminals:"
	@echo "  Terminal 1: cd backend && npm run dev"
	@echo "  Terminal 2: cd front && npm run dev"
