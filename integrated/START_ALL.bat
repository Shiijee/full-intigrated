@echo off
echo ============================================================
echo   IT 3012 Integration Hub - Starting All Systems
echo ============================================================
echo.
echo [1/3] Starting TestPoint on port 5000...
start "TestPoint" cmd /k "cd testpoint_app && pip install -r requirements.txt -q && python app.py"
timeout /t 3 >nul

echo [2/3] Starting Voxify on port 5001...
start "Voxify" cmd /k "cd voxify_app && pip install -r requirements.txt -q && python app.py"
timeout /t 3 >nul

echo [3/3] Starting NewChange on port 5002...
start "NewChange" cmd /k "cd newchange_app && pip install -r requirements.txt -q && python app.py"
timeout /t 3 >nul

echo [4/4] Starting Integration Hub on port 5003...
start "Hub" cmd /k "cd hub && pip install flask requests -q && python app.py"
timeout /t 2 >nul

echo.
echo All systems starting! Open these URLs:
echo   TestPoint  : http://localhost:5000
echo   Voxify     : http://localhost:5001
echo   NewChange  : http://localhost:5002
echo   Hub        : http://localhost:5003  (open this for the demo)
echo.
pause
