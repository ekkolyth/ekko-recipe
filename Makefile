.PHONY: help redis/up redis/down redis/restart redis/logs redis/cli redis/status redis/flush redis/keys redis/inspect redis/stats dev dev-simple build kill/next stop clean clean/next install

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

##############################################
# Redis
##############################################

redis/up: ## Start Redis container
	@echo "Starting Redis container..."
	docker-compose up -d redis
	@echo "Redis is starting up..."
	@echo "Connection URL: redis://localhost:6379"

redis/down: ## Stop Redis container
	@echo "Stopping Redis container..."
	docker-compose down redis
	@echo "Redis container stopped"

redis/restart: ## Restart Redis container
	@echo "Restarting Redis container..."
	docker-compose restart redis
	@echo "Redis container restarted"

redis/logs: ## Show Redis container logs
	docker-compose logs -f redis

redis/cli: ## Open Redis CLI
	docker-compose exec redis redis-cli

redis/status: ## Check Redis container status
	@docker-compose ps redis
	@echo ""
	@echo "Testing Redis connection..."
	@docker-compose exec -T redis redis-cli ping || echo "Redis is not responding"

redis/flush: ## Flush all Redis data (WARNING: deletes all data)
	@echo "WARNING: This will delete all Redis data!"
	@docker-compose exec -T redis redis-cli FLUSHALL
	@echo "Redis data flushed"

redis/keys: ## List all Redis keys (cache entries)
	@echo "Redis cache keys:"
	@docker-compose exec -T redis redis-cli --scan --pattern "nextjs:cache:*" | head -20 || echo "No keys found or Redis not running"

redis/inspect: ## Inspect a specific cache key (usage: make redis-inspect KEY=nextjs:cache:...)
	@if [ -z "$(KEY)" ]; then \
		echo "Usage: make redis-inspect KEY=nextjs:cache:APP_PAGE:/test-cache:..."; \
		echo "First, run 'make redis-keys' to see available keys"; \
	else \
		docker-compose exec -T redis redis-cli GET "$(KEY)" | python3 -m json.tool 2>/dev/null || \
		docker-compose exec -T redis redis-cli GET "$(KEY)"; \
	fi

redis/stats: ## Show Redis statistics and cache info
	@echo "=== Redis Info ==="
	@docker-compose exec -T redis redis-cli INFO stats | grep -E "(keyspace|total_commands|keyspace_hits|keyspace_misses)" || echo "Redis not running"
	@echo ""
	@echo "=== Cache Key Count ==="
	@docker-compose exec -T redis redis-cli --scan --pattern "nextjs:cache:*" | wc -l | xargs echo "Total cache keys:"
	@echo ""
	@echo "=== Tag Key Count ==="
	@docker-compose exec -T redis redis-cli --scan --pattern "nextjs:tag:*" | wc -l | xargs echo "Total tag keys:"


##############################################
# Dev
##############################################

dev: ## Start Redis and development server (with cleanup on Ctrl+C)
	@./scripts/dev.sh

build: ## Build the project
	bun run build

install: ## Install dependencies
	bun install

clean: ## Clean up Docker volumes and containers
	@echo "Stopping and removing Redis container..."
	docker-compose down -v
	@echo "Cleanup complete"

clean/next: ## Clean Next.js build cache
	@echo "Cleaning Next.js build cache..."
	rm -rf apps/web/.next
	rm -rf apps/docs/.next
	@echo "Next.js cache cleaned"

kill/next: ## Kill all Next.js processes on port 3000
	@echo "Killing Next.js processes on port 3000..."
	@PORT_PIDS=$$(lsof -ti:3000 2>/dev/null || true); \
	if [ -n "$$PORT_PIDS" ]; then \
		echo "$$PORT_PIDS" | xargs kill -9 2>/dev/null || true; \
		echo "Processes killed"; \
	else \
		echo "No processes found on port 3000"; \
	fi

stop: ## Stop Redis and kill Next.js processes
	@echo "Stopping all services..."
	@make redis/down
	@make kill/next
	@echo "All services stopped"
