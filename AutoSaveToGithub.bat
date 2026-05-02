@echo off
title GitHub Auto-Sync
echo ==============================================
echo GitHub Auto-Sync is RUNNING...
echo Leave this window open to automatically save 
echo your code to GitHub every 60 minutes.
echo Close this window to stop auto-saving.
echo ==============================================

:loop
echo.
echo [%time%] Checking for changes...
git add .
git diff --staged --quiet
if errorlevel 1 (
    echo Changes detected! Pushing to GitHub...
    git commit -m "Auto-save update"
    git push
    echo Successfully pushed!
) else (
    echo No changes detected.
)

:: Wait for 3600 seconds (60 minutes) before checking again
timeout /t 3600 /nobreak
goto loop
