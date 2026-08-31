# ============================================================
# Testskript fuer PowerShell A1
#
# Aufgabe:
# - fuehrt eine kontrollierte lokale Testhandlung aus
# - erzeugt eine definierte A1-Ergebnisdatei
# - startet keine weiteren Prozesse
# ============================================================

# Bei einem Fehler wird die weitere Ausfuehrung beendet
# und der Catch-Block aufgerufen.
$ErrorActionPreference = "Stop"

# Festgelegter Pfad fuer die A1-Ergebnisdatei.
$resultFile = "C:\Lab\Outputs\A1\A1_PowerShell_Result.txt"

try {

    # Die Ergebnisdatei dient als funktionaler Nachweis dafuer,
    # dass die A1-Testhandlung erfolgreich ausgefuehrt wurde.
    $resultContent = @(
        "ActionClass=A1"
        "Component=powershell.exe"
        "Result=SUCCESS"
    )

    # Die Ergebnisdatei wird am festgelegten Pfad erzeugt.
    $resultContent |
        Set-Content `
            -LiteralPath $resultFile `
            -Encoding UTF8

    # Kontrolle, ob die Ergebnisdatei erzeugt wurde.
    if (-not (Test-Path -LiteralPath $resultFile)) {
        throw "Die A1-Ergebnisdatei wurde nicht erzeugt."
    }

    Write-Host "A1 wurde erfolgreich ausgefuehrt."
    Write-Host "Ergebnisdatei: $resultFile"

    exit 0
}
catch {

    Write-Error "A1 ist fehlgeschlagen: $($_.Exception.Message)"
    exit 1
}