# aviutl2-psdtoolkit2-ext

`aviutl2-psdtoolkit2-ext` は AviUtl2 用のプラグインです。PSDToolKitExt 用の Lua と `.obj2`、`.anm2` を追加します。

## 導入方法

1. release zip を AviUtl2 に取り込みます。
2. 手動で入れる場合は `data/Script/` 配下の 3 ファイルを AviUtl2 の `data/Script/` へコピーします。
3. 必要に応じて AviUtl2 を再起動します。

## AviUtl2 上での簡単な使い方

1. `PSDToolKit` 本体を導入した状態で使います。
2. `@PSDToolKitExt.obj2` や `@PSDToolKitExt.anm2` を読み込むと `PSDToolKitExt.lua` が呼ばれます。
3. upstream の `PSDToolKit.lua` が変わったら互換性を見直します。

## 構成

- `data/Script/@PSDToolKitExt.anm2`
- `data/Script/@PSDToolKitExt.obj2`
- `data/Script/PSDToolKitExt.lua`
- `upstream/PSDToolKit.lua.sha256`: 確認済み upstream Lua のハッシュ
- `scripts/check-lua-syntax.ps1`: `PSDToolKitExt.lua` の構文チェック
- `scripts/check-upstream.ps1`: upstream `PSDToolKit.lua` の変更検知

## 検証

GitHub Actions では次を確認します。

- `PSDToolKitExt.lua` の構文チェック
- upstream `PSDToolKit.lua` の変更検知
