// Copyright (c) 2025-2026 Peter Summerland LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

let manpageMain = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibProtocols
import CmdArgLibHelpScreen
import CmdArgLibManpage COMPLETION_IMPORT_LINE
import Foundation

typealias Greeting = String
typealias Name = String
typealias Count = Int

@main
struct TARGET_NAME: MainFunctionDef {

    var i__includeIndex: Flag = false 
    var u__upper: Flag = false
    var l__lower: Flag = false
    var c__count: Count?? = nil
    var g__greeting: Greeting = "Hello"
    var _name: Name? = nil
    var generateManpage: MetaFlag = MetaFlag(manpageElements: manpageElements) COMPLETION_PARAMETER_LINE 
    var v__version: MetaFlag = MetaFlag(string: "version 0.1.0")
    var h__help: MetaFlag = MetaFlag(helpElements: helpElements)

    var attributes: MainFunctionAttributes? = MainFunctionAttributes(
        shadowGroups: ["l__lower u__upper"],
        typeNames: [
            "c__count": "Count??", COMPLETION_TYPENAME_LINE
        ],
    )

    func run() throws {
        let count = if let c__count, let c__count, c__count > 0 { c__count } else { Int.random(in: 1...3) }
        var text = "\\(g__greeting) \\(_name!)"
        text = l__lower ? text.lowercased() : u__upper ? text.uppercased() : text
        for index in 1...count {
            var text = (i__includeIndex ? "\\(index) " : "") + "\\(g__greeting) \\(_name!)"
            if u__upper { text = text.uppercased() }
            print(text)
        }
    } COMPLETION_GENERATOR_LINES

    private static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Greet a person repeatedly."),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nARGUMENT"),
        .parameter("_name", "The name of the person to greet"),
        .text("\\nOPTIONS"),
        .parameter("c__count", "Repeat the greeting $E{c__count} times (the default is a random integer between 1 and 3)"),
        .parameter("g__greeting", "The greeting to print"),
        .parameter("i__includeIndex", "Show index of repeated greetings"),
        .parameter("l__lower", "Print text in lowercase"),
        .parameter("u__upper", "Print text in uppercase"),
        .parameter("generateManpage", "Generate a manual page"), COMPLETION_SHOW_ELEMENT_LINE
        .parameter("v__version", "Show version information"),
        .parameter("h__help", "Show help information"),
        .text("\\nNOTE\\n", note1),
    ]

    private static let manpageElements: [ShowElement] = [
        .prologue(description: "print a greeting."),
        .synopsis(),
        .paragraph("DESCRIPTION", "Print $T{g__greeting}, followed by $E{_name}, $E{c__count} times."),
        .paragraph("", "The following options are available:"),
        .parameter("g__greeting", "The greeting to print"),
        .parameter("i__includeIndex", "Show index of repeated greetings"),
        .parameter("l__lower", "Print text in lowercase"),
        .parameter("c__count", "Repeat the greeting $E{c__count} times (the default is a random integer between 1 and 3)"),
        .parameter("u__upper", "Print text in uppercase"),
        .parameter("generateManpage", "Generate this manual page"), COMPLETION_SHOW_ELEMENT_LINE
        .parameter("v__version", "Show version information"),
        .parameter("h__help", "Show help information"),
        .paragraph("", note1),
        .mdoc(exitStatus),
        .mdoc(examples),
        .mdoc(seeAlso),
        .mdoc(authors),
    ]

    private static let note1 = \"\"\"
        The $S{l__lower} and $S{u__upper} options shadow each other; only the last one specified
        is applicable.
        \"\"\"

    private static let exitStatus = \"\"\"
        .Sh EXIT STATUS
        The 
        .Nm
        utility exits 0 on success, and >0 if an error occurs.
        \"\"\"

    private static let examples = \"\"\"
        .Sh EXAMPLES
        .Pp
        Say 'Hi' to John Wesley Harding:
        .Pp
        .Dl > PRODUCT_NAME -c1 -g Hi 'John Wesley Harding'
        .Pp
        Say it twice with an index:
        .Pp
        .Dl > PRODUCT_NAME -ic2 -g Hi 'John Wesley Harding'
        \"\"\"

    private static let seeAlso = \"\"\"
        .Sh SEE ALSO
        .Xr man 1 ,
        .Xr mandoc 1 ,
        .Xr sed 1 ,
        .Xr mdoc 7 ,
        .Xr re_format 7
        \"\"\"

    private static let authors = \"\"\"
        .Sh AUTHORS
        The 
        .Nm
        utility was written by
        .%A Mack the Finger and Louie the King .
        \"\"\"

    private static let mammalDict: [String: String] = [
        "cat": "A domesticated carnivorous mammal.",
        "dog": "A domesticated carnivorous mammal.",
        "cow": "A large, domesticated bovine mammal.",
    ]
}
"""

let minimalManpageMain = manpageMain
