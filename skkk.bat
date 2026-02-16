@echo off
setlocal EnableDelayedExpansion
title Money Calm 1080p Video Builder — FIXED VERSION

REM ===============================
REM PATHS
REM ===============================
set "DESKTOP=%USERPROFILE%\Desktop"
set "FFMPEG=%DESKTOP%\ffmpeg.exe"
set "VIDEOS_FOLDER=%DESKTOP%\moneyvidz"
set "AUDIO_FOLDER=%DESKTOP%\pixabaysongs1"
set "OUTPUT_FOLDER=D:\moneyput"
set "UPLOADER=%DESKTOP%\upload1.py"

REM ===============================
REM VIDEO SETTINGS
REM ===============================
set "WIDTH=1920"
set "HEIGHT=1080"
set "FPS=30"

REM ===============================
REM CHECK FILES AND FOLDERS
REM ===============================
if not exist "%FFMPEG%" echo FFmpeg not found! & exit /b
if not exist "%VIDEOS_FOLDER%" echo Videos folder not found! & exit /b
if not exist "%AUDIO_FOLDER%" echo Audio folder not found! & exit /b
if not exist "%UPLOADER%" echo Uploader script not found! & exit /b
if not exist "%OUTPUT_FOLDER%" mkdir "%OUTPUT_FOLDER%"

for %%A in (1 2 3) do (
    if not exist "%AUDIO_FOLDER%\%%A.mp3" echo Missing audio file %%A.mp3 & exit /b
)

REM ===============================
REM PROCESS VIDEOS
REM ===============================
for %%I in ("%VIDEOS_FOLDER%\*.mp4") do (

    REM ---- choose random duration 1h15m or 1h3m ----
    set /a RAND_DUR=%RANDOM% %% 2
    if !RAND_DUR! EQU 0 (
        set "DURATION=4500"
        set "DUR_LABEL=1h15m"
    ) else (
        set "DURATION=3780"
        set "DUR_LABEL=1h3m"
    )

    REM ---- random audio order ----
    set /a RAND=%RANDOM% %% 6
    if !RAND! EQU 0 set A1=1&set A2=2&set A3=3
    if !RAND! EQU 1 set A1=1&set A2=3&set A3=2
    if !RAND! EQU 2 set A1=2&set A2=1&set A3=3
    if !RAND! EQU 3 set A1=2&set A2=3&set A3=1
    if !RAND! EQU 4 set A1=3&set A2=1&set A3=2
    if !RAND! EQU 5 set A1=3&set A2=2&set A3=1

    set "NAME=%%~nI"
    set "OUT=%OUTPUT_FOLDER%\!NAME!_1080p_!DUR_LABEL!.mp4"

    REM ---- run FFmpeg ----
    "%FFMPEG%" -y ^
        -stream_loop -1 -i "%%I" ^
        -stream_loop -1 -i "%AUDIO_FOLDER%\!A1!.mp3" ^
        -stream_loop -1 -i "%AUDIO_FOLDER%\!A2!.mp3" ^
        -stream_loop -1 -i "%AUDIO_FOLDER%\!A3!.mp3" ^
        -filter_complex "[1:a][2:a][3:a]concat=n=3:v=0:a=1[aout];[0:v]scale=%WIDTH%:%HEIGHT%,fps=%FPS%,format=yuv420p[vout]" ^
        -map "[vout]" -map "[aout]" ^
        -c:v libx264 -preset veryfast -crf 18 ^
        -pix_fmt yuv420p ^
        -c:a aac -b:a 192k ^
        -t !DURATION! ^
        -movflags +faststart ^
        "!OUT!"

    REM ---- check if output created ----
    if exist "!OUT!" (
        echo ✔ DONE → !OUT!
        python "%UPLOADER%"
    ) else (
        echo ❌ FAILED → %%I
    )

)

echo All done!
exit /b
