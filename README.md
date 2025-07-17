#　海底地形データの作り方（J-DSS 500mメッシュ水深）

 実行環境は，macOS Sonoma 14.5 QGIS3.42.1
## データの入手
 1. https://www.jodc.go.jp/vpage/depth500_file_j.html にアクセスし，必要な地域のデータをダウンロード
 2. ダウンロードしたファイルを解凍し，作業ディレクトリに移動
## データの編集
　データの中身はこんな感じ．
 ```
 1  37.10693 137.00159     5
0  37.10242 137.00186     2
0  37.09792 137.00215     8
0  37.09341 137.00243    13
1  37.08891 137.00272    10
 ```

データフォーマット
種別（0または1）、緯度（単位：度）、経度（単位：度）、水深（単位：ｍ）
・フォーマット[ I1、F10.5、F10.5、I6 ]
・種別　　0： 計測水深または等深線から求めた水深、1： 補間処理により作成された水深
・測地系は、世界測地系(WGS-84)を採用しています。
（https://www.jodc.go.jp/jodcweb/JDOSS/infoJEGG_j.html）

コンマ区切りではない，経度と水深の間のスペースの数が桁数によって異なるのでこれをcsv形式に修正します
~~何をどう考えたらこんな形式のデータを作ろうと思うのか．．．~~

まず，このtxtをまとめてcsvに変換するシェルスクリプトを作成する．ファイル名はconvert.shで．
```bash:convert.sh
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
```

ターミナルで以下の手順でファイルを動かす．
作業ディレクトリに移動し，
```bash
#実行権限を与える
chmod -x covert.sh
```
```bash
#実行
./convert.sh mesh500_36_136.txt mesh500_36_137.txt mesh500_37_136.txt mesh500_37_137.txt 
```
うまく行けば
```bash
変換完了: merged.csv
```
が表示される．出力ファイル名を変えたければconvert.shを編集すればOK！

marge.csvの中身はこんな感じ
```csv
latitude,longitude,depth
36.274600,136.066730,-89.000000
36.270100,136.067060,-86.000000
36.265610,136.067410,-85.000000
36.261100,136.067730,-83.000000
36.256600,136.068080,-82.000000
36.252110,136.068440,-80.000000
36.247610,136.068770,-78.000000
36.243110,136.069110,-77.000000
36.238610,136.069440,-77.000000
```

## QGIS上で表示＆出力
QGISを開き，レイヤ→レイヤの追加→csvテキストレイヤを追加...
![fig1](https://github.com/user-attachments/assets/e6587366-b4d9-4523-ad69-eb8368d2ac34)
![fig2](https://github.com/user-attachments/assets/8ba25144-84f5-48d7-be4b-f1baa24e5bac)
ジオメトリ定義のX値にlongitude, Y値にlatitude, Z値にdepthを入れてレイヤーを追加

するとこんな感じ
![fig3](https://github.com/user-attachments/assets/3e4a6d62-99ee-4641-be0a-3f5b52a6add3)

このcsvをラスターに変換します．
1. csvレイヤーをベクターデータにエクスポート（形式は何でもOK．geojsonをおすすめする）
2. ラスタ→変換→ベクタをラスタ化を選択
3. 入力レイヤにベクターデータを入れ，焼き込む値の属性は”depth”を選択，出力ラスタライズの単位を地理単位に設定し，水平垂直どちらも500に設定する（500mメッシュなので）
![fig4](https://github.com/user-attachments/assets/950a84d6-bb51-4ef5-8e56-cab21dd007b5)
4. 実行

これでgeotiffが出力されたらOK
![fig5](https://github.com/user-attachments/assets/b66d0f55-0d99-47d5-9e87-196613e63e09)

ところどころデータが抜けていたりするのであとはいい感じに補完すれば終了．