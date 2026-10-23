# tee-sim

## プロジェクトの目的

小児・成人向けの TEE（経食道心エコー）シミュレータ。

- Three.js r128 を使い、`index.html` の1ファイルで完結している
- `python -m http.server 8000` で配信し、http://localhost:8000/ を開く

## 公開URL

- https://sasahara-h.github.io/tee-echo-sim/ （GitHub Pages、リポジトリ https://github.com/sasahara-h/tee-echo-sim の master ブランチのルート）
- 更新するときは master に push するだけで反映される（ビルドは数分かかる。混んでいると 20 分ほど待つこともある）
- 公開リポジトリなので、Wi-Fi のパスワード・APIキー・個人情報などはコミットしない
  - 例外：Metered の TURN 認証情報は承知のうえで index.html に入れている（漏れたら Metered で作り直す）
- コミットのメールアドレスは GitHub の非公開アドレス（`344892775+sasahara-h@users.noreply.github.com`、このリポジトリの `git config user.email`）にしてある

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

## 使用ライブラリ

すべて CDN から読み込み、バージョンを固定している。

- Three.js r128（cdnjs）と OrbitControls（jsdelivr、three@0.128.0）：3D・エコー描画
- PeerJS 1.5.4（jsdelivr）：連動モードの WebRTC 接続。仲介は PeerJS の公開サーバー
- qrcodejs 1.0.0（cdnjs）：連動モードのコントローラー用 URL の QR コード

PeerJS と qrcodejs は、連動モードを使うとき（「📱 スマホで操作」を押したとき、または `?controller=` で開いたとき）だけ読み込む。読み込めなくても通常モードは動く。

## 連動モード

- 公開URL で開けば、そのまま https のコントローラー用 QR が出る（ローカルサーバー不要）
- 手元で試すときは、スマホから開けるように `python -m http.server 8000 --bind 0.0.0.0` で起動し、PC も IP アドレス（`http://192.168.x.x:8000/`）で開く
- スマホ側は `index.html?controller=部屋ID`。3D とエコーは描画せず、ハンドル操作だけを送る

## 生成ファイル

- `source/` の生成ファイル（`bodyparts3d.js`、`bodyparts3d_volume.js`）はコミットしない
- リポジトリ直下の `bodyparts3d.js` が本番用

## 作業ルール

- `index.html` を変更したら、ブラウザで確認してからコミットする
- 別の Claude（claude.ai 側）が同じファイルを編集することがある。編集前に `git status` で未コミットの変更がないか確認する
- ハードウェア（模型ハンドル）の経緯と決定事項は docs/handoff-route1-sensor-nav.md を読むこと
