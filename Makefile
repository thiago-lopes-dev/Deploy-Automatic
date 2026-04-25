.PHONY: help build up down logs ps shell deploy-check

help:
	@echo "🚀 Comandos disponíveis:"
	@echo "  make build          - Constrói a imagem Docker da aplicação"
	@echo "  make up             - Sobe os containers em modo produção"
	@echo "  make down           - Derruba os containers"
	@echo "  make logs           - Mostra os logs em tempo real"
	@echo "  make ps             - Lista os containers ativos"
	@echo "  make deploy-check   - Roda testes básicos antes de um deploy"

build:
	docker build -t app-sistema:latest .

up:
	docker compose -f docker-compose.production.yml up -d

down:
	docker compose -f docker-compose.production.yml down

logs:
	docker compose -f docker-compose.production.yml logs -f

ps:
	docker compose -f docker-compose.production.yml ps

deploy-check:
	@echo "🔍 Verificando integridade..."
	@ls -la .env.production || (echo "❌ Erro: .env.production não encontrado!" && exit 1)
	@docker compose -f docker-compose.production.yml config -q && echo "✅ Configuração Docker OK"
