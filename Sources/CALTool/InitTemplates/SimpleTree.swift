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
    import CmdArgLibMacros
    import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

    @main
    struct Main {COMPLETION_GENERATOR_LINES

        @CommandNodeMacro(synopsis: "Simulate children speaking.", children: subcommands)
        static func FUNCTION_NAME( COMPLETION_PARAMETER_LINE
            t__tree tree: MetaFlag = MetaFlag(treeFor: "PRODUCT_NAME", synopsis: "Execute a subcommand."),
            v__version version: MetaFlag = MetaFlag(string: "0.0.1"),
            h__help help: MetaFlag = MetaFlag(helpElements: helpElements)
        ) {}
    
       private static let subcommands = [Son.commandNode, Daughter.commandNode]

        private static let helpElements: [ShowElement] = [
            .text("DESCRIPTION\\n", "Simulate children speaking."),
            .synopsis("\\nUSAGE\\n", line: ["$*", "$_:Subcommand"]),
            .text("\\nOPTIONS"),
            .parameter("version","Print the program's version"),
            .parameter("tree", "Show a hierarchical list of commands"),
            .parameter("help", "Show this help screen"), COMPLETION_SHOW_ELEMENT_LINE
            .text("\\nSUBCOMMANDS"),
            .commandContext(Son.commandNode.context),
            .commandContext(Daughter.commandNode.context),
        ]

        private static func main() async {
            await runAsMain(commandNode)
        }
    }
    """

let minimalSimpleTreeMain = simpleTreeMain
