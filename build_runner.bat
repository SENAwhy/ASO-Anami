@echo off
set "LOCALAPPDATA=C:\Users\ASUS\AppData\Local"
set "APPDATA=C:\Users\ASUS\AppData\Roaming"
set "PUB_CACHE=C:\Users\ASUS\AppData\Local\Pub\Cache"
E:\flutter\flutter\bin\dart.bat run build_runner build --delete-conflicting-outputs
