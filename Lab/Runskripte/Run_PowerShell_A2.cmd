@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM Run-Skript fuer PowerShell A2
REM
REM Aufgabe:
REM - nimmt eine Run-ID entgegen
REM - erfasst Start- und Endzeitpunkt der Testhandlung
REM - startet das PowerShell-A2-Testskript
REM - erfasst den Exitcode des Zielprozesses
REM - prueft, ob die Download-Datei vorhanden ist
REM - schreibt ein Laufprotokoll
REM
REM Die SHA-256-Pruefung der heruntergeladenen Datei erfolgt
REM nach der KAPE-Erhebung auf dem Hostsystem.
REM ============================================================

REM Eine Run-ID muss als erster Parameter uebergeben werden.
if "%~1"=="" (
    echo FEHLER: Es wurde keine Run-ID angegeben.
    echo Beispiel: Run_PowerShell_A2.cmd PILOT-PS-A2-P2-01
    exit /b 2
)

set "RUN_ID=%~1"

REM Festgelegte Dateien und Pfade.
set "TEST_SCRIPT=C:\Lab\TestFiles\PowerShell\A2_PowerShell.ps1"
set "DESTINATION_FILE=C:\Lab\Outputs\A2\a2_download_test_v1.txt"
set "LOG_FILE=C:\Lab\RunLogs\%RUN_ID%.txt"

REM Das Testskript muss vorhanden sein.
if not exist "%TEST_SCRIPT%" (
    echo FEHLER: Das A2-Testskript wurde nicht gefunden.
    exit /b 3
)

REM Startzeitpunkt unmittelbar vor der eigentlichen Testhandlung.
set "RUN_START=%DATE% %TIME%"

REM Start der untersuchten PowerShell-Ausfuehrung.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%TEST_SCRIPT%"

REM Exitcode unmittelbar nach Beendigung des Zielprozesses sichern.
set "TARGET_EXIT_CODE=!ERRORLEVEL!"

REM Prozessendzeitpunkt unmittelbar nach Beendigung erfassen.
set "PROCESS_END=%DATE% %TIME%"

REM ============================================================
REM Funktionale Kontrolle nach Ende der Testhandlung.
REM ============================================================

set "DESTINATION_FILE_EXISTS=NO"
set "TECHNICAL_COMPLETION=NO"

if exist "%DESTINATION_FILE%" (
    set "DESTINATION_FILE_EXISTS=YES"
)

REM An dieser Stelle wird noch nicht der Datei-Hash geprueft.
REM Der technische Run gilt als abgeschlossen, wenn
REM - powershell.exe Exitcode 0 liefert und
REM - die erwartete Download-Datei vorhanden ist.
if "!TARGET_EXIT_CODE!"=="0" if "!DESTINATION_FILE_EXISTS!"=="YES" (
    set "TECHNICAL_COMPLETION=YES"
)

REM ============================================================
REM Laufprotokoll schreiben.
REM ============================================================

(
    echo RunID=!RUN_ID!
    echo Component=powershell.exe
    echo ActionClass=A2
    echo ComputerName=!COMPUTERNAME!
    echo UserName=!USERNAME!
    echo TestScript=!TEST_SCRIPT!
    echo CommandLine=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!TEST_SCRIPT!"
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
echo PowerShell A2 abgeschlossen.
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