@echo off
set "LOCALAPPDATA=C:\Users\ASUS\AppData\Local"
set "APPDATA=C:\Users\ASUS\AppData\Roaming"
set "PUB_CACHE=C:\Users\ASUS\AppData\Local\Pub\Cache"
mkdir "%APPDATA%" 2>nul
mkdir "%LOCALAPPDATA%" 2>nul
mkdir "%PUB_CACHE%" 2>nul
E:\flutter\flutter\bin\flutter.bat pub get
