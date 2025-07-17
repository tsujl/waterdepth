#!/bin/bash

# 出力ファイル名
output_file="merged.csv"

# ヘッダを書き込み
echo "latitude,longitude,depth" > "$output_file"

# 入力ファイルをループ
for file in "$@"; do
    awk '{if (NF>=4) printf "%f,%f,%f\n", $2, $3, -$4}' "$file" >> "$output_file"
done

echo "変換完了: $output_file"

