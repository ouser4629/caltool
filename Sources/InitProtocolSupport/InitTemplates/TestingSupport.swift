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

let testingSupport = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibProtocols
import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

public typealias Count = Int

public enum Animal: String, CmdArgEnum { case bear, fox, wolf}

public struct TARGET_NAMESupport: CommandNodeDef {

    public init() {}

    var version: MetaFlag = MetaFlag(string: "version 0.1.0") COMPLETION_PARAMETER_LINE
    var upper: Flag = false
    var lower: Flag = false
    var index: Flag = false
    var count: Count = 1
    var animals: Variadic<Animal>? = nil
    var help: MetaFlag = MetaFlag(helpElements: helpElements)

    public var configuration: CommandNodeConfig<Void>? = CommandNodeConfig(
        commandName: "PRODUCT_NAME",
        shadowGroups: ["lower upper"],
        embellishments: [
            .embellish("upper", label: "u"),
            .embellish("lower", label: "l"),
            .embellish("index", label: "i__index"),
            .embellish("count", label: "c__count", typeName: "Count"),
            .embellish("animals", label: "_", typeName: "Variadic<Animal>?"), COMPLETION_EMBELLISHMET_LINE
            .embellish("version", label: "v__version"), COMPLETION_EMBELLISHMET_LINE
            .embellish("help", label: "h__help"),
        ],
    )

    public func run(state: [()]) async throws -> [Void] {
        let output = try Self.showAnimals(animals!, count: count, index: index, upper: upper, lower: lower)
        throw Exception.stdout(output)
    } COMPLETION_GENERATOR_LINES

    public static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Print lines containing the names of animals."),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nARGUMENT"),
        .parameter("animals", "The name of an animal (can be repeated)", .list(Animal.cases)),
        .text("\\nOPTIONS"),
        .parameter("count", "The number of times to repeat the line"),
        .parameter("index", "Prefix each line with an index"),
        .parameter("upper", "Print text in upper case"),
        .parameter("lower", "Print text in lower case"),
        .parameter("help", "Show this help message"), COMPLETION_SHOW_ELEMENT_LINE
        .parameter("version", "Show version information"),
        .text("\\nNOTES:\\n", note1),
        .text("\\n", note2),
    ]

    private static let note1 = \"\"\"
        The available animals are \\(Animal.casesJoinedWith("and")).
        \"\"\"

    private static let note2 = \"\"\"
        The $S{upper} and $S{lower} options shadow each other. The last one encountered, if
        any, determines the case of the printed text.
        \"\"\"
}

extension TARGET_NAMESupport {

    public static func showAnimals(
        _ animals: [Animal], count: Count, index: Bool, upper: Bool = false, lower: Bool = false) throws -> String
    {
        if count < 1 || count > 3 {
            throw Exception.errors(["$T{count} must be between 1 and 3."])
        }
        let animalsString = string(of: animals)
        var lines: [String] = []
        for i in 1...count {
            let indexString = index ? "\\(i): " : ""
            lines.append(indexString + animalsString)
        }
        var text = lines.joined(separator: "\\n")
        if upper { text = text.uppercased() }
        if lower { text = text.lowercased() }
        return text
    }

    static func string(of animals: [Animal]) -> String {
        animals.map{$0.rawValue}.joinedWith("and")
    }
}
"""

let minimalTestingSupport = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibProtocols
import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE


public struct TARGET_NAMESupport: CommandNodeDef {

    public init() {}

    var version: MetaFlag = MetaFlag(string: "version 0.1.0") COMPLETION_PARAMETER_LINE
    var help: MetaFlag = MetaFlag(helpElements: helpElements)

    public var configuration: CommandNodeConfig<Void>? = CommandNodeConfig(
        commandName: "PRODUCT_NAME",
        embellishments: [
            .embellish("version", label: "v__version"), COMPLETION_EMBELLISHMET_LINE
            .embellish("help", label: "h__help"),
        ],
    )

    public func run(state: [()]) async throws -> [Void] {
        let output = Self.showAnimals()
        throw Exception.stdout(output)
    } COMPLETION_GENERATOR_LINES

    public static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Describe GNU"),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nOPTIONS"),
        .parameter("help", "Show this help message"), COMPLETION_SHOW_ELEMENT_LINE
        .parameter("version", "Show version information"),
        .text("\\nNOTES\\n", "A gnu is an animal."),
    ]

    public static func showAnimals() -> String {
        return "gnu"
    }
}
"""
