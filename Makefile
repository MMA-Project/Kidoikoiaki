.PHONY: install install-backend install-frontend dev dev-backend dev-frontend build clean help

# Default target
help:
	@echo "Kidoikoiaki - Makefile Commands"
	@echo ""
	@echo "Usage:"
	@echo "  make install          Install all dependencies (backend + frontend)"
	@echo "  make install-backend  Install backend dependencies only"
	@echo "  make install-frontend Install frontend dependencies only"
	@echo "  make dev              Run both backend and frontend in development mode"
	@echo "  make dev-backend      Run backend only in development mode"
	@echo "  make dev-frontend     Run frontend only in development mode"
	@echo "  make build            Build both backend and frontend for production"
	@echo "  make clean            Remove node_modules and build artifacts"
	@echo ""
	@echo "Prerequisites:"
	@echo "  - Node.js 18+"
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
