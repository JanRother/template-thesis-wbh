@echo off

setlocal
set "script_dir=%~dp0"
call "%script_dir%scripts\cleanup.bat" %*
