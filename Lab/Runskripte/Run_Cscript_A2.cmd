@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM Run-Skript fuer Cscript A2
REM
REM Aufgabe:
REM - nimmt eine Run-ID entgegen
REM - erfasst Start- und Endzeitpunkt der Testhandlung
REM - startet die Cscript-A2-Testdatei
REM - erfasst den Exitcode von cscript.exe
REM - prueft, ob die Download-Datei vorhanden ist
REM - schreibt ein Laufprotokoll
REM
REM Die SHA-256-Pruefung der heruntergeladenen Datei erfolgt
REM nach der KAPE-Erhebung auf dem Hostsystem.
REM ============================================================

if "%~1"=="" (
    echo FEHLER: Es wurde keine Run-ID angegeben.
    echo Beispiel: Run_Cscript_A2.cmd DEV-CS-A2-P2-01
    exit /b 2
)

set "RUN_ID=%~1"

REM Festgelegte Dateien und Pfade.
set "COMPONENT=C:\Windows\System32\cscript.exe"
set "TEST_FILE=C:\Lab\TestFiles\Cscript\A2_Cscript.js"
set "DESTINATION_FILE=C:\Lab\Outputs\A2\a2_download_test_v1.txt"
set "LOG_FILE=C:\Lab\RunLogs\%RUN_ID%.txt"

REM Die Testdatei muss vorhanden sein.
if not exist "%TEST_FILE%" (
    echo FEHLER: Die A2-Testdatei wurde nicht gefunden.
    exit /b 3
)

REM Startzeitpunkt unmittelbar vor der eigentlichen Testhandlung.
set "RUN_START=%DATE% %TIME%"

REM JScript explizit ueber Windows Script Host ausfuehren.
"%COMPONENT%" //E:JScript //B //NoLogo "%TEST_FILE%"

REM Exitcode unmittelbar nach Beendigung sichern.
set "TARGET_EXIT_CODE=!ERRORLEVEL!"

REM Prozessendzeitpunkt erfassen.
set "PROCESS_END=%DATE% %TIME%"

REM Nach Prozessende wird nur kontrolliert,
REM ob die erwartete Download-Datei vorhanden ist.
set "DESTINATION_FILE_EXISTS=NO"
set "TECHNICAL_COMPLETION=NO"

if exist "%DESTINATION_FILE%" (
    set "DESTINATION_FILE_EXISTS=YES"
)

if "!TARGET_EXIT_CODE!"=="0" if "!DESTINATION_FILE_EXISTS!"=="YES" (
    set "TECHNICAL_COMPLETION=YES"
)

REM Laufprotokoll schreiben.
(
    echo RunID=!RUN_ID!
    echo Component=cscript.exe
    echo ActionClass=A2
    echo ComputerName=!COMPUTERNAME!
    echo UserName=!USERNAME!
    echo TestFile=!TEST_FILE!
    echo CommandLine="!COMPONENT!" //E:JScript //B //NoLogo "!TEST_FILE!"
    echo DestinationFile=!DESTINATION_FILE!
    echo RunStart=!RUN_START!
    echo ProcessEnd=!PROCESS_END!
    echo TargetProcessExitCode=!TARGET_EXIT_CODE!
    echo DestinationFileExists=!DESTINATION_FILE_EXISTS!
    echo TechnicalCompletion=!TECHNICAL_COMPLETION!
    echo HostSHA256Verification=PENDING
) > "%LOG_FILE%"

echo.
echo ============================================================
echo Cscript A2 abgeschlossen.
echo Run-ID: !RUN_ID!
echo Exitcode: !TARGET_EXIT_CODE!
echo Download-Datei vorhanden: !DESTINATION_FILE_EXISTS!
echo Technischer Run abgeschlossen: !TECHNICAL_COMPLETION!
echo SHA-256-Pruefung auf dem Host: PENDING
echo Protokoll: !LOG_FILE!
echo ============================================================

if "!TECHNICAL_COMPLETION!"=="YES" (
    exit /b 0
) else (
    exit /b 1
)