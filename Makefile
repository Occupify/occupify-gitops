.PHONY: network dns-refresh \
        sync-shared sync-identity sync-core sync-payment sync-noti sync-administration sync-agentic sync-gateway sync-all \
        infra infra-all infra-shared \
        infra-identity infra-core infra-payment infra-noti infra-administration infra-agentic \
        identity core payment noti administration agentic gateway nginx \
        be-gateway be-identity be-core be-payment be-noti be-administration be-agentic be-all all

network:
	@podman network exists occupify-network || podman network create occupify-network

dns-refresh:
	@echo ">> Refreshing Aardvark DNS daemon..."
	@pkill -u "$$(id -u)" aardvark-dns || true

sync-shared:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services/shared
	@cp -rf services/shared/* $$HOME/.config/systemd/user/git-ops/services/shared/ 2>/dev/null || true
	@cp -f service/occupify-infra-shared.service $$HOME/.config/systemd/user/ 2>/dev/null || true

sync-identity:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services/identity
	@cp -rf services/identity/* $$HOME/.config/systemd/user/git-ops/services/identity/ 2>/dev/null || true
	@cp -f service/occupify-*-identity.service $$HOME/.config/systemd/user/ 2>/dev/null || true

sync-core:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services/core
	@cp -rf services/core/* $$HOME/.config/systemd/user/git-ops/services/core/ 2>/dev/null || true
	@cp -f service/occupify-*-core.service $$HOME/.config/systemd/user/ 2>/dev/null || true

sync-payment:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services/payment
	@cp -rf services/payment/* $$HOME/.config/systemd/user/git-ops/services/payment/ 2>/dev/null || true
	@cp -f service/occupify-*-payment.service $$HOME/.config/systemd/user/ 2>/dev/null || true

sync-noti:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services/noti
	@cp -rf services/noti/* $$HOME/.config/systemd/user/git-ops/services/noti/ 2>/dev/null || true
	@cp -f service/occupify-*-noti.service $$HOME/.config/systemd/user/ 2>/dev/null || true

sync-administration:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services/administration
	@cp -rf services/administration/* $$HOME/.config/systemd/user/git-ops/services/administration/ 2>/dev/null || true
	@cp -f service/occupify-*-administration.service $$HOME/.config/systemd/user/ 2>/dev/null || true

sync-agentic:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services/agentic
	@cp -rf services/agentic/* $$HOME/.config/systemd/user/git-ops/services/agentic/ 2>/dev/null || true
	@cp -f service/occupify-*-agentic.service $$HOME/.config/systemd/user/ 2>/dev/null || true

sync-gateway:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services/gateway
	@cp -rf services/gateway/* $$HOME/.config/systemd/user/git-ops/services/gateway/ 2>/dev/null || true
	@cp -f service/occupify-be-gateway.service $$HOME/.config/systemd/user/ 2>/dev/null || true

sync-all: sync-shared sync-identity sync-core sync-payment sync-noti sync-administration sync-agentic sync-gateway

infra-shared: network dns-refresh sync-shared
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-rabbitmq' && \
	    podman ps --format '{{.Names}}' | grep -qw 'occupify-redis' && \
	    podman ps --format '{{.Names}}' | grep -qw 'occupify-pgadmin'; then \
		echo ">> Shared infra (RabbitMQ, Redis, pgAdmin) is already running, skipping..."; \
	else \
		echo ">> Starting Shared infrastructure (RabbitMQ, Redis, pgAdmin)..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-shared; \
		sleep 3; \
		podman ps | grep -E "occupify-rabbitmq|occupify-redis|occupify-pgadmin" || true; \
	fi

infra-identity: network dns-refresh sync-identity
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-identity'; then \
		echo ">> Identity infra (occupify-postgres-identity) is already running, skipping..."; \
	else \
		echo ">> Starting Identity infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-identity; \
		sleep 3; \
		podman ps | grep occupify-postgres-identity || true; \
	fi

infra-core: network dns-refresh sync-core
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-core'; then \
		echo ">> Core infra (occupify-postgres-core) is already running, skipping..."; \
	else \
		echo ">> Starting Core infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-core; \
		sleep 3; \
		podman ps | grep occupify-postgres-core || true; \
	fi

infra-payment: network dns-refresh sync-payment
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-payment'; then \
		echo ">> Payment infra (occupify-postgres-payment) is already running, skipping..."; \
	else \
		echo ">> Starting Payment infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-payment; \
		sleep 3; \
		podman ps | grep occupify-postgres-payment || true; \
	fi

infra-noti: network dns-refresh sync-noti
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-noti'; then \
		echo ">> Notification infra (occupify-postgres-noti) is already running, skipping..."; \
	else \
		echo ">> Starting Notification infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-noti; \
		sleep 3; \
		podman ps | grep occupify-postgres-noti || true; \
	fi

infra-administration: network dns-refresh sync-administration
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-administration'; then \
		echo ">> Administration infra (occupify-postgres-administration) is already running, skipping..."; \
	else \
		echo ">> Starting Administration infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-administration; \
		sleep 3; \
		podman ps | grep occupify-postgres-administration || true; \
	fi

infra-agentic: network dns-refresh sync-agentic
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-agentic'; then \
		echo ">> Agentic infra (occupify-postgres-agentic) is already running, skipping..."; \
	else \
		echo ">> Starting Agentic infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-agentic; \
		sleep 3; \
		podman ps | grep occupify-postgres-agentic || true; \
	fi

infra-all: infra-shared infra-identity infra-core infra-payment infra-noti infra-administration infra-agentic

infra: infra-all

nginx:
	@echo ">> Ensuring Nginx service is running..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-nginx
	@sleep 2
	systemctl --user status occupify-nginx --no-pager

gateway: infra-shared be-gateway

be-gateway: network dns-refresh sync-gateway
	@echo ">> Pulling occupify-gateway image..."
	podman pull ghcr.io/occupify/occupify-gateway:latest
	@echo ">> Triggering Systemd Service for Gateway..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-gateway
	@sleep 3
	@podman ps | grep occupify-gateway || true

identity: infra-identity be-identity

be-identity: network dns-refresh sync-identity
	@echo ">> Pulling occupify-identity image..."
	podman pull ghcr.io/occupify/occupify-identity:latest
	@echo ">> Triggering Systemd Service for Identity..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-identity
	@sleep 3
	@podman ps | grep occupify-identity || true

core: infra-core be-core

be-core: network dns-refresh sync-core
	@echo ">> Pulling occupify-core image..."
	podman pull ghcr.io/occupify/occupify-core:latest
	@echo ">> Triggering Systemd Service for Core..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-core
	@sleep 3
	@podman ps | grep occupify-core || true

payment: infra-payment be-payment

be-payment: network dns-refresh sync-payment
	@echo ">> Pulling occupify-payment image..."
	podman pull ghcr.io/occupify/occupify-payment:latest
	@echo ">> Triggering Systemd Service for Payment..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-payment
	@sleep 3
	@podman ps | grep occupify-payment || true

noti: infra-noti be-noti

be-noti: network dns-refresh sync-noti
	@echo ">> Pulling occupify-noti image..."
	podman pull ghcr.io/occupify/occupify-noti:latest
	@echo ">> Triggering Systemd Service for Notification..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-noti
	@sleep 3
	@podman ps | grep occupify-noti || true

administration: infra-administration be-administration

be-administration: network dns-refresh sync-administration
	@echo ">> Pulling occupify-administration image..."
	podman pull ghcr.io/occupify/occupify-administration:latest
	@echo ">> Triggering Systemd Service for Administration..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-administration
	@sleep 3
	@podman ps | grep occupify-administration || true

agentic: infra-agentic be-agentic

be-agentic: network dns-refresh sync-agentic
	@echo ">> Pulling occupify-agentic image..."
	podman pull ghcr.io/occupify/occupify-agentic:latest
	@echo ">> Pulling occupify-cv-compiler image..."
	podman pull ghcr.io/occupify/occupify-cv-compiler:latest
	@echo ">> Triggering Systemd Service for Agentic..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-agentic
	@sleep 3
	@podman ps | grep occupify-agentic || true
	@podman ps | grep occupify-cv-compiler || true
	@echo ">> Restarting API Gateway..."
	podman restart occupify-gateway || true

be-all: be-gateway be-identity be-core be-payment be-noti be-administration be-agentic

all: sync-all infra-all be-all nginx
