.PHONY: gateway identity core payment noti administration agentic admin \
        stop-gateway stop-identity stop-core stop-payment stop-noti stop-administration stop-agentic stop-admin \
        clean-all

gateway:
	@echo ">> Starting Gateway service..."
	podman compose -f compose/gateway/compose.prod.yml up -d

stop-gateway:
	@echo ">> Stopping Gateway service..."
	podman compose -f compose/gateway/compose.prod.yml down

identity:
	@echo ">> Starting Identity service + Postgres..."
	podman compose -f compose/identity/compose.prod.yml up -d

stop-identity:
	@echo ">> Stopping Identity service + Postgres..."
	podman compose -f compose/identity/compose.prod.yml down

core:
	@echo ">> Starting Core service + Postgres..."
	podman compose -f compose/core/compose.prod.yml up -d

stop-core:
	@echo ">> Stopping Core service + Postgres..."
	podman compose -f compose/core/compose.prod.yml down

payment:
	@echo ">> Starting Payment service + Postgres..."
	podman compose -f compose/payment/compose.prod.yml up -d

stop-payment:
	@echo ">> Stopping Payment service + Postgres..."
	podman compose -f compose/payment/compose.prod.yml down

noti:
	@echo ">> Starting Noti service + Postgres..."
	podman compose -f compose/noti/compose.prod.yml up -d

stop-noti:
	@echo ">> Stopping Noti service + Postgres..."
	podman compose -f compose/noti/compose.prod.yml down

admin: administration

stop-admin: stop-administration

administration:
	@echo ">> Starting Administration service + Postgres..."
	podman compose -f compose/administration/compose.prod.yml up -d

stop-administration:
	@echo ">> Stopping Administration service + Postgres..."
	podman compose -f compose/administration/compose.prod.yml down

agentic:
	@echo ">> Starting Agentic service + Postgres + CV Compiler..."
	podman compose -f compose/agentic/compose.prod.yml up -d

stop-agentic:
	@echo ">> Stopping Agentic service + Postgres + CV Compiler..."
	podman compose -f compose/agentic/compose.prod.yml down

clean-all:
	@echo ">> Cleaning all compose services..."
	podman compose -f compose/gateway/compose.prod.yml down 2>/dev/null || true
	podman compose -f compose/identity/compose.prod.yml down 2>/dev/null || true
	podman compose -f compose/core/compose.prod.yml down 2>/dev/null || true
	podman compose -f compose/payment/compose.prod.yml down 2>/dev/null || true
	podman compose -f compose/noti/compose.prod.yml down 2>/dev/null || true
	podman compose -f compose/administration/compose.prod.yml down 2>/dev/null || true
	podman compose -f compose/agentic/compose.prod.yml down 2>/dev/null || true
