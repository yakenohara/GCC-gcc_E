:: <License>------------------------------------------------------------

::  Copyright (c) 2019 Shinnosuke Yakenohara

::  This program is free software: you can redistribute it and/or modify
::  it under the terms of the GNU General Public License as published by
::  the Free Software Foundation, either version 3 of the License, or
::  (at your option) any later version.

::  This program is distributed in the hope that it will be useful,
::  but WITHOUT ANY WARRANTY; without even the implied warranty of
::  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::  GNU General Public License for more details.

::  You should have received a copy of the GNU General Public License
::  along with this program.  If not, see <http://www.gnu.org/licenses/>.

:: -----------------------------------------------------------</License>

@echo off

::param check
if "%1" == "" goto PARAM_ERROR
if NOT EXIST "%1" (
goto NOT_FOUND_ERROR
)

::initialize
set fromDir=%~1
set tmpDir=%fromDir%_tmp
set outDir=%fromDir%_switched
@echo on

::作業用ディレクトリ作成
if EXIST "%tmpDir%" (
rmdir /s /q "%tmpDir%"
)
xcopy "%fromDir%" "%tmpDir%" /e /i

::プリプロセス除外
@echo off
set ps1FileName=escape_preprocess.ps1
set param=\"%tmpDir%\"
@echo on
powershell -ExecutionPolicy Unrestricted "& \"%~dp0%ps1FileName%\" %param% /r"

::プリプロセス
@echo off
set ps1FileName=gcc_recursively.ps1
set param=\"%tmpDir%\" \"%outDir%\"
@echo on
powershell -ExecutionPolicy Unrestricted "& \"%~dp0%ps1FileName%\" %param%"
::エラーチェック
@echo off
if %ERRORLEVEL% neq 0 (
goto GCC_ERROR
)
@echo on

::プリプロセス除外したキーワードの復活
@echo off
set ps1FileName=restore_escaped.ps1
set param=\"%outDir%\"
@echo on
powershell -ExecutionPolicy Unrestricted "& \"%~dp0%ps1FileName%\" %outDir% /r"

::作業用ディレクトリ削除
rmdir /s /q "%tmpDir%"

@echo;
@echo Done!
::@pause
@exit /B 0

:PARAM_ERROR
@echo Direcotory not specified
@exit /B 1

:NOT_FOUND_ERROR
@echo Specified directory "%~1" not found
@exit /B 1

:GCC_ERROR
@echo gcc error
@pause
@exit /B 1
