// ============================================================
// Testdatei fuer Cscript A2
//
// Aufgabe:
// - ruft die festgelegte Referenzdatei ueber HTTPS ab
// - speichert sie unter dem einheitlichen A2-Zielpfad
// - fuehrt die heruntergeladene Datei nicht aus
// ============================================================

// Commit-spezifische URL der festgelegten Referenzdatei.
var sourceUrl =
    "https://raw.githubusercontent.com/utku461/Test/51825ebe3d485e3cf877d09c04deb9914900a81a/testfiles/a2_download_test_v1.txt";

// Einheitlicher Zielpfad fuer A2.
var destinationFile =
    "C:\\Lab\\Outputs\\A2\\a2_download_test_v1.txt";

try {

    // Synchroner HTTPS-Abruf der Referenzdatei.
    var request =
        new ActiveXObject("WinHttp.WinHttpRequest.5.1");

    request.Open(
        "GET",
        sourceUrl,
        false
    );

    request.Send();

    // Nur HTTP 200 wird als erfolgreicher Abruf akzeptiert.
    if (request.Status != 200) {
        throw new Error(
            "HTTP-Status: " + request.Status
        );
    }

    // Die empfangenen Daten werden binaer und unveraendert
    // am festgelegten Zielpfad gespeichert.
    var stream =
        new ActiveXObject("ADODB.Stream");

    stream.Type = 1;
    stream.Open();
    stream.Write(request.ResponseBody);

    stream.SaveToFile(
        destinationFile,
        2
    );

    stream.Close();

    WScript.Echo("A2 wurde erfolgreich ausgefuehrt.");
    WScript.Echo(
        "Gespeicherte Datei: " + destinationFile
    );

    WScript.Quit(0);
}
catch (e) {

    WScript.Echo(
        "A2 ist fehlgeschlagen: " + e.message
    );

    WScript.Quit(1);
}