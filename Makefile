IMAGE_OWNER ?= occupify

.PHONY: network dns-refresh infra nginx be-gateway be-identity be-core be-payment be-noti be-administration be-all

network:
	@podman network exists occupify-network || podman network create occupify-network

dns-refresh:
	@echo ">> Refreshing Aardvark DNS daemon..."
	@pkill -u "$$(id -u)" aardvark-dns || true

infra: network dns-refresh
	@echo ">> Ensuring infrastructure is running..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-infra
	@sleep 3
	@podman ps | grep occupify-postgres || true

nginx:
	@echo ">> Ensuring Nginx service is running..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-nginx
	@sleep 2
	systemctl --user status occupify-nginx --no-pager

be-gateway: network dns-refresh
	@echo ">> Pulling occupify-gateway image..."
	podman pull ghcr.io/${IMAGE_OWNER}/occupify-gateway:latest
	@echo ">> Triggering Systemd Service for Gateway..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-gateway
	@sleep 3
	@podman ps | grep occupify-gateway || true

be-identity: network dns-refresh
	@echo ">> Pulling occupify-identity image..."
	podman pull ghcr.io/${IMAGE_OWNER}/occupify-identity:latest
	@echo ">> Triggering Systemd Service for Identity..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-identity
	@sleep 3
	@podman ps | grep occupify-identity || true

be-core: network dns-refresh
	@echo ">> Pulling occupify-core image..."
	podman pull ghcr.io/${IMAGE_OWNER}/occupify-core:latest
	@echo ">> Triggering Systemd Service for Core..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-core
	@sleep 3
	@podman ps | grep occupify-core || true

be-payment: network dns-refresh
	@echo ">> Pulling occupify-payment image..."
	podman pull ghcr.io/${IMAGE_OWNER}/occupify-payment:latest
	@echo ">> Triggering Systemd Service for Payment..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-payment
	@sleep 3
	@podman ps | grep occupify-payment || true

be-noti: network dns-refresh
	@echo ">> Pulling occupify-noti image..."
	podman pull ghcr.io/${IMAGE_OWNER}/occupify-noti:latest
	@echo ">> Triggering Systemd Service for Notification..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-noti
	@sleep 3
	@podman ps | grep occupify-noti || true

be-administration: network dns-refresh
	@echo ">> Pulling occupify-administration image..."
	podman pull ghcr.io/${IMAGE_OWNER}/occupify-administration:latest
	@echo ">> Triggering Systemd Service for Administration..."
	systemctl --user daemon-reload
	systemctl --user restart occupify-be-administration
	@sleep 3
	@podman ps | grep occupify-administration || true

be-all: be-gateway be-identity be-core be-payment be-noti be-administration
