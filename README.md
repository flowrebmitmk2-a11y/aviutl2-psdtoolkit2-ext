# aviutl2-psdtoolkit2-ext

ローカルの `PSDToolKit` 構成を参考にした、AviUtl2 Script 系 repo の雛形です。
公開先は `flowrebmitmk2-a11y/aviutl2-psdtoolkit2-ext` を想定しています。

## 目的

- plugin repo とは別に script 系資産を管理する
- `PSDToolKit.lua` の upstream 変更を追いやすくする
- GitHub Actions で Lua 構文チェックと upstream 差分確認を行う

## 構成

- `src/PSDToolKit.lua`: 追跡対象の Lua スクリプト
- `src/@PSDToolKit.obj2`: object 定義
- `src/@PSDToolKit.anm2`: animation 定義
- `scripts/check-lua-syntax.ps1`: Lua 構文チェック
- `scripts/check-upstream.ps1`: upstream との差分確認

## upstream 追跡

GitHub Actions で自動比較したい場合は `UPSTREAM_PSDTOOLKIT_URL` を設定して使います。
