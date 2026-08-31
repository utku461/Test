@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM Run-Skript fuer Regsvr32 A1
REM
REM Aufgabe:
REM - nimmt eine Run-ID entgegen
REM - erfasst Start- und Endzeitpunkt der Testhandlung
REM - startet die lokale A1-Scriptlet-Datei ueber scrobj.dll
REM - erfasst den Exitcode von regsvr32.exe
REM - prueft die erzeugte A1-Ergebnisdatei
REM - schreibt ein Laufprotokoll
REM
REM Besonderheit:
REM Der Exitcode von regsvr32.exe wird dokumentiert, aber nicht
REM als alleiniges Erfolgskriterium verwendet. Entscheidend ist
REM der funktionale Nachweis durch die Ergebnisdatei.
REM ============================================================

if "%~1"=="" (
    echo FEHLER: Es wurde keine Run-ID angegeben.
    echo Beispiel: Run_Regsvr32_A1.cmd DEV-REG-A1-P2-01
    exit /b 2
)

set "RUN_ID=%~1"

REM Festgelegte Dateien und Pfade.
set "COMPONENT=C:\Windows\System32\regsvr32.exe"
set "SCROBJ=C:\Windows\System32\scrobj.dll"
set "TEST_FILE=C:\Lab\TestFiles\Regsvr32\A1_Regsvr32.sct"
set "RESULT_FILE=C:\Lab\Outputs\A1\A1_Regsvr32_Result.txt"
set "LOG_FILE=C:\Lab\RunLogs\%RUN_ID%.txt"

REM Die Testdatei muss vorhanden sein.
if not exist "%TEST_FILE%" (
    echo FEHLER: Die A1-Testdatei wurde nicht gefunden.
    exit /b 3
)

REM Startzeitpunkt unmittelbar vor der eigentlichen Testhandlung.
set "RUN_START=%DATE% %TIME%"

REM Lokales Scriptlet ueber scrobj.dll ausfuehren.
"%COMPONENT%" /s /n /u /i:"%TEST_FILE%" "%SCROBJ%"

REM Exitcode unmittelbar nach Beendigung sichern.
set "TARGET_EXIT_CODE=!ERRORLEVEL!"

REM Prozessendzeitpunkt erfassen.
set "PROCESS_END=%DATE% %TIME%"

REM Funktionale Erfolgskontrolle.
set "RESULT_FILE_EXISTS=NO"
set "RESULT_CONTENT_CORRECT=NO"
set "FUNCTIONAL_SUCCESS=NO"

if exist "%RESULT_FILE%" (
    set "RESULT_FILE_EXISTS=YES"

    findstr /c:"ActionClass=A1" "%RESULT_FILE%" >nul
    set "CHECK_ACTION=!ERRORLEVEL!"

    findstr /c:"Component=regsvr32.exe" "%RESULT_FILE%" >nul
    set "CHECK_COMPONENT=!ERRORLEVEL!"

    findstr /c:"Result=SUCCESS" "%RESULT_FILE%" >nul
    set "CHECK_RESULT=!ERRORLEVEL!"

    if "!CHECK_ACTION!"=="0" if "!CHECK_COMPONENT!"=="0" if "!CHECK_RESULT!"=="0" (
        set "RESULT_CONTENT_CORRECT=YES"
    )
)

REM Bei Regsvr32 entscheidet der funktionale Nachweis.
REM Der Exitcode wird unabhaengig davon dokumentiert.
if "!RESULT_FILE_EXISTS!"=="YES" if "!RESULT_CONTENT_CORRECT!"=="YES" (
    set "FUNCTIONAL_SUCCESS=YES"
)

REM Laufprotokoll schreiben.
(
    echo RunID=!RUN_ID!
    echo Component=regsvr32.exe
    echo ActionClass=A1
    echo ComputerName=!COMPUTERNAME!
    echo UserName=!USERNAME!
    echo TestFile=!TEST_FILE!
    echo CommandLine="!COMPONENT!" /s /n /u /i:"!TEST_FILE!" "!SCROBJ!"
    echo RunStart=!RUN_START!
    echo ProcessEnd=!PROCESS_END!
    echo TargetProcessExitCode=!TARGET_EXIT_CODE!
    echo ResultFile=!RESULT_FILE!
    echo ResultFileExists=!RESULT_FILE_EXISTS!
    echo ResultContentCorrect=!RESULT_CONTENT_CORRECT!
    echo FunctionalSuccess=!FUNCTIONAL_SUCCESS!
) > "%LOG_FILE%"

echo.
echo ============================================================
echo Regsvr32 A1 abgeschlossen.
echo Run-ID: !RUN_ID!
echo Exitcode: !TARGET_EXIT_CODE!
echo Ergebnisdatei vorhanden: !RESULT_FILE_EXISTS!
echo Inhalt korrekt: !RESULT_CONTENT_CORRECT!
echo Funktional erfolgreich: !FUNCTIONAL_SUCCESS!
echo Protokoll: !LOG_FILE!
echo ============================================================

if "!FUNCTIONAL_SUCCESS!"=="YES" (
    exit /b 0
) else (
    exit /b 1
)