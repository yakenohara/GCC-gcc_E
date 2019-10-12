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
rm -r -f "%tmpDir%"
)
xcopy "%fromDir%" "%tmpDir%" /e /i

::プリプロセス除外
@echo off
set ps1FileName=escape_preprocess.ps1
set param=\"%tmpDir%\"
@echo on
powershell -ExecutionPolicy Unrestricted "& \"%~dp0%ps1FileName%\" %param% /r"
pause
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
rm -r -f "%tmpDir%"

@echo;
@echo %0 Done!
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
