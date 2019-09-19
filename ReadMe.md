C言語のソースコードファイル(*.c, *.h)内の、  
コンパイルスイッチを指定して、 GCC が解釈したソースコードを出力する。

# Requirements

 - GCC
 - Sakura Editor (ver 2.2.0.0 or higher)

# 準備

1. (※インストール時のみ必要※) サクラエディタのパスを、`ifdef_switcher` 配下の以下2つに対して設定する

 - escape_preprocess.ps1
```
$sakuraExeAbusolutePath = "C:\Program Files (x86)\sakura\sakura.exe"
```

 - restore_escaped.ps1
```
$sakuraExeAbusolutePath = "C:\Program Files (x86)\sakura\sakura.exe"
```

2. (※インストール時のみ必要※)`ifdef_switcher` フォルダをまるごと好きなところに配置する
   
3. (※変換対象のソースコードの変更毎に必要※) `gcc`コマンド用のオプション定義ファイル `gcc_option.sh` を編集する

`gcc_option.sh` の `User Defintions` 内を編集する  
↓ 同封のサンプルファイル `example\ex.c` の、`#define` 値、`XXX` と `QQQ(IN)` を有効にする例↓
```
# < User Defintions >----------------------------
-D'XXX'
-D'IN=1'
-D'QQQ(IN)=(IN?1:0)'
# ----------------------------</ User Defintions >
```

# Usage

`ifdef_switcher\ifdef_switcher.bat` に 変換対象の ソースコード (*.c, *.h) を含んだフォルダを指定してたたく。  
↓ 同封の `example` フォルダを指定した例 ↓
```
.\ifdef_switcher\ifdef_switcher.bat example > log.txt 2>&1
```
上記の例では、`example` フォルダが配置されたディレクトリに、  
`example_switched` という、`_switched` が付加されたフォルダが生成される。

※生成に失敗した場合は 標準出力にエラー内容が出力されます。  
  エラー内容を確認してください。

# Limitation

 - ソースコード内の改行コード `\r\n` が `\n` に変換されてしまう
  
 - ソースコード内の空行は削除されてしまう

 - Cgywin の `gcc-core` 環境の場合  
   変換対象のソースコードのパスに日本語が入っていると `No such file or directory` がでることがある

 - MSYS2 の `mingw-w64-x86_64-gcc` 環境の場合  
   `gcc macro names must be identifiers` エラーがでて失敗する


