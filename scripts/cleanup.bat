@echo off

setlocal EnableExtensions EnableDelayedExpansion

set "script_dir=%~dp0"
for %%I in ("%script_dir%..") do set "repo_root=%%~fI"
set "cleanup_list_file=%script_dir%cleanup-files"
set "cleanup_directory=%repo_root%\out"
set /A move_artifacts=1

if not "%~1"=="" (
    if /I "%~1"=="--no-move" (
        set /A move_artifacts=0
    ) else (
        set "cleanup_directory=%repo_root%\%~1"
    )
)

if not "%~2"=="" (
    if /I "%~2"=="--no-move" (
        set /A move_artifacts=0
    ) else (
        set "cleanup_directory=%repo_root%\%~2"
    )
)

if not exist "%cleanup_list_file%" (
    echo ERROR: Cleanup list not found at "%cleanup_list_file%".
    exit /b 1
)

echo SCRIPT: CLEANUP
echo Cleaning up build generated files from '%cleanup_list_file%'.
echo Directory: %cleanup_directory%
echo.

for /f "usebackq delims=" %%a in ("%cleanup_list_file%") do (
    set "cleanup_target=%cleanup_directory%\%%a"

    for /f "delims=" %%d in ('dir /b /ad "!cleanup_target!" 2^>nul') do (
        rmdir /s /q "!cleanup_directory!\%%d"
    )

    for /f "delims=" %%f in ('dir /b /a-d "!cleanup_target!" 2^>nul') do (
        del /q /f "!cleanup_directory!\%%f"
    )
)

if !move_artifacts! equ 1 (
    echo.
    echo Moving all generated artifacts to the root directory.
    echo.

    for /f "delims=" %%p in ('dir /b /a-d "%cleanup_directory%\*.pdf" 2^>nul') do (
        move /y "%cleanup_directory%\%%p" "%repo_root%\"
    )
)

echo.
echo Cleaned up after build.
echo Done.