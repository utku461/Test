@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM Run-Skript fuer PowerShell A1
REM
REM Aufgabe:
REM - nimmt eine Run-ID entgegen
REM - erfasst Start- und Endzeitpunkt der Testhandlung
REM - startet das PowerShell-A1-Testskript
REM - erfasst den Exitcode des Zielprozesses
REM - prueft die erzeugte A1-Ergebnisdatei
REM - schreibt ein Laufprotokoll
REM ============================================================

REM Eine Run-ID muss als erster Parameter uebergeben werden.
if "%~1"=="" (
    echo FEHLER: Es wurde keine Run-ID angegeben.
    echo Beispiel: Run_PowerShell_A1.cmd PILOT-PS-A1-P2-01
    exit /b 2
)

set "RUN_ID=%~1"

REM Festgelegte Dateien und Pfade.
set "TEST_SCRIPT=C:\Lab\TestFiles\PowerShell\A1_PowerShell.ps1"
set "RESULT_FILE=C:\Lab\Outputs\A1\A1_PowerShell_Result.txt"
set "LOG_FILE=C:\Lab\RunLogs\%RUN_ID%.txt"

REM Das Testskript muss vorhanden sein.
if not exist "%TEST_SCRIPT%" (
    echo FEHLER: Das A1-Testskript wurde nicht gefunden.
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
REM Funktionale Erfolgskontrolle nach Ende der Testhandlung.
REM ============================================================

set "RESULT_FILE_EXISTS=NO"
set "RESULT_CONTENT_CORRECT=NO"
set "FUNCTIONAL_SUCCESS=NO"

if exist "%RESULT_FILE%" (

    set "RESULT_FILE_EXISTS=YES"

    findstr /c:"ActionClass=A1" "%RESULT_FILE%" >nul
    set "CHECK_ACTION=!ERRORLEVEL!"

    findstr /c:"Component=powershell.exe" "%RESULT_FILE%" >nul
    set "CHECK_COMPONENT=!ERRORLEVEL!"

    findstr /c:"Result=SUCCESS" "%RESULT_FILE%" >nul
    set "CHECK_RESULT=!ERRORLEVEL!"

    if "!CHECK_ACTION!"=="0" if "!CHECK_COMPONENT!"=="0" if "!CHECK_RESULT!"=="0" (
        set "RESULT_CONTENT_CORRECT=YES"
    )
)

REM A1 gilt als funktional erfolgreich, wenn
REM - powershell.exe Exitcode 0 liefert,
REM - die Ergebnisdatei vorhanden ist und
REM - der erwartete Inhalt enthalten ist.
if "!TARGET_EXIT_CODE!"=="0" if "!RESULT_FILE_EXISTS!"=="YES" if "!RESULT_CONTENT_CORRECT!"=="YES" (
    set "FUNCTIONAL_SUCCESS=YES"
)

REM ============================================================
REM Laufprotokoll schreiben.
REM ============================================================

(
    echo RunID=!RUN_ID!
    echo Component=powershell.exe
    echo ActionClass=A1
    echo ComputerName=!COMPUTERNAME!
    echo UserName=!USERNAME!
    echo TestScript=!TEST_SCRIPT!
    echo CommandLine=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!TEST_SCRIPT!"
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
echo PowerShell A1 abgeschlossen.
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