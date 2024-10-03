# ベースステージ
FROM golang:1.23.2 AS base

# 作業ディレクトリを設定
WORKDIR /app

# Goモジュールファイルをコピーして依存関係をダウンロード
COPY src/backend/go.mod src/backend/go.sum ./
RUN go mod download && go mod verify

# ソースコードをコピー
COPY src/backend .

# ---------------------- #
# - 開発環境用のステージ - #
# ---------------------- #
FROM base AS development

# templをインストール
RUN go install github.com/a-h/templ/cmd/templ@latest

# 開発用のポートを公開
EXPOSE 8080
EXPOSE 7331

# 開発用のコマンド
CMD ["make", "live"]

# -------------------- #
# - 本番環境用(ビルド) - #
# -------------------- #

# ビルドステージ
FROM base AS build

# ビルド
RUN CGO_ENABLED=0 GOOS=linux go build -o /entrypoint

# ------------------ #
# - 本番環境用(実行) - #
# ------------------ #

FROM alpine:latest AS production

# 必要なランタイムをインストール
RUN apk add --no-cache ca-certificates

# 作業ディレクトリを設定
WORKDIR /

# ビルド済みのバイナリをコピー
COPY --from=build /entrypoint /entrypoint

# 本番用のポートを公開
EXPOSE 8080

# エントリポイントを実行
ENTRYPOINT ["/entrypoint"]