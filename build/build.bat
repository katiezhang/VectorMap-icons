@echo off
cd  %~dp0
cd ..
md dist
xcopy /e fonts "dist"
