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
import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

@main
struct TARGET_NAME: MainFunctionDef {
    enum Animal: String, CmdArgEnum { case bear, fox, wolf }

    var version: MetaFlag = MetaFlag(string: "version 0.1.0") COMPLETION_PARAMETER_LINE
    var h__help: MetaFlag = MetaFlag(helpElements: helpElements)
    var i__index: Flag = false
    var l: Flag = false
    var u: Flag = false
    var count: Int?? = Optional(.none)
    var _animals: Variadic<Animal>? = nil

    func run() throws
    {
        let repeats = if let count { count! } else { Int.random(in: 1...3) }
        if repeats < 1 || repeats > 3 {
            throw Exception.error("$T{count} must be between 1 and 3.")
        }
        let animalsString = _animals!.map { $0.rawValue }.joinedWith("and")
        var lines: [String] = []
        for i in 1...repeats {
            let indexString = i__index ? "\\(i): " : ""
            lines.append(indexString + animalsString)
        }
        var line = lines.joined(separator: "\\n")
        line = l ? line.lowercased() : u ? line.uppercased() : line
        throw Exception.stdout(line)
    } COMPLETION_GENERATOR_LINES

    static let attributes = ArgumentAttributes(
        shadowGroups: ["l u"],
        showElements: helpElements
    )

    static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Print out the names of specified animals."),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nOPERANDS"),
        .parameter("_animals", "The names of the animals to print", .list(Animal.cases), typeName: "Variadic<Animal>?"),
        .text("\\nOPTIONS"),
        .parameter("h__help", "Show this help message"),
        .parameter("i__index", "Add line numbers to output"),
        .parameter("l", "Lowercase the message"),
        .parameter("u", "Uppercase the message"),
        .parameter("count", "Repeat the greeting $E{count} times (the default is a random integer between 1 and 3)"),
        .parameter("version", "Show version information"), COMPLETION_SHOW_ELEMENT_LINE
        .text("\\nNOTES\\n", notes),
    ]

    static let notes = \"\"\"
        Each $E{_animals} can be \\(Animal.orCases())."

        The $S{l} and $S{u} options shadow each other; the last one encountered
        determines the format.
        \"\"\"
}

"""

let minimalBasicMain = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

@main
struct TARGET_NAME: MainFunctionDef {

    var version: MetaFlag = MetaFlag(string: "version 0.1.0")
    var h__help: MetaFlag = MetaFlag(helpElements: helpElements) COMPLETION_PARAMETER_LINE

    static let attributes = ArgumentAttributes(
        showElements: helpElements
    )

    func run() throws
    {
        throw Exception.stdout("A gnu is an animal.")
    } COMPLETION_GENERATOR_LINES

    static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Explain GNU."),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nOPTIONS"),
        .parameter("h__help", "Show this help message"),
        .parameter("version", "Show version information"), COMPLETION_SHOW_ELEMENT_LINE
        .text("\\nNOTES\\n", "A gnu is an animal."),
    ]
}
"""
