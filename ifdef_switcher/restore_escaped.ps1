# <License>------------------------------------------------------------

#  Copyright (c) 2019 Shinnosuke Yakenohara

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# -----------------------------------------------------------</License>

# <User Settings>-----------------------------------------

$enc_name = "utf-8"

$strarr_extentions = @(
    "`.c",
    "`.h"
)
# ----------------------------------------</User Settings>

#変数宣言
$opRec = "/r" #Recursive処理指定文字列
$isRec = $FALSE #Recursiveに処理するかどうか
$opPau = "/p" #エラーがあった場合にpauseする事を指定する文字列
$pauseWhenErr = $FALSE  #エラーがあった場合にpauseするかどうか

$total = 0
$scsOfTotal = 0
$errOfTotal = 0
$file = 0
$scsOfFile = 0
$errOfFile = 0
$dir = 0
$scsOfDir = 0
$errOfDir = 0
$newFile = 0
$scsOfnewFile = 0
$errOfnewFile = 0

# import CommentLexer.ps1
. ( (Split-Path -Parent $MyInvocation.MyCommand.Path) + ".\CommentLexer.ps1")

$listener_1st = {

    # # Show progress on prompt
    $percentage = ($progress[1] / $progress[0].Length) * 100
    Write-Host -NoNewline ("`r" + $percentage.ToString("0").PadLeft(3) + '% processing ' + $path)

    # # Get string from $delimitedBytes that stores analized byte list.
    $str_line = ""
    $str_nlc = ""
    for ($_l1 = 0 ; $_l1 -lt $delimitedBytes.Count ; $_l1++){

        if ($delimitedBytes[$_l1][0].Count -gt 0){
            $str_line = $enc.GetString($delimitedBytes[$_l1][0])
        }

        if ($delimitedBytes[$_l1][1].Count -gt 0){
            $str_nlc = $enc.GetString($delimitedBytes[$_l1][1])
        }
        
    }
    
    # $listener_1st で 変換した文字列の復活
    $str_line = $str_line -replace ' /\* {% tab_or_space %}((\t| )+){% tab_or_space %} \*/ '  , '$1'
    $str_line = $str_line -replace ' /\* {% tab_or_space %}((\t| )+){% tab_or_space %} \*/$'  , '$1'

    # $listener_2nd で 変換した文字列の復活
    $str_line = $str_line -replace '/\* {% vacant_line %}(.*){% vacant_line %} \*/'  , '$1'
    $str_line = $str_line -replace '/\* {% escaped_prepro %}(.+){% escaped_prepro %} \*/', '$1'
    
    $tmp_file_1st.Write($str_line)
    $tmp_file_1st.Write($str_nlc)
}

#Recursiveに処理するかどうかをチェック
$isRec = $FALSE
$mxOfArgs = $Args.count
for ($idx = 0 ; $idx -lt $mxOfArgs ; $idx++){
    
    if($Args[$idx] -eq $opRec){ #Recursive処理指定文字列の場合
        $isRec = $TRUE
        $Args[$idx] = $null #処理対象から除外
        
    } elseif ($Args[$idx] -eq $opPau){ #エラーがあった場合にpauseする事を指定する文字列の場合
        $pauseWhenErr = $TRUE
        $Args[$idx] = $null #処理対象から除外
    }
}

#処理対象リスト作成
$list = New-Object System.Collections.Generic.List[System.String]

foreach ($arg in $args){
    
    if($arg -ne $null){ #処理対象から除外していなければ
        
        $list.Add($arg)
        
        if ((Test-Path $arg -PathType Container) -And ($isRec)){ #ディレクトリでかつRecursive処理指定の場合
            Get-ChildItem  -Recurse -Force -Path $arg | ForEach-Object {
                $list.Add($_.FullName)
            }
        }
    }
}

#パラメータ数チェック
if($list.count -eq 0){ #処理対象が指定されていない
    Write-Host "Argument not specified"
    $errOfTotal = 1
    
}else{ #処理対象が1つ以上ある

    #タイムスタンプ更新ループ
    foreach ($path in $list) {
        
        # Write-Host $path
        
        if (Test-Path $path -PathType leaf) { #ファイルの場合

            $str_ext = [System.IO.Path]::GetExtension($path);

            $bool_in_list = $FALSE # 処理対象拡張子リストに存在するかどうか
            foreach ($str_extention in $strarr_extentions){
                if ( $str_ext -eq $str_extention ){ # 処理対象拡張子リストに存在する場合
                    $bool_in_list = $TRUE
                    break
                }
            }

            if ($bool_in_list) { # ソースコードの場合

                $tmp_path_1st = $path + "_"
                
                # open tmp path
                $enc_obj = [Text.Encoding]::GetEncoding($enc_name)
                if ($enc_obj.CodePage -eq 65001){ # for utf-8 encoding with no BOM
                    $tmp_file_1st = New-Object System.IO.StreamWriter($tmp_path_1st, $false)
                }else{
                    $tmp_file_1st = New-Object System.IO.StreamWriter($tmp_path_1st, $false, $enc_obj)
                }

                LexLine ($path) ($enc_name) ($listener_1st)
                $tmp_file_1st.Close()
                Write-Host
                
                Remove-Item $path
                Rename-Item $tmp_path_1st -newName $path

                $scsOfFile++
            
            }else{ # ソースコードではない場合
                
                #nothing to do
                Write-Host ('100% processing ' + $path)
                $scsOfFile++
            }
            
            $file++
        
        } else { # ディレクトリの場合
            Write-Host ('processing dir  ' + $path)
        }
    }
}
