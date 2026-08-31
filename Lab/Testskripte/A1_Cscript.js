// ============================================================
// Testdatei fuer Cscript A1
//
// Aufgabe:
// - erzeugt eine definierte A1-Ergebnisdatei
// - startet keine weiteren Prozesse
// ============================================================

// Festgelegter Pfad der A1-Ergebnisdatei.
var resultFile =
    "C:\\Lab\\Outputs\\A1\\A1_Cscript_Result.txt";

try {

    // FileSystemObject dient zum Erzeugen der Referenzdatei.
    var fso =
        new ActiveXObject("Scripting.FileSystemObject");

    var file =
        fso.CreateTextFile(
            resultFile,
            true
        );

    file.WriteLine("ActionClass=A1");
    file.WriteLine("Component=cscript.exe");
    file.WriteLine("Result=SUCCESS");

    file.Close();

    WScript.Echo("A1 wurde erfolgreich ausgefuehrt.");
    WScript.Echo("Ergebnisdatei: " + resultFile);

    WScript.Quit(0);
}
catch (e) {

    WScript.Echo(
        "A1 ist fehlgeschlagen: " + e.message
    );

    WScript.Quit(1);
}