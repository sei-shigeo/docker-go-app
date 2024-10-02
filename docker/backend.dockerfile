# ベースイメージとして公式のGoイメージを使用
FROM golang:1.23.2

# 作業ディレクトリを設定
WORKDIR /app

# airをインストール
RUN go install github.com/a-h/templ/cmd/templ@latest

# Goモジュールファイルをコピーして依存関係をダウンロード
COPY src/backend/go.mod src/backend/go.sum ./
RUN go mod download && go mod verify

# ソースコードをコピー
COPY src/backend .

# ポートを公開
EXPOSE 8080
EXPOSE 7331

CMD ["make", "live"]