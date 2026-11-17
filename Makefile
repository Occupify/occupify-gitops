.PHONY: network dns-refresh sync-manifests infra infra-all infra-shared \
        infra-identity infra-core infra-payment infra-noti infra-administration infra-agentic \
        identity core payment noti administration agentic gateway nginx \
        be-gateway be-identity be-core be-payment be-noti be-administration be-agentic be-all all

network:
	@podman network exists occupify-network || podman network create occupify-network

dns-refresh:
	@echo ">> Refreshing Aardvark DNS daemon..."
	@pkill -u "$$(id -u)" aardvark-dns || true

sync-manifests:
	@mkdir -p $$HOME/.config/systemd/user/git-ops/services
	@cp -rf services/* $$HOME/.config/systemd/user/git-ops/services/ 2>/dev/null || true
	@cp -f service/occupify-*.service $$HOME/.config/systemd/user/ 2>/dev/null || true

infra-shared: network dns-refresh sync-manifests
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

infra-identity: network dns-refresh sync-manifests
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-identity'; then \
		echo ">> Identity infra (occupify-postgres-identity) is already running, skipping..."; \
	else \
		echo ">> Starting Identity infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-identity; \
		sleep 3; \
		podman ps | grep occupify-postgres-identity || true; \
	fi

infra-core: network dns-refresh sync-manifests
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-core'; then \
		echo ">> Core infra (occupify-postgres-core) is already running, skipping..."; \
	else \
		echo ">> Starting Core infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-core; \
		sleep 3; \
		podman ps | grep occupify-postgres-core || true; \
	fi

infra-payment: network dns-refresh sync-manifests
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-payment'; then \
		echo ">> Payment infra (occupify-postgres-payment) is already running, skipping..."; \
	else \
		echo ">> Starting Payment infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-payment; \
		sleep 3; \
		podman ps | grep occupify-postgres-payment || true; \
	fi

infra-noti: network dns-refresh sync-manifests
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-noti'; then \
		echo ">> Notification infra (occupify-postgres-noti) is already running, skipping..."; \
	else \
		echo ">> Starting Notification infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-noti; \
		sleep 3; \
		podman ps | grep occupify-postgres-noti || true; \
	fi

infra-administration: network dns-refresh sync-manifests
	@if podman ps --format '{{.Names}}' | grep -qw 'occupify-postgres-administration'; then \
		echo ">> Administration infra (occupify-postgres-administration) is already running, skipping..."; \
	else \
		echo ">> Starting Administration infrastructure..."; \
		systemctl --user daemon-reload; \
		systemctl --user start occupify-infra-administration; \
		sleep 3; \
		podman ps | grep occupify-postgres-administration || true; \
	fi

infra-agentic: network dns-refresh sync-manifests
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

be-gateway: network dns-refresh sync-manifests
	@echo ">> Pulling occupify-gateway image..."
	podman pull ghcr.io/occupify/occupify-gateway:latest
	@echo ">> Triggering Systemd Service for Gateway..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-gateway
	@sleep 3
	@podman ps | grep occupify-gateway || true

identity: infra-identity be-identity

be-identity: network dns-refresh sync-manifests
	@echo ">> Pulling occupify-identity image..."
	podman pull ghcr.io/occupify/occupify-identity:latest
	@echo ">> Triggering Systemd Service for Identity..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-identity
	@sleep 3
	@podman ps | grep occupify-identity || true

core: infra-core be-core

be-core: network dns-refresh sync-manifests
	@echo ">> Pulling occupify-core image..."
	podman pull ghcr.io/occupify/occupify-core:latest
	@echo ">> Triggering Systemd Service for Core..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-core
	@sleep 3
	@podman ps | grep occupify-core || true

payment: infra-payment be-payment

be-payment: network dns-refresh sync-manifests
	@echo ">> Pulling occupify-payment image..."
	podman pull ghcr.io/occupify/occupify-payment:latest
	@echo ">> Triggering Systemd Service for Payment..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-payment
	@sleep 3
	@podman ps | grep occupify-payment || true

noti: infra-noti be-noti

be-noti: network dns-refresh sync-manifests
	@echo ">> Pulling occupify-noti image..."
	podman pull ghcr.io/occupify/occupify-noti:latest
	@echo ">> Triggering Systemd Service for Notification..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-noti
	@sleep 3
	@podman ps | grep occupify-noti || true

administration: infra-administration be-administration

be-administration: network dns-refresh sync-manifests
	@echo ">> Pulling occupify-administration image..."
	podman pull ghcr.io/occupify/occupify-administration:latest
	@echo ">> Triggering Systemd Service for Administration..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-administration
	@sleep 3
	@podman ps | grep occupify-administration || true

agentic: infra-agentic be-agentic

be-agentic: network dns-refresh sync-manifests
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

all: infra-all be-all nginx
