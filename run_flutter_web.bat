@echo off
echo ===================================================
echo   Smart Soil (SKIT Group AI-12) - Flutter Web
echo ===================================================
echo Starting local web server on port 8080...
cd /d "%~dp0app"
start "" "http://localhost:8080"
python -m http.server 8080 --directory build/web
pause
