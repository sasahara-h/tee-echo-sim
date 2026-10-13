# tee-sim

## プロジェクトの目的

小児・成人向けの TEE（経食道心エコー）シミュレータ。

- Three.js r128 を使い、`index.html` の1ファイルで完結している
- `python -m http.server 8000` で配信し、http://localhost:8000/ を開く

## 座標系と操作の符号

- 座標系は BodyParts3D 準拠：+X が患者の左、+Y が背側、+Z が頭側（単位は mm）
- `rot`（回転）：＋が時計回り（患者の右）
- `ante`：＋が前屈
- `lr`：＋が右屈
- オムニプレーン角：0° では画面右が患者の左、90° では画面右が頭側

## 数値を変えないこと

`PRESETS` と `PATH_PTS` の数値は、心臓メッシュの目印と ASE ガイドライン（Hahn 2013、Puchalski 2019）の角度範囲に合わせて計算したもの。

- 勝手に丸めたり変えたりしない
- 変えるときは理由を説明する

## 練習モード

`COURSE` は「ベース断面 → 派生断面」の木構造。ベースは次の3つ。

- ME 4C
- TG mid SAX
- UE 大動脈弓 LAX

## 生成ファイル

- `source/` の生成ファイル（`bodyparts3d.js`、`bodyparts3d_volume.js`）はコミットしない
- リポジトリ直下の `bodyparts3d.js` が本番用

## 作業ルール

- `index.html` を変更したら、ブラウザで確認してからコミットする
- 別の Claude（claude.ai 側）が同じファイルを編集することがある。編集前に `git status` で未コミットの変更がないか確認する
