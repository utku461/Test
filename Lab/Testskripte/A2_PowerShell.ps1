# ============================================================
# Testskript fuer PowerShell A2
#
# Aufgabe:
# - ruft eine festgelegte Referenzdatei ueber HTTPS ab
# - speichert sie unter dem einheitlichen A2-Zielpfad
# - fuehrt die heruntergeladene Datei nicht aus
# ============================================================

# Bei einem Fehler wird die Ausfuehrung beendet
# und der Catch-Block aufgerufen.
$ErrorActionPreference = "Stop"

# Commit-spezifische URL der festgelegten Referenzdatei.
# Durch den festen Commit wird immer derselbe Dateistand abgerufen.
$sourceUrl = "https://raw.githubusercontent.com/utku461/Test/51825ebe3d485e3cf877d09c04deb9914900a81a/testfiles/a2_download_test_v1.txt"

# Festgelegter lokaler Zielpfad fuer A2.
$destinationFile = "C:\Lab\Outputs\A2\a2_download_test_v1.txt"

try {

    # Die festgelegte Referenzdatei wird ueber HTTPS abgerufen
    # und am definierten Zielpfad gespeichert.
    Invoke-WebRequest `
        -Uri $sourceUrl `
        -OutFile $destinationFile `
        -UseBasicParsing

    # Kontrolle, ob der Download eine Datei erzeugt hat.
    if (-not (Test-Path -LiteralPath $destinationFile)) {
        throw "Die heruntergeladene Datei wurde nicht gefunden."
    }

    Write-Host "A2 wurde erfolgreich ausgefuehrt."
    Write-Host "Gespeicherte Datei: $destinationFile"

    # Die heruntergeladene Datei wird nicht ausgefuehrt
    # und nicht installiert.
    exit 0
}
catch {

    Write-Error "A2 ist fehlgeschlagen: $($_.Exception.Message)"
    exit 1
}