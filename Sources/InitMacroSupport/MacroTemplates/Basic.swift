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

let basicMain = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibMacros
import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

@main
struct Main {COMPLETION_GENERATOR_LINES
    typealias Count = Int
    enum Animal: String, CmdArgEnum { case bear, fox, wolf }

    @MainFunctionMacro
    static func FUNCTION_NAME(COMPLETION_PARAMETER_LINE
        i__index index: Flag = false,
        l: Flag = false,
        u: Flag = false,
        count: Count? = nil,
        _ animals: [Animal], 
        v__version version: MetaFlag = MetaFlag(string: "version 0.1.0"),
        h__help help: MetaFlag = MetaFlag(helpElements: helpElements),
    ) throws {
        let repeats = count ?? Int.random(in: 1...3) 
        if repeats < 1 || repeats > 3 {
            throw Exception.error("$T{count} must be between 1 and 3.")
        }
        let animalsString = animals.map { $0.rawValue }.joinedWith("and")
        var lines: [String] = []
        for i in 1...repeats {
            let indexString = index ? "\\(i): " : ""
            lines.append(indexString + animalsString)
        }
        var text = lines.joined(separator: "\\n")
        text = l ? text.lowercased() : u ? text.uppercased() : text
        throw Exception.stdout(text)
    }

    static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Print lines containing the names of animals."),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nARGUMENT"),
        .parameter("animals", "The name of an animal (can be repeated)", .list(Animal.cases)),
        .text("\\nOPTIONS"),
        .parameter("count", "Repeat the greeting $E{count} times (the default is a random integer between 1 and 3)"),
        .parameter("index", "Prefix each line with an index"),
        .parameter("help", "Show this help message"),
        .parameter("version", "Show version information"), COMPLETION_SHOW_ELEMENT_LINE
        .text("\\nNOTES\\n", notes),
    ]

    static let notes = \"\"\"
        Each $E{animals} can be \\(Animal.orCases())."

        The $S{l} and $S{u} options shadow each other; the last one encountered
        determines the format.
        \"\"\"
}
"""

let minimalBasicMain = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibMacros
import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

@main
struct Main {COMPLETION_GENERATOR_LINES
    @MainFunctionMacro
    static func FUNCTION_NAME(COMPLETION_PARAMETER_LINE
        v__version version: MetaFlag = MetaFlag(string: "version 0.1.0"),
        h__help help: MetaFlag = MetaFlag(helpElements: helpElements),
    ) throws {
        throw Exception.stdout("A gnu is an animal.")
    }

    static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Explain GNU."),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nOPTIONS"),
        .parameter("help", "Show this help message"),
        .parameter("version", "Show version information"), COMPLETION_SHOW_ELEMENT_LINE
        .text("\\nNOTES\\n", "A gnu is an animal."),
    ]
}
"""
