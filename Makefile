# Docker Compose コマンド
DC := docker-compose -f ./docker/docker-compose.yml

# 環境ファイルのパターン
ENV_FILES := $(wildcard config/.env.*)

# 環境名のリスト（.env.の後ろの部分を抽出）
ENVIRONMENTS := $(patsubst config/.env.%,%,$(ENV_FILES))

# Docker Composeファイルからサービス名を取得
SERVICES := $(shell sed -n '/^services:/,/^[^ ]/p' ./docker/docker-compose.yml | awk '/^  [a-zA-Z0-9_-]+:/' | sed 's/://g' | tr -d ' ' | xargs)

.PHONY: debug-services
debug-services:
	@echo "検出されたサービス: $(SERVICES)"

# デフォルトのターゲット
.PHONY: help
help:
	@echo "使用可能なコマンド:"
	@echo "  make up           - コンテナを起動（環境を選択）"
	@echo "  make down         - コンテナを停止・削除"
	@echo "  make logs         - コンテナのログを表示"
	@echo "  make build        - イメージをビルド"
	@echo "  make shell [SERVICE=名前] - 指定したサービスのコンテナ内でシェルを実行"
	@echo "  make ps           - 実行中のコンテナの状態を表示"
	@echo "  make restart      - コンテナを再起動"
	@echo "  $(SERVICES)"

.PHONY: up
up:
	@bash -c ' \
		echo "環境を選択してください:"; \
		select env in $(ENVIRONMENTS); do \
			if [ -n "$$env" ]; then \
				echo "選択された環境: $$env"; \
				ENVIRONMENT=$$env $(DC) up -d; \
				break; \
			else \
				echo "無効な選択です。もう一度試してください。"; \
			fi \
		done \
	'

.PHONY: ps
ps:
	$(DC) ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Label \"environment\"}}"

.PHONY: down
down:
	$(DC) down

.PHONY: logs
logs:
	$(DC) logs

.PHONY: build
build:
	$(DC) build

.PHONY: shell
shell:
	@if [ -z "$(SERVICE)" ]; then \
		chmod +x ./script/select_service.sh && ./script/select_service.sh $(SERVICES); \
	else \
		$(DC) exec $(SERVICE) /bin/sh; \
	fi


# 新しいターゲットを追加
.PHONY: restart
restart:
	$(DC) restart