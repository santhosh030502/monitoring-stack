.PHONY: setup up down restart logs reload ps clean

setup:
	./scripts/setup.sh

up: setup
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps

reload:
	./scripts/reload.sh

# removes containers AND stored data
clean:
	docker compose down -v
