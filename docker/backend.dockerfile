# ベースイメージとして公式のGoイメージを使用
# これにより、Go言語の開発環境が整った状態から始められます
FROM golang:1.23.1 AS builder

# 作業ディレクトリを設定
# 以降のコマンドはこのディレクトリで実行されます
WORKDIR /app

# Goモジュールファイルをコピーして依存関係をダウンロード
# go.modとgo.sumファイルのみをコピーすることで、依存関係の変更がない限りキャッシュを活用できます
COPY src/backend/go.mod src/backend/go.sum ./
RUN go mod download && go mod verify

# ソースコードをコピー
# 依存関係のダウンロード後にソースコードをコピーすることで、ソースコードの変更時のビルド時間を短縮できます
COPY src/backend .

# アプリケーションをビルド
# CGO_ENABLED=0: Cコンパイラを無効にし、純粋なGoのバイナリを作成
# GOOS=linux: Linuxで実行可能なバイナリを作成
RUN CGO_ENABLED=0 GOOS=linux go build -o myapp

# 実行用の軽量イメージを使用
# alpineは非常に軽量なLinuxディストリビューションで、最終イメージのサイズを小さくできます
FROM alpine:latest

# 必要なSSL証明書をインストール
RUN apk --no-cache add ca-certificates

# 作業ディレクトリを設定
WORKDIR /root/

# ビルドしたアプリケーションをコピー
# --from=0は最初のステージ（golang:1.23.1）を指します
COPY --from=builder /app/myapp .

# コンテナが起動したときに実行されるコマンド
# これにより、コンテナ起動時に自動的にアプリケーションが実行されます
CMD ["./myapp"]