@echo on
set pwd=%~dp0
set example_path=%pwd%..\example
cd %example_path%
start /wait cmd /c "flutter build windows"
del /q build\windows\meeting_flutter.zip
cd %example_path%\build\windows\x64\runner\Release\
"C:\Program Files\7-Zip\7z.exe" a -tzip -r %example_path%\build\windows\meeting_flutter.zip *
cd %example_path%
copy /y %example_path%\build\windows\meeting_flutter.zip D:\aoeiuv020\sk\server\meeting\meeting_flutter_windows.zip
