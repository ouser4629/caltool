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

let simpleTreeMain = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

@main
struct TARGET_NAME: CommandNodeDef {

    var tree: MetaFlag = MetaFlag(treeFor: "PRODUCT_NAME", synopsis: "Execute a subcommand.")
    var version: MetaFlag = MetaFlag(string: "0.0.1") COMPLETION_PARAMETER_LINE
    var help: MetaFlag = MetaFlag(helpElements: helpElements)

    var configuration: CommandNodeConfig<Void>? = CommandNodeConfig(
       embellishments: [
           .embellish("tree", label: "t__tree"),
           .embellish("version", label: "v__version"), COMPLETION_TYPENAME_LINE
           .embellish("help", label: "h__help"),
       ],
       commandSynopsis: "Simulate children speaking.",
       children: [sonCommandNode, daughterCommandNode]
    )

    func run(state: [Void]) throws -> [Void] { return [] } COMPLETION_GENERATOR_LINES

    private static let sonCommandNode = Son().commandNode
    private static let daughterCommandNode = Daughter().commandNode

    private static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Simulate children speaking."),
        .synopsis("\\nUSAGE\\n", line: ["$*", "$_:Subcommand"]),
        .text("\\nOPTIONS"),
        .parameter("version","Print the program's version"),
        .parameter("tree", "Show a hierarchical list of commands"),
        .parameter("help", "Show this help screen"), COMPLETION_SHOW_ELEMENT_LINE
        .text("\\nSUBCOMMANDS"),
        .commandContext(sonCommandNode.context),
        .commandContext(daughterCommandNode.context),
    ]
}
"""

let minimalSimpleTreeMain = simpleTreeMain
