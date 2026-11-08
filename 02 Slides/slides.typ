#import "@preview/grayness:0.1.0": grayscale-image
#import "@preview/touying:0.7.3": *
#import themes.metropolis: *

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Analyse von *Apache Log4j2* mit *Joern* und *Semgrep*],
    author: [Alexander Ley und Jonathan Ndinga],
    date: [11. Juni 2026],
  ),
  align: top + left,
)

#set list(spacing: 0.8em)

#let java(code) = raw(code.text, lang: "java")

#let codebox(content) = {
  block(
    fill: luma(245),
    inset: 10pt,
    radius: 4pt,
    stroke: 0.5pt + luma(200),
    content,
  )
}

#title-slide()

== Projekt Überblick von *Apache Log4j2*
#place(top + right, clearance: 1em, float: false)[
  #figure(image("assets/Apache_Log4j_Logo.png", width: 25%))
]
- Standard Logging Framework für `Java` in der Industrie
  - gilt als Vorreiter für andere Logging-Frameworks
- Etliche Adaptionen für andere Programmiersprachen
- Auf möglichst hohe Geschwindigkeit ausgelegt, um die Applikation möglichst nicht zu beinträchtigen
- Vollständige Neuentwicklung im Jahre 2014 als Antwort auf die Schwachstellen in *Log4j* $->$ *Log4j2*
- bekanntwerden der *Log4Shell* Sicherheitslücke im Dezember 2021

#rect(
  inset: 0.5em,
  fill: rgb(209, 209, 209, 75),
  stroke: 1pt + black,
)[
  #set text(15pt)
  #set list(spacing: 0.75em)
  === Zahlen und Fakten:
  #table(
    columns: (1fr, 1fr),
    [*Entwickler*: Apache Software Foundation], [*Gegründet*: 1996],
    [*Programmiersprache*: Java], [*Vollständie Neuentwicklung*: Juli 2015],
    [*Commits*: 14.664], [*Aktuelle Version*: 2.26.0],
    [*Java Code Zeilen*: 348.872], [*Forks*: 1.700],
  )
]

== *"Log4shell"* Sicherheitslücke _(CVE-2021-44228)_ in *Log4j2*
#place(horizon + right, clearance: 1em, float: false)[
  #figure(image("assets/Log4j - Meme.png", width: 33%))
]
- Wurde im Dezember 2021 in der aktuellen *Log4j2* Version bekannt #grid(
    columns: (1fr, 1fr),
    [- ermöglicht *Remote Code Execution*], [- CVSS von 10],
  )
  - gilt als eine der gefährlichsten Sicherheitslücken überhaupt
    - *große Reichweite* mit potentiell *verheerenden Folgen*
- viele bekannte Softwareprodukte waren betroffen:
  - Cloudflare, iCloud, Minecraft: Java Edition, ...

=== Ist die Sicherheitslücke nun geschlossen?
- *Ja und Nein*: Veröffentlichung eines Patches, aber nicht\ alle Softwareprodukte updaten Log4j
  - Somit ist diese Sicherheitslücke potentiell noch immer\ relevant

== Tool Setup mit *Joern* und *Semgrep*
#place(top + right, float: false)[
  #figure(image("assets/Tool Setup.png", width: 36%))
]
- Verwendung des in der Übung bereitgestellten \ DevContainer wo *Joern* und *Semgrep* bereits installiert\ waren
- Clonen des Source Code von *Apache Log4j2*#footnote[https://github.com/apache/logging-log4j2]
#v(2em)
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  align: center + horizon,
  [#image("assets/Joern Logo.png", width: 33%)], [#image("assets/Semgrep Logo.png", width: 70%)],
)

== *Joern*: Erste Experimente
#place(top + right, float: false)[
  #figure(image("assets/Joern Logo.png", width: 15%))
]
=== 1. Anzahl der Methoden
#grid(
  columns: (auto, 1cm, 1fr),
  gutter: 1em,
  align: horizon,
  [#codebox[```scala
  cpg.method.l.size
  ```]],
  [#text(25pt)[$=>$]],
  [#text(25pt)[19.643]],
)

#pause
=== 2. Anzahl der Methodenaufrufe
#grid(
  columns: (auto, 1cm, 1fr),
  gutter: 1em,
  align: horizon,
  [#codebox[```scala
  cpg.call.l.size
  ```]],
  [#text(25pt)[$=>$]],
  [#text(25pt)[110.315]],
)

#pause
=== 3. Anzahl der Methodenaufrufe die "#java[execute]" enthalten
#grid(
  columns: (auto, 1cm, 1fr),
  gutter: 1em,
  align: horizon,
  [#codebox[```scala
  cpg.call.filter(_.name.toLowerCase().contains("execute")).l.size
  ```]],
  [#text(25pt)[$=>$]],
  [#text(25pt)[47]],
)
$=>$ "#java[execute]"-Methoden als potentielle *Sinks*

== *Joern*: Weitere Methoden
#grid(
  columns: (1fr, 1fr),
  align: center + horizon,
  gutter: 1em,
  [#image("assets/diag_01.png", width: 100%)], [#image("assets/diag_03.png", width: 100%)],
  [#image("assets/diag_02.png", width: 100%)], [#image("assets/diag_04.png", width: 100%)],
)

== *Joern*: Ein Ausschnitt der "#java[execute]"-Methoden
#codebox[
  #set list(spacing: 0.4em)
  - #java[execute()]
  - #java[executeScript()]
  - #java[executeBatch()]
  - #java[executeUpdate()]
  - #java[executeUpdate(String s)]
  - #java[execute(Runnable runnable)]
  - #java[execute(boolean endOfBatch)]
  - #java[execute(CommandLine parsed)]
  - #java[execute(FileVisitor visitor)]
  - #java[execute(Bindings bindings)]
  - #java[execute(String id, final Bindings bindings)]
  - #java[execute(String name, File source, File destination, boolean deleteSource)]
  - #java[execute(File source, File destination, boolean deleteSource)]
  - #java[execute(File source, File destination, boolean renameEmptyFiles)]
  - #java[execute(File source, File destination, boolean deleteSource, int level)]
]

== *Joern*: Ein Ausschnitt der "#java[execute]"-Methoden
#codebox[
  #set list(spacing: 0.4em)
  - #java[execute()]
  - #highlight(fill: red.lighten(60%))[#java[executeScript()]]
  - #java[executeBatch()]
  - #java[executeUpdate()]
  - #java[executeUpdate(String s)]
  - #highlight(fill: red.lighten(60%))[#java[execute(Runnable runnable)]]
  - #java[execute(boolean endOfBatch)]
  - #highlight(fill: red.lighten(60%))[#java[execute(CommandLine parsed)]]
  - #java[execute(FileVisitor visitor)]
  - #java[execute(Bindings bindings)]
  - #java[execute(String id, final Bindings bindings)]
  - #java[execute(String name, File source, File destination, boolean deleteSource)]
  - #java[execute(File source, File destination, boolean deleteSource)]
  - #java[execute(File source, File destination, boolean renameEmptyFiles)]
  - #java[execute(File source, File destination, boolean deleteSource, int level)]
]
$=>$ Potentielle *Command Injections*

== *Joern*: Ein Ausschnitt der "#java[execute]"-Methoden mit Klassen
#codebox[
  #set list(spacing: 0.4em)
  - #java[execute()] in #java[org.apache.logging.log4j.core.appender.rolling.action.Action]
  - #java[executeScript()] in $[...]$ #java[.log4j.core.appender.rolling.action.DeleteAction]
  - #java[executeBatch()] in #java[java.sql.PreparedStatement]
  - #java[executeUpdate()] in #java[java.sql.PreparedStatement]
  - #java[executeUpdate(String s)] #java[java.sql.Statement]
  - #java[execute(Runnable runnable)] #java[java.util.concurrent.ExecutorService]
  - #java[execute(boolean endOfBatch)]  in $[...]$ #java[.core.async.RingBufferLogEvent]
  - #java[execute(CommandLine parsed)] in $[...]$ #java[.core.tools.picocli.CommandLine]
  - #java[execute(FileVisitor visitor)] in $[...]$ #java[.core.appender.rolling.action.AbstractPathAction]
  - #java[execute(Bindings bindings)] in $[...]$ #java[.core.script.ScriptManager§ScriptRunner]
]

== *Joern*: Ein Ausschnitt der "#java[execute]"-Methoden mit Klassen
#codebox[
  #set list(spacing: 0.4em)
  - #java[execute()] in #java[org.apache.logging.log4j.core.appender.rolling.action.Action]
  - #java[executeScript()] in $[...]$ #java[.log4j.core.appender.rolling.action.DeleteAction]
  - #highlight(fill: red.lighten(60%))[#java[executeBatch()] in #java[java.sql.PreparedStatement]]
  - #highlight(fill: red.lighten(60%))[#java[executeUpdate()] in #java[java.sql.PreparedStatement]]
  - #highlight(fill: red.lighten(60%))[#java[executeUpdate(String s)] #java[java.sql.Statement]]
  - #java[execute(Runnable runnable)] #java[java.util.concurrent.ExecutorService]
  - #java[execute(boolean endOfBatch)]  in $[...]$ #java[.core.async.RingBufferLogEvent]
  - #java[execute(CommandLine parsed)] in $[...]$ #java[.core.tools.picocli.CommandLine]
  - #java[execute(FileVisitor visitor)] in $[...]$ #java[.core.appender.rolling.action.AbstractPathAction]
  - #java[execute(Bindings bindings)] in $[...]$ #java[.core.script.ScriptManager§ScriptRunner]
]
$=>$ Potentielle *SQL Injections*

== *Joern*: SQL-Injection: Taint Analyse
=== Taint Methoden
- *Sources*: Die "#java[get]"-Methoden
- *Sinks*: "#java[executeBatch]" und "#java[executeUpdate]"
- *Sanitizer*: "#java[prepareStatement]" und "#java[replaceAll]"
#pause
=== Flows
- 22 flows ohne Sanitizer
- 14 flows mit Sanitizer
  - 4 flows ohne #java[statement.clearParameters()]
#pause
=== Ergebnisse
- 2 True Positive (TP) \ _(also für weitere Analysen)_
- 2 False Negatives (FP)

== *Joern*: SQL-Injection: Anmerkungen
- Es gibt nur einen Ort, wo SQL Anfragen stattfinden: #java[JdbcDatabaseManager.java]
  - alle flows laufen über den selben Code
#pause
- Verwendung von der Klasse #java[PreparedStatement]
#pause
=== Persönliche Einschätzung
$=>$ *SQL-Injection eher unwahrscheinlich*

== *Joern*: Command-Injection: Taint Analyse
- Es wurde nirgendwo die Klasse #java[ProcessBuilder] verwendet !

== *Joern*: Command-Injection: Taint Analyse
- *Sources*: Die "#java[get]"-Methoden
- *Sinks*: "#java[execute]" und "#java[executeScript]"
- *Sanitizer*:
  + Alles wo Eingaben konvertiert werden
  + Eingaben, die offensichtlich unbedenklich waren
#pause
=== Flows:
- 150 flows ohne Sanitizer
- 38 flows mit Sanitizer
#pause
=== Ergebnisse
- 18 True Positive (TP) \ _(alle sehr ähnlich)_
- 20 False Negatives (FP)


== *Joern*: Command-Injection: Anmerkungen
- TP waren vielmals ähnlich
- Es wurden Dateinamen und Scripte als Hauptquellen identifiziert
- viele sehr lange flows
- 2 flows schienen sehr kurz
#pause
=== Beispiel
#let joernFlow = [
  #set text(12pt)
  #table(
    columns: (3cm, 9cm, 1cm, 4cm, 1fr),
    align: center + horizon,
    [*nodeType*], [*tracked*], [*line*], [*method*], [*file*],
    [Call],
    [#java[parsed.getCommand()]],
    [455],
    [#java[execute]],
    [#java[log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java]],

    [Identifier],
    [#java[Object command] = #java[parsed.getCommand()]],
    [455],
    [#java[execute]],
    [\[...\]/#java[CommandLine.java]],

    [Identifier], [#java[command instanceof Runnable]], [456], [#java[execute]], [\[...\]#java[/CommandLine.java]],

    [Identifier], [#java[command instanceof Callable]], [463], [#java[execute]], [\[...\]#java[/CommandLine.java]],

    [Call],
    [#java[(Callable]\<#java[Object]\>#java[) command.call()]],
    [465],
    [#java[execute]],
    [\[...\]#java[/CommandLine.java]],

    [Return],
    [#java[return] #java[((Callable]\<#java[Object]\>#java[) command).call()]],
    [465],
    [#java[execute]],
    [\[...\]#java[/CommandLine.java]],

    [MethodReturn], [#java[RET]], [454], [#java[execute]], [\[...\]#java[/CommandLine.java]],

    [Call],
    [#java[execute(parsedCommands.get(0))]],
    [500],
    [#java[handleParseResult]],
    [\[...\]#java[/CommandLine.java]],
  )
]
#joernFlow
#pause
$=>$ flows sind deutlich länger

== *Joern*: Command-Injection: #java[CommandLine] Klasse
- die Klasse #java[CommandLine] ist ein *Command-Line-Parser* und kann Commands ausführen
  - sie bekommt ein Objekt, dass einen Command wiederspiegeln soll
    #pause
    #[
      === Beispiel für einen `encrypt` command
      #set text(12pt)
      #codebox[```java
      @Command(header = "Encrypt FILE(s), or standard input, to standard output or to the output file.", version = "v1.2.3")
      public class Encrypt {

          @Parameters(type = File.class, description = "Any number of input files")
          private List<File> files = new ArrayList<File>();

          @Option(names = { "-o", "--out" }, description = "Output file (default: print to console)")
          private File outputFile;

          @Option(names = { "-v", "--verbose"}, description = "Verbosely list files processed")
          private boolean verbose;

          @Option(names = { "-h", "--help", "-?", "-help"}, usageHelp = true, description = "Display this help and exit")
          private boolean help;

          @Option(names = { "-V", "--version"}, versionHelp = true, description = "Display version info and exit")
          private boolean versionHelp;
      }
      ```]
    ]

== *Joern*: Command-Injection: #java[CommandLine] Klasse
- die Klasse #java[CommandLine] ist ein *Command-Line-Parser* und kann Commands ausführen
  - sie bekommt ein Objekt, dass einen Command wiederspiegeln soll
  - sie befüllt es mit den Werten die *untrusted* von der Kommandozeile als #java[String] eingelesen werden
    #pause
    === Beispiel
    #image("assets/arg matching.png", width: 72%)

== *Joern*: Command-Injection: #java[CommandLine] Klasse
- die Klasse #java[CommandLine] ist ein *Command-Line-Parser* und kann Commands ausführen
  - sie bekommt ein Objekt, dass einen Command wiederspiegeln soll
  - sie befüllt es mit den Werten die *untrusted* von der Kommandozeile als #java[String] eingelesen werden

=== Sicherheitsprobleme
- Übergebene Argumente werden *nicht ungeprüft*
  - problematische Eingaben bei #java[File] und #java[Path] möglich

    === Beispiel
    #codebox[```shell
    --file ../../../../etc/passwd
    --output /tmp/evil
    --config C:\Windows\System32\drivers\etc\hosts
    ```]

== *Joern*: Command-Injection: #java[CommandLine] Klasse
- die Klasse #java[CommandLine] ist ein *Command-Line-Parser* und kann Commands ausführen
  - sie bekommt ein Objekt, dass einen Command wiederspiegeln soll
  - sie befüllt es mit den Werten die *untrusted* von der Kommandozeile als #java[String] eingelesen werden

=== Sicherheitsprobleme
- Übergebene Argumente werden *nicht ungeprüft*
  - problematische Eingaben bei #java[File] und #java[Path] möglich
  - die Klasse packt bei Fehlermeldungen die Argumente direkt in die Fehlermeldungen
    \ $=>$ potentielles leaken von sensiblen Daten wie Tokens, Passwörter usw...

#pause
=== Persönliche Einschätzung
$=>$ Diese Klasse würde ich als *sicherheitsrelevante Input-Grenze* oder *potentielles Evil Gadget* markieren


== *Joern*: Meine Erfahrungen
- Ist eher ein Tool um Code besser zu verstehen und zu analysieren
- Ich hätte mir eine Entwicklungsumgebung gewünscht Joern Skripte zu schreiben mit Autovervollständigung usw...
  - sehr umständlich
- Fokus liegt auf der Benutzung der Joern Shell

== *Semgrep*: Setup und Community-Scan
#place(top + right, float: false)[
  #figure(image("assets/Semgrep Logo.png", width: 20%))
]

=== Community-Regelwerke: `p/java` und `p/owasp`
#codebox[```bash
semgrep --config p/java --config p/owasp-top-ten \
  --json --output semgrep_full.json .
```]

#rect(
  inset: 0.6em,
  fill: rgb(255, 245, 200, 150),
  stroke: 1pt + orange,
  radius: 4pt,
)[
  #set text(12pt)
  *Tooling-Befund:* Der in der Aufgabe vorgegebene Pack `p/owasp` liefert *HTTP 404*  er existiert nicht mehr in der Registry. Ersetzt durch `p/owasp-top-ten` (aktuelles OWASP-Äquivalent). Dokumentiert als Setup-Erfahrung.
]

#v(0.4em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    #rect(inset: 0.8em, fill: rgb(240, 240, 240), radius: 4pt)[
      #set text(13pt)
      *Scan-Ergebnisse*
      #set list(spacing: 0.4em)
      - *4539* Dateien gescannt (gesamtes Repo)
      - *~13 Sek* Dauer · *0* Fehler
      - *155* Regeln ausgeführt
      - *5* Findings gesamt
      - #text(fill: red)[*3 ERROR*] · #text(fill: orange)[*2 WARNING*] · *0 INFO*
    ]
  ],
  [
    #set text(12pt)
    #table(
      columns: (3.2fr, 0.8fr),
      fill: (col, row) => if row == 0 { rgb(70, 70, 70) } else if calc.odd(row) { rgb(245, 245, 245) } else { white },
      [#text(fill: white)[*Top Regel-IDs*]], [#text(fill: white)[*\#*]],
      [`...xxe.doctype-decl-missing`], [2],
      [`...run-shell-injection`], [1],
      [`...unencrypted-socket`], [1],
      [`...use-of-md5`], [1],
    )
  ],
)

#v(0.4em)

#rect(
  inset: 0.6em,
  fill: rgb(220, 240, 220, 150),
  stroke: 1pt + green.darken(20%),
  radius: 4pt,
)[
  #set text(12pt)
  *Scope:* Gesamtes Repo  passend zur Joern-Analyse. Ausschluss der Test-/Fuzz-Module via `--exclude` änderte die 5 Findings nicht: alle in Produktions- bzw. Infrastruktur-Code.
]

// ---------------------------------------------------------------- Folie 2
== Was wurde mit *Semgrep* gefunden?

#[
  #set text(11.5pt)
  #table(
    columns: (1.7fr, 0.4fr, 1.5fr, 0.75fr, 0.55fr, 2.6fr),
    fill: (col, row) => if row == 0 { rgb(50, 50, 50) } else if calc.odd(row) { rgb(245, 245, 245) } else { white },

    [#text(fill: white)[*Datei*]],
    [#text(fill: white)[*Z.*]],
    [#text(fill: white)[*Regel*]],
    [#text(fill: white)[*Schwere*]],
    [#text(fill: white)[*Bew.*]],
    [#text(fill: white)[*Begründung*]],

    [`log4j-1.2-api/…XmlConfiguration.java`],
    [167],
    [`...xxe.doctype-decl-missing`],
    [ERROR],
    [#text(fill: green.darken(30%))[*TP*]],
    [Keine XXE-Härtung: `setValidating(true)`, kein `disableDtdProcessing()`. Nur `Log4jEntityResolver`, der externe Entities *nicht* abschaltet  echte XXE-Angriffsfläche im Legacy-1.x-Konfig-Parser],

    [`log4j-core/…XmlConfiguration.java`],
    [188],
    [`...xxe.doctype-decl-missing`],
    [ERROR],
    [#text(fill: red.darken(10%))[*FP*]],
    [Dieselbe Regel, aber gehärtet: `disableDtdProcessing()` deaktiviert externe Entities + DTD. Parst nur die vertrauenswürdige eigene Konfig-Datei  kein externer Input],

    [`deploy-site.yaml`],
    [77],
    [`...run-shell-injection`],
    [ERROR],
    [#text(fill: red.darken(10%))[*FP*]],
    [`${{ github.ref_name }}` fließt per `sed` in `run:`. Job durch `if`-Guard abgesichert (`startsWith('release/')` + Repo-Check), kein `pull_request_target`  Ref nicht angreiferkontrolliert],

    [`TcpSocketManager.java`],
    [464],
    [`...unencrypted-socket`],
    [WARNING],
    [#text(fill: red.darken(10%))[*FP*]],
    [Plain-TCP-Appender ist by-design; separater `SslSocketManager` für Verschlüsselung. Klartext ist wählbare Option, kein Defekt],

    [`NameUtil.java`],
    [59],
    [`...use-of-md5`],
    [WARNING],
    [#text(fill: red.darken(10%))[*FP*]],
    [MD5 nur für eindeutige Konfig-Element-IDs, nicht für Sicherheit; per Javadoc + `@SuppressFBWarnings` bestätigt, `@Deprecated`],
  )
]

#v(0.4em)
#text(11pt)[*Ergebnis:* 5 Findings · *1 True Positive* · *4 False Positives*]

// ---------------------------------------------------------------- Folie 3
== Triage-Highlight: Zwei XXE-Findings, ein Urteil auseinander

#v(0.3em)
Dieselbe Regel `documentbuilderfactory-disallow-doctype-decl-missing` feuert an zwei Stellen  die Bewertung kippt allein am Vorhandensein der Härtung.

#v(0.6em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1.2em,
  [
    #rect(inset: 0.9em, fill: rgb(220, 240, 220, 120), stroke: 1.5pt + green.darken(20%), radius: 5pt)[
      #set text(12.5pt)
      #text(fill: green.darken(30%))[*True Positive*] \
      `log4j-1.2-api/…XmlConfiguration.java:167`
      #v(0.4em)
      #set list(spacing: 0.6em)
      - `setValidating(true)` — DTD-Verarbeitung *aktiv*
      - *kein* `disableDtdProcessing()`
      - `Log4jEntityResolver` schränkt nur die Log4j-DTD ein, schaltet externe Entities *nicht* ab
      - parst Legacy-1.x-Konfig
      #v(0.3em)
      $=>$ echte XXE-Angriffsfläche
    ]
  ],
  [
    #rect(inset: 0.9em, fill: rgb(255, 225, 225, 120), stroke: 1.5pt + red.darken(10%), radius: 5pt)[
      #set text(12.5pt)
      #text(fill: red.darken(20%))[*False Positive*] \
      `log4j-core/…XmlConfiguration.java:188`
      #v(0.4em)
      #set list(spacing: 0.6em)
      - `disableDtdProcessing()` *aktiv*
      - externe general- & parameter-Entities deaktiviert
      - externes DTD-Laden deaktiviert
      - parst nur vertrauenswürdige eigene Konfig
      #v(0.3em)
      $=>$ Regel-Treffer, aber gehärtet
    ]
  ],
)

#v(0.6em)

#rect(inset: 0.6em, fill: rgb(235, 235, 245), radius: 4pt)[
  #set text(12pt)
  *Lehre:* Die Regel matcht ein fehlendes Feature-Flag, „sieht" aber nicht die *äquivalente* Härtung über andere Features. Erst das manuelle Triage trennt echten Fund von Fehlalarm.
]

// ---------------------------------------------------------------- Folie 4
== *Semgrep*: Eigener Ansatz  Log4j-spezifische Regeln

#v(0.2em)
*Motivation:* Die Community-Packs lieferten *0* Treffer für die JNDI-Lookup-Klasse — ausgerechnet die Log4Shell-Schwachstellenklasse. Daher zwei eigene Regeln in `custom_rules.yaml`.

#v(0.5em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    #rect(inset: 0.7em, fill: rgb(240, 240, 240), radius: 4pt)[
      #set text(10.5pt)
      *Regel 1 — `log4j-jndi-lookup-sink`*
      #codebox[```yaml
      patterns:
        - pattern: $CTX.lookup($NAME)
        - metavariable-regex:
            metavariable: $NAME
            regex: '^(?!\s*").+'
      ```]
      Matcht JNDI-Lookups mit *nicht-konstantem* Argument → Log4Shell-Sink. Bewusst breit (Sink-Discovery), manuelles Triage eingeplant.
    ]
  ],
  [
    #rect(inset: 0.7em, fill: rgb(240, 240, 240), radius: 4pt)[
      #set text(10.5pt)
      *Regel 2 — `xml-dbf-validating-enabled`*
      #codebox[```yaml
      patterns:
        - pattern: $F.setValidating(true)
      ```]
      #v(0.3em)
      Feuert auf `setValidating(true)` → aktive DTD-Verarbeitung (XXE). Präziser als die Community-Regel: trifft den TP in `log4j-1.2-api`, ignoriert den gehärteten `log4j-core`.
    ]
  ],
)

#v(0.5em)

#rect(inset: 0.6em, fill: rgb(235, 235, 245), radius: 4pt)[
  #set text(11.5pt)
  *Mechanismus:* Pattern bindet jeden Aufruf an Metavariablen; `metavariable-regex` filtert per negativem Lookahead konstante String-Literale heraus. Keyword-basierte Sink-Discovery → hohe Trefferzahl, anschließend manuelles Triage.
]

// ---------------------------------------------------------------- Folie 5
== *Semgrep*: Eigene Regeln, Ergebnisse und Triage
#place(top + right, float: false)[
  #figure(image("assets/Semgrep Logo.png", width: 18%))
]

#v(0.2em)
`custom_rules.yaml` → *15 Findings* (2 Regeln, 1488 Java-Dateien).

#v(0.4em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    #rect(inset: 0.75em, fill: rgb(220, 240, 220, 120), stroke: 1pt + green.darken(20%), radius: 4pt)[
      #set text(10.5pt)
      *Regel 1 — 10 echte JNDI-Sinks (TP)*
      #set list(spacing: 0.3em)
      - `JndiLookup.java:63` ← Log4Shell-Sink selbst
      - `JndiManager.java:251`
      - `JndiContextSelector.java:152`
      - `JmsManager` (core + jakarta, 6×)
      - `DataSourceConnectionSource.java:79`
    ]
  ],
  [
    #rect(inset: 0.75em, fill: rgb(255, 225, 225, 120), stroke: 1pt + red.darken(10%), radius: 4pt)[
      #set text(10.5pt)
      *Regel 1 — 4 Namens-Kollisionen (FP)*

      Methode heißt `lookup`, ist aber *kein* JNDI:
      #set list(spacing: 0.3em)
      - `JavaLookup.java:70` — Log4j-`${java:}`-Lookup
      - `MainMapResolver.java:80` — Map-Lookup
      - `CommandLine.java:5392` — Enum-Lookup
      - `FixedDateFormat.java:491` — Enum-Lookup
    ]
  ],
)

#v(0.4em)

#rect(inset: 0.7em, fill: rgb(240, 240, 240), radius: 4pt)[
  #set text(11pt)
  *Regel 2  1 Treffer (TP):* `XmlConfiguration.java:165` (`log4j-1.2-api`)  isoliert; der gehärtete `log4j-core`-Parser wird *nicht* getroffen.
]

#v(0.4em)

#rect(inset: 0.6em, fill: rgb(220, 240, 220, 150), stroke: 1pt + green.darken(20%), radius: 4pt)[
  #set text(11.5pt)
  *Kontrast:* Community-Packs *0* JNDI-Treffer vs. eigene Regel *10* echte Sinks  inkl. der Log4Shell-Stelle. Breite Sink-Discovery → manuelles Triage trennt die 4 Namens-Kollisionen sauber ab.
]

// ---------------------------------------------------------------- Folie 6
== *Semgrep*: Grenzen und FP-Muster

=== Gemeinsames Muster der False Positives
#set text(12pt)
Die Regeln matchen *lokale Syntax*  einen Algorithmus, einen API-Aufruf, ein Feature-Flag, einen Methodennamen  ohne den *Verwendungs-Kontext*, der über echte Ausnutzbarkeit entscheidet:

#v(0.3em)
#table(
  columns: (1.3fr, 2fr),
  fill: (col, row) => if row == 0 { rgb(50, 50, 50) } else if calc.odd(row) { rgb(245, 245, 245) } else { white },
  inset: 7pt,
  [#text(fill: white)[*Fehlender Kontext*]], [#text(fill: white)[*Beispiel*]],
  [Zweck der Operation], [MD5 nur zur ID-Erzeugung, keine Krypto],
  [Konfig-Absicht], [Unverschlüsselter Socket ist gewollte Option],
  [Äquivalente Härtung], [Core-XXE anders abgesichert als erwartet],
  [Access-Control-Guard], [`if`-Guard schützt CI-Job, Regel ignoriert ihn],
  [Namens-Kollision], [`lookup()` ist nicht immer JNDI (Map/Enum)],
)

#v(0.5em)

#rect(
  inset: 0.7em,
  fill: rgb(255, 235, 235, 150),
  stroke: 1pt + red.darken(10%),
  radius: 4pt,
)[
  #set text(12pt)
  *Was Semgrep nicht fand:* Generische Packs hätten auch *Log4Shell* (CVE-2021-44228) *nicht* erkannt  ein *Design-Fehler* im JNDI-Lookup, kein lokales Muster. Selbst die eigene JNDI-Regel findet nur den *Sink*, nicht den vollständigen Datenfluss  dafür ist Joern/Taint-Analyse nötig.
]

#focus-slide[
  = Vielen Dank für Ihre Aufmerksamkeit!
  Wir sind offen für Fragen !!
]
