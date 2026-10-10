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
import CmdArgLibMacros
import CmdArgLibHelpScreen
import CmdArgLibManpage COMPLETION_IMPORT_LINE
import Foundation

typealias Greeting = String
typealias Name = String
typealias Count = Int

@main
struct Main {COMPLETION_GENERATOR_LINES

    @MainFunctionMacro(shadowGroups: ["lower upper"])
    private static func FUNCTION_NAME(COMPLETION_PARAMETER_LINE
        i includeIndex: Flag,
        u upper: Flag,
        l lower: Flag,
        c__count repeats: Count?,
        g__greeting greeting: Greeting = "Hello",
        _ name: Name,
        generateManpage: MetaFlag = MetaFlag(manpageElements: manpageElements),
        v__version version: MetaFlag = MetaFlag(string: "version 0.1.0"),
        h__help help: MetaFlag = MetaFlag(helpElements: helpElements))
    {
        let count = repeats == nil || repeats! < 1 ? (Int.random(in: 1...3)) : repeats!
        var text = "\\(greeting) \\(name)"
        text = lower ? text.lowercased() : upper ? text.uppercased() : text
        for index in 1...count {
            var text = (includeIndex ? "\\(index) " : "") + "\\(greeting) \\(name)"
            if upper { text = text.uppercased() }
            print(text)
        }
    }

    private static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Greet a person repeatedly."),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nARGUMENT"),
        .parameter("name", "The name of the person to greet"),
        .text("\\nOPTIONS"),
        .parameter("repeats", "Repeat the greeting $E{repeats} times (the default is a random integer between 1 and 3)"),
        .parameter("greeting", "The greeting to print"),
        .parameter("includeIndex", "Show index of repeated greetings"),
        .parameter("lower", "Print text in lower case"),
        .parameter("upper", "Print text in upper case"),
        .parameter("generateManpage", "Generate a manual page"), COMPLETION_SHOW_ELEMENT_LINE
        .parameter("version", "Show version information"),
        .parameter("help", "Show help information"),
        .text("\\nNOTE\\n", note1),
    ]

    private static let manpageElements: [ShowElement] = [
        .prologue(description: "print a greeting."),
        .synopsis(),
        .paragraph("DESCRIPTION", "Print $T{greeting}, followed by $E{name}, $E{repeats} times."),
        .paragraph("", "The following options are available:"),
        .parameter("greeting", "The greeting to print"),
        .parameter("includeIndex", "Show index of repeated greetings"),
        .parameter("lower", "Print text in lower case"),
        .parameter("repeats", "Repeat the greeting $E{repeats} times (the default is a random integer between 1 and 3)"),
        .parameter("upper", "Print text in upper case"),
        .parameter("generateManpage", "Generate this manual page"), COMPLETION_SHOW_ELEMENT_LINE
        .parameter("version", "Show version information"),
        .parameter("help", "Show help information"),
        .paragraph("", note1),
        .mdoc(exitStatus),
        .mdoc(examples),
        .mdoc(seeAlso),
        .mdoc(authors),
    ]

    private static let note1 = \"\"\"
        The $S{lower} and $S{upper} options shadow each other; only the last one specified
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
