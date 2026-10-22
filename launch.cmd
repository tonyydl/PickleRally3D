@echo off
cd /d "%~dp0"
where godot >nul 2>nul
if errorlevel 1 (
    echo Godot 4 was not found in PATH. Open project.godot in Godot and press F5.
    pause
    exit /b 1
)
godot --path "%~dp0."
