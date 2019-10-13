C言語のソースコードファイル(*.c, *.h)内の、  
コンパイルスイッチを指定して、 GCC が解釈したソースコードを出力する。  
  
Limitation 多すぎ。  
改行コードが `\n` に強制変換されてしまうので、あらかじめ改行コードを `\n` に変換したソースコードと、  
このスクリプトが出力したソースコードの Diff を、参考情報として使う程度の代物。

# Requirements

 - GCC(パスが通っている事)

# Installation

`ifdef_switcher` フォルダをまるごと好きなところに配置する

# Usage

## Edit settings before run
   
1. `gcc` コマンド用のオプション定義ファイル `gcc_option.sh` 内の、`User Defintions` 内を編集する.
 

※ Do not use following
- space characters
- comment out keyword `<<`
- return escaping `\`, like as follow
  ```
  -D'QQQ(IN)=(IN? \
              TRUE: \
              FALSE \
             )'
  ```

↓ 同封のサンプルファイル `example\ex.c` の、`#define` 値、`XXX` と `QQQ(IN)` を有効にする例 ↓
```shellscript
# < User Defintions >----------------------------
-D'XXX'
-D'IN=1'
-D'QQQ(IN)=(IN?1:0)'
# ----------------------------</ User Defintions >
```

2. 文字エンコーディング

以下ファイル内の `$enc_name = "utf-8"` を環境に合わせて編集する  

 - escape_preprocess.ps1  
 - restore_escaped.ps1  

↓ シフト JIS を設定する例 ↓  

```powershell
`$enc_name = "shift_jis"`
```
※設定可能な文字エンコーディングのリストは、Powershell ターミナルで以下を実行する事で確認可能。  

```powershell
&{
    for($cnt = 0; $cnt -lt 65535; $cnt++){
        try{
            $enc = [Text.Encoding]::GetEncoding($cnt)
            $web_name = $enc.WebName
            $enc_name = $enc.EncodingName
            Write-Output "$cnt, $web_name, $enc_name"
        } catch {}
    }
}
```

## Run

`ifdef_switcher\ifdef_switcher.bat` に 変換対象の ソースコード (*.c, *.h) を含んだフォルダを指定してたたく。  

↓ 同封の `example` フォルダを指定した例 ↓
```
.\ifdef_switcher\ifdef_switcher.bat example > log.txt 2>&1
```
上記の例では、`example` フォルダの隣に、`example_switched` という、`_switched` が付加されたフォルダが生成される。

※生成に失敗した場合は 標準出力にエラー内容が出力されます。  
  エラー内容を確認してください。

# Limitation

## GCC に起因するもの

 - Cgywin の `gcc-core` 環境の場合  
   変換対象のソースコードのパスに日本語が入っていると `No such file or directory` がでることがある

 - MSYS2 の `mingw-w64-x86_64-gcc` 環境の場合  
   `gcc macro names must be identifiers` エラーがでて失敗する

## `gcc -E` コマンドに起因するもの

 - ソースコード内の `#include` は無視する仕様。  
   無視しないと、指定したインクルードファイル内の全文字列を展開した状態のソースコードが出力されてしまうから。  
   その為、インクルードファイル内に `#ifdef` スイッチを制御するための `#define` 値を定義している場合は、  
   `gcc_option.sh` 内のオプションにその `#define` 値を定義して使用する。  

 - ソースコード内の改行コード `\r\n` が `\n` に変換されてしまう
 - ファイルの最終行が空文字でない場合は、強制的に空行が付加される
  