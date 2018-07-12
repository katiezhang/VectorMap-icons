@echo off
setlocal enabledelayedexpansion
cd  %~dp0
cd ..
call git pull
for /F %%i in ('git rev-parse --short HEAD') do ( set commitid=%%i)
md dist
xcopy /e fonts "dist"
set config=C:\config\icons-config.json
set newversion=1
(for /f "tokens=* delims= " %%i in (%config%) do (
    set s=%%i
    if "!s:~12,7!" neq "%commitid%" (
        set  "cur=!s:~21,3!"
        set /a cur=1!cur!-1000+1
		if !cur! LEQ 9 (
			set cur=00!cur!
		)
		if !cur! GTR 9 if !cur! LEQ 99 (
			set cur=0!cur!)
        if "!s:~1,7!" == "version" (
            set "newversion=!s:~11,10!!cur!"
                echo "version":"!s:~11,10!!cur!")
        if "!s:~1,8!" == "lastHead" (
            echo "lastHead":"%commitid%",)
        if "!s:~1,7!" neq "version" if "!s:~1,8!" neq "lastHead" (echo %%i)
    ) else (goto end)
))>icons-config.json
call move icons-config.json C:\config\icons-config.json
call aws s3 cp dist\thinkgeo-icons-webfont.css s3://cdnorigin.thinkgeo.com/vectormap-icons/%newversion%/
call aws s3 cp dist\thinkgeo-icons-webfont.eot s3://cdnorigin.thinkgeo.com/vectormap-icons/%newversion%/
call aws s3 cp dist\thinkgeo-icons-webfont.svg s3://cdnorigin.thinkgeo.com/vectormap-icons/%newversion%/
call aws s3 cp dist\thinkgeo-icons-webfont.ttf s3://cdnorigin.thinkgeo.com/vectormap-icons/%newversion%/
call aws s3 cp dist\thinkgeo-icons-webfont.woff s3://cdnorigin.thinkgeo.com/vectormap-icons/%newversion%/
call aws s3 cp dist\webfontloader.js s3://cdnorigin.thinkgeo.com/vectormap-icons/%newversion%/
call cd  %~dp0
call npm init -y 
call npm install vectormap-icons
call xcopy /y /c /h /r ..\dist\"*"  node_modules\vectormap-icons
call cd node_modules\vectormap-icons
call setlocal enabledelayedexpansion
set f=package.json
(for /f "tokens=* delims= " %%i in (%f%) do (
set s=%%i
if "!s:~1,7!" =="version" (
for /f "tokens=1* delims=:" %%j in ('echo !s!') do (
echo %%j:"%newversion%")
) 

if "!s:~1,7!" neq "version" echo !s!))>temp.json
del package.json
ren "temp.json" "package.json"
call npm publish 
call cd ..\..\..\
call git clean -xdf
:end