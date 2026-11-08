// Helper Methoden
def printList[T](liste: List[T]): Unit = {
  liste.foreach(println)
}

def printMethodCalls(
    liste: Iterator[Call],
    printReturnTypes: Boolean = true,
    printClasses: Boolean = true
): Unit = {
  printList(
    liste
      .map(m => {
        def className = m.methodFullName.replaceAll("\\.[^.]*:[^:]*$", "")

        def returnType =
          if (!printReturnTypes) ""
          else m.signature.replaceAll("\\(.*$", "") + " "

        def paramList = "(" + m.signature
          .replaceFirst("^[^\\(]*\\(", "")
          .replaceFirst("\\)[^\\)]*$", "") + ")"

        def method = m.name

        s"${returnType}${method}${paramList}" + (if (printClasses)
                                                   s" in der Klasse: \"${className}\""
                                                 else "")
      })
      .dedup
      .l
  )
}

def getMethodCalls(
    searchName: String,
    forbiddenSubstrings: List[String] = Nil
): Iterator[
  Call
] = {
  cpg.call
    .filter(_.name.toLowerCase().contains(searchName.toLowerCase()))
    .filterNot(m => forbiddenSubstrings.exists(sub => m.name.contains(sub)))
}

def printMethodAmount(
    searchName: String,
    methods: Iterator[Call]
): Unit = {
  println(
    s"Anzahl der Methodenaufrufe mit dem Substring \"${searchName}\": ${methods.l.size}"
  )
}

def getFlows(
    src: Iterator[Call],
    sink: Iterator[Call]
): Iterator[Path] = {
  sink.reachableByFlows(src)
}

def sanitizeFlows(
    flows: Iterator[Path],
    san: Call => Boolean
): Iterator[Path] = {
  flows.passesNot(_.isCall.filter(san))
}

def printTPandFP(
    tp: List[String],
    fp: List[String]
): Unit = {
  println(s"${tp.size} True Positives (TP) needing further analysis: ")
  printList(tp)
  println("- - - - -")
  println(s"${fp.size} False Positives (FP): ")
  printList(fp)
}

// Import Methods
import io.shiftleft.semanticcpg.language.*
import io.joern.dataflowengineoss.language.*
import io.shiftleft.codepropertygraph.generated.nodes.*
import io.shiftleft.codepropertygraph.generated.*
import flatgraph.traversal.language.*
import io.joern.joerncli.console.Joern.context

def executeMethods = getMethodCalls("execute")
def runMethods = getMethodCalls(
  "run",
  List("trunc", "Trunc", "runtime", "Runtime", "isRunning", "rUn")
)
def runtimeMethods = getMethodCalls("runtime")
def invokeMethods = getMethodCalls("invoke")
def evalMethods =
  getMethodCalls("eval", List("eVal", "EvaluationAllowed"))
def performMethods =
  getMethodCalls("perform", List("PerformancePreferences"))
def writeMethods = getMethodCalls(
  "write",
  List(
    "Writer",
    "Policy",
    "Overwrite",
    "writeObject",
    "DirectWrite",
    "_createXmlWriter",
    "newWriter",
    "AlwaysWrite",
    "ReadWrite",
    "getWriteMethod",
    "defaultWriteObject"
  )
)
def writeObjectMethods = getMethodCalls("writeObject")
def readMethods =
  getMethodCalls(
    "read",
    List(
      "thread",
      "reAd",
      "readObject",
      "Thread",
      "getIndexedReadOnly",
      "getReadOnlyContextData",
      "Ready",
      "ReadTimeout",
      "ReadWrite",
      "Reader",
      "DefaultReadOnly",
      "defaultReadObject",
      "canRead",
      "getReadMethod",
      "logOptionReadFailure"
    )
  )
def readObjectMethods =
  getMethodCalls("readObject", List("defaultReadObject"))
def sendMethods = getMethodCalls(
  "send",
  List(
    "sEnd",
    "getSendRc",
    "resetSendRc",
    "isSend",
    "isSync",
    "setSend",
    "setSync",
    "SendBuffer",
    "SendTime"
  )
)
def dispatchMethods = getMethodCalls("dispatch")
def forwardMethods = getMethodCalls("forward")
def emitMethods = getMethodCalls("emit")
def transmitMethods = getMethodCalls("transmit")
def broadcastMethods = getMethodCalls("broadcast")
def processMethods = getMethodCalls(
  "process",
  List(
    "getProcess",
    "getPattern",
    "setPattern",
    "disableDtd",
    "appendProcess",
    "availableProcessors",
    "processingOver"
  )
)
def handleMethods = getMethodCalls("handle", List("Handler"))
def parseMethods = getMethodCalls("parse", List("Parser", "handleParse"))
def transformMethods = getMethodCalls("transform", List("Transformer"))
def convertMethods = getMethodCalls("convert", List("Converter"))
def renderMethods =
  getMethodCalls("render", List("Renderer", "RenderedMessage"))
def appendMethods =
  getMethodCalls(
    "append",
    List("Appender", "getAppend", "isAppend", "appender")
  )
def publishMethods = getMethodCalls("publish")
def formatMethods = getMethodCalls(
  "format",
  List(
    "formatter",
    "Formatter",
    "setFormat",
    "getFormat",
    "getContent",
    "Information",
    "dateFormat",
    "DateFormat",
    "MessageFormat",
    "canFormat",
    "ZoneFormat",
    "FormatPattern",
    "writeMultiformat",
    "throughput",
    "latency",
    "classic",
    "refactored",
    "CustomFormat",
    "atomic",
    "createFormat"
  )
)
def lookupMethods = getMethodCalls(
  "lookup",
  List(
    "RequireLookup",
    "RequiringLookup",
    "WithLookups",
    "NeedsLookup",
    "isLookup",
    "DefaultLookup",
    "StrLookupMap",
    "isJndiLookup",
    "getUserPrincipal"
  )
)
def doMethods = getMethodCalls(
  "do",
  List(
    "down",
    "Down",
    "double",
    "Double",
    "does",
    "Does",
    "dows",
    "doc",
    "Doc",
    "dO",
    "Random",
    "random",
    "done",
    "Done",
    "Vendor",
    "vendor",
    "doFilter",
    "doSetLevel",
    "setDoInput",
    "setDoOutput",
    "domain",
    "Domain",
    "doGet"
  )
)
def allGetMethods = getMethodCalls(
  "get",
  List(
    "Filter",
    "ErrorHandler",
    "Layout",
    "Threshold",
    "Categor",
    "Hierarchy",
    "Level",
    "Logger",
    "Root",
    "Additivity",
    "Appender",
    "Prio",
    "Parent",
    "Follow",
    "Target",
    "target",
    "Size",
    "BufferedIO",
    "Context",
    "Map",
    "Render",
    "Type",
    "Depth",
    "Format",
    "Syslog",
    "Index",
    "Pattern",
    "Adapter",
    "Event",
    "Handler",
    "Encoding",
    "Time",
    "Thread",
    "thread",
    "policy",
    "Policy",
    "Marker",
    "Attr",
    "Manager",
    "Path",
    "Stream",
    "Info",
    "Abbreviator",
    "Class",
    "Element",
    "Factory",
    "Stack",
    "geT",
    "Builder",
    "gEt",
    "Listener",
    "sourceGet",
    "Provider",
    "Permissions",
    "Capacity",
    "Charset",
    "Length",
    "Options",
    "Excludes",
    "Includes",
    "Writer",
    "Reader",
    "Precision",
    "Scale",
    "Socket",
    "MaxFiles",
    "Clock",
    "Translator",
    "Strategy",
    "Disruptor",
    "Method",
    "incrementAndGet",
    "test",
    "getInstance",
    "Connection",
    "Transaction",
    "Millisecond",
    "Language",
    "Substitutor",
    "Children",
    "Serializer",
    "Files",
    "Synchronous",
    "ScriptRunner",
    "Asynchronous",
    "Properties"
  )
)
def getInstanceMethods = getMethodCalls("getInstance")
def reducedGetMethods(cpg: Cpg): Iterator[Call] = {
  cpg.call("get") ++ cpg.call("getName") ++ cpg.call("getValue") ++ cpg.call(
    "getKey"
  ) ++ cpg.call("getCommand") ++ cpg.call("getSubName")
}

// ImportCPGGraph
importCpg("cpg.bin")
println("---------------")
println("Joern Querries:")
println("---------------")

// Queries
println(s"Anzahl der Methodenaufrufe: ${cpg.call.l.size}")
println("---------------")
printMethodAmount("execute", executeMethods)
printMethodAmount("run", runMethods)
printMethodAmount("runtime", runtimeMethods)
printMethodAmount("invoke", invokeMethods)
printMethodAmount("eval", evalMethods)
printMethodAmount("perform", performMethods)
printMethodAmount("write", writeMethods)
printMethodAmount("writeObject", writeObjectMethods)
printMethodAmount("read", readMethods)
printMethodAmount("readObject", readObjectMethods)
printMethodAmount("send", sendMethods)
printMethodAmount("dispatch", dispatchMethods)
printMethodAmount("forward", forwardMethods)
printMethodAmount("emit", emitMethods)
printMethodAmount("transmit", transmitMethods)
printMethodAmount("broadcast", broadcastMethods)
printMethodAmount("process", processMethods)
printMethodAmount("handle", handleMethods)
printMethodAmount("parse", parseMethods)
printMethodAmount("transform", transformMethods)
printMethodAmount("convert", convertMethods)
printMethodAmount("render", renderMethods)
printMethodAmount("append", appendMethods)
printMethodAmount("publish", publishMethods)
printMethodAmount("format", formatMethods)
printMethodAmount("lookup", lookupMethods)
printMethodAmount("do", doMethods)
printMethodAmount("get", allGetMethods)
printMethodAmount("getInstance", getInstanceMethods)
println("---------------")
println("Beispielhaft: Die \"execute\" Methoden: ")
println("- - - - -")
printMethodCalls(executeMethods, false, false)
println("- - - - -")
println("Beispielhaft: Die \"execute\" Methoden mit Klassen: ")
printMethodCalls(executeMethods, false, true)
println("- - - - -")
println("Beispielhaft: Die \"execute\" Methoden noch etwas genauer: ")
println("- - - - -")
printMethodCalls(executeMethods, true, true)

println("---------------")
println("Taint Analyse: SQL-Injection")

def srcSqlInj = allGetMethods

def sanSqlInj(m: Call): Boolean = {
  m.name.contains("prepareStatement") || m.name.contains("replaceAll")
}

def sinkSqlInj = cpg.call("executeBatch") ++ cpg.call("executeUpdate")

def sqlFlows = getFlows(srcSqlInj, sinkSqlInj)
println(s"src -> sink: ${sqlFlows.l.size} flows gefunden")

val clearLines = cpg.call.nameExact("clearParameters").lineNumber.l.toSet
def sqlSanFlows = sanitizeFlows(sqlFlows, sanSqlInj).filterNot {
  _.elements.exists {
    _.lineNumber.exists(line => clearLines.contains(line))
  }
}
println(s"Sanitized: src -> sink: ${sqlSanFlows.l.size} flows gefunden")
sqlSanFlows.p #> "output/sql_san_flows.txt"
println("Flows exported to: output/sql_san_flows.txt")

println("- - - - -")
printTPandFP(
  List(
    "#02 - but very long",
    "#03",
    "#05",
    "#07",
    "#10 - but very long",
    "#12 - but very long",
    "#14 - but very long"
  ),
  List(
    "#01 - not attacker controlled",
    "#04",
    "#06 - doubled",
    "#08",
    "#09 - not controlled ny attacker",
    "#11",
    "#13"
  )
)

println("- - - - -")
println("Concluding Remarks: ")
val sqlRemarks = List(
  "- TP quite long",
  "- TP need further analysis",
  "- one place where sql happens",
  "- almost all flows run over the same code",
  "- effect of statement.clearParameters() unknown: why set once and clear again before execute?"
)
printList(sqlRemarks)

println("---------------")
println("Taint Analyse: Command Injection")
println(
  s"Wieviele ProcessBuilder benutzt: ${cpg.call.code.filter(c => c.contains("ProcessBuilder")).l.size}"
)

def srcCmdInj = allGetMethods

def sanCmdInj(m: Call): Boolean = {
  // Fall 1: Converting
  val convertSanitizer =
    m.methodFullName.contains("parse") || m.methodFullName.contains(
      "valueOf"
    ) || m.methodFullName.contains("convert")

  // Fall 2: Sanitier Methods
  val escapeSanitizer =
    m.methodFullName.contains("escape") || m.methodFullName.contains(
      "sanitize"
    ) || m.methodFullName.contains("isValid") || m.methodFullName.contains(
      "cleanCmd"
    ) || m.methodFullName.contains("isAlphanumeric")

  // Fall 3: Exclude not attacker controlled data
  val notContSanitizer =
    m.code.contains("runners.get()") || m.code.contains(
      "scriptRunners.get(id)"
    ) || m.code.contains("get(logEventIndex)") || m.code.contains(
      "rootLogger.getName()"
    ) || m.code.contains(
      "scriptRunners.get(script.getId())"
    ) || m.code.contains(
      "clearParameters()"
    ) || m.code.contains(
      "this.statement.clearParameters()"
    ) || m.code.contains("statement")

  convertSanitizer || escapeSanitizer || notContSanitizer
}

def sinkCmdInj = cpg.call("execute") ++ cpg.call("executeScript")

def cmdFlows = getFlows(srcCmdInj, sinkCmdInj)
println(s"src -> sink: ${cmdFlows.l.size} flows gefunden")

def cmdSanFlows = sanitizeFlows(cmdFlows, sanCmdInj)
println(s"Sanitized: src -> sink: ${cmdSanFlows.l.size} flows gefunden")
sqlSanFlows.p #> "output/cmd_san_flows.txt"
println("Flows exported to: output/cmd_san_flows.txt")

println("- - - - -")
printTPandFP(
  List(
    "#01",
    "#02",
    "#05",
    "#06",
    "#16",
    "#18 - short",
    "#19",
    "#20 - short",
    "#21",
    "#23 - short but mabey parsed",
    "#24",
    "#25",
    "#26",
    "#28 - very short !",
    "#31 - short but mabey parsed",
    "#32",
    "#35",
    "#36 - short but mabey parsed"
  ),
  List(
    "#03 - doubled",
    "#04 - but very long",
    "#06 - doubled",
    "#07 - very long",
    "#08 - doubled",
    "#09 - very long and has subset",
    "#10 - very long",
    "#11 - very long",
    "#12 - very long",
    "#13 - doubled",
    "#14 - very long",
    "#15 - very long",
    "#17 - very long",
    "#22 - very long",
    "#27 - very long",
    "#29 - very long",
    "#30 - very long",
    "#33 - long",
    "#34 - very long",
    "#37 - very long"
  )
)

println("- - - - -")
println("SUS:")
println("""
┌────────────┬────────────────────────────────────────┬────┬─────────────────┬─────────────────────────────────────────┐
|│nodeType    │tracked                                 │line│method           │file                                     │
|├────────────┼────────────────────────────────────────┼────┼─────────────────┼─────────────────────────────────────────┤
|│Call        │parsed.getCommand()                     │455 │execute          │log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|│Identifier  │Object command = parsed.getCommand()    │455 │execute          │log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|│Identifier  │command instanceof Runnable             │456 │execute          │log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|│Identifier  │command instanceof Callable             │463 │execute          │log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|│Call        │(Callable<Object>) command              │465 │execute          │log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|│Call        │(Callable<Object>) command.call()       │465 │execute          │log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|│Return      │return ((Callable<Object>)              │465 │execute          │log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|│            │command).call();                        │    │                 │                                         │
|│MethodReturn│RET                                     │454 │execute          │log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|│Call        │execute(parsedCommands.get(0))          │500 │handleParseResult│log4j-core/src/main/java/org/apache/logging/log4j/core/tools/picocli/CommandLine.java│
|└────────────┴────────────────────────────────────────┴────┴─────────────────┴─────────────────────────────────────────┘,
""")
println("Very SUS:")
println(
  """┌────────────┬────────────────────────────────────────────┬────┬─────────┬─────────────────────────────────────────────┐
    |│nodeType    │tracked                                     │line│method   │file                                         │
    |├────────────┼────────────────────────────────────────────┼────┼─────────┼─────────────────────────────────────────────┤
    |│Call        │this.script.getScriptText()                 │260 │execute  │log4j-core/src/main/java/org/apache/logging/log4j/core/script/ScriptManager.java│
    |│Call        │this.scriptEngine.eval(script.getScriptText(),│260 │execute  │log4j-core/src/main/java/org/apache/logging/log4j/core/script/ScriptManager.java│
    |│            │bindings)                                   │    │         │                                             │
    |│Call        │this.scriptEngine.eval(script.getScriptText(),│260 │execute  │log4j-core/src/main/java/org/apache/logging/log4j/core/script/ScriptManager.java│
    |│            │bindings)                                   │    │         │                                             │
    |│Return      │return                                      │260 │execute  │log4j-core/src/main/java/org/apache/logging/log4j/core/script/ScriptManager.java│
    |│            │scriptEngine.eval(script.getScriptText(),   │    │         │                                             │
    |│            │bindings);                                  │    │         │                                             │
    |│MethodReturn│RET                                         │250 │execute  │log4j-core/src/main/java/org/apache/logging/log4j/core/script/ScriptManager.java│
    |│Call        │scriptRunner.execute(bindings)              │203 │<lambda>0│log4j-core/src/main/java/org/apache/logging/log4j/core/script/ScriptManager.java│
    |└────────────┴────────────────────────────────────────────┴────┴─────────┴─────────────────────────────────────────────┘"""
)
println("- - - - -")
println("Concluding Remarks: ")
val cmdRemarks = List(
  "- TP flows are similar, have same source but different endings",
  "- file names und script text als Angrifssvektoren",
  "- very long paths",
  "- above very suspicious"
)

printList(cmdRemarks)
println("---------------")
