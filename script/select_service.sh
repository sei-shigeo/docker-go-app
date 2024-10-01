#!/bin/bash

# 引数がない場合（サービスが指定されていない場合）にエラーを表示して終了
if [ $# -eq 0 ]; then
    echo "エラー: サービスが指定されていません。"
    exit 1
fi

# 引数（サービス名）を配列に格納
services=($@)

echo "サービスを選択してください:"

# selectコマンドを使用してユーザーにサービスを選択させる
select service in "${services[@]}"; do
    # 選択されたサービスが空でない場合（有効な選択の場合）
    if [ -n "$service" ]; then
        echo "選択されたサービス: $service"
        # docker-composeを使用して選択されたサービスのシェルを実行
        docker-compose -f ./docker/docker-compose.yml exec $service /bin/sh
        break  # 選択が完了したらループを抜ける
    else
        # 無効な選択の場合、エラーメッセージを表示して再選択を促す
        echo "無効な選択です。もう一度試してください。"
    fi
done