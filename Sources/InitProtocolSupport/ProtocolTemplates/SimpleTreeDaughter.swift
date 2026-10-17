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

let simpleTreeDaughter = """
    // Copyright (c) <YEAR> <AUTHOR>

    import CmdArgLibCore
    import CmdArgLibHelpScreen

    struct Daughter: CommandNodeDef {
    
        var lower: Flag = false
        var upper: Flag = false
        var h__help: MetaFlag = MetaFlag(helpElements: helpElements)
    
        var configuration: CommandNodeConfig<Void>? = CommandNodeConfig(
            shadowGroups: ["lower upper"],
            commandSynopsis: "Simulate daughter speaking."
        )

        func run(state: [Void]) throws -> [Void] {
            var text = "I want to play chess with my brother."
            if lower { text = text.lowercased() }
            if upper { text = text.uppercased() }
            print(text)
            return []
        }

        private static let helpElements: [ShowElement] = [
            .text("DESCRIPTION\\n", "Simulate daughter speaking."),
            .synopsis("\\nUSAGE\\n"),
            .text("\\nOPTIONS"),
            .parameter("lower", "Lowercase the output"),
            .parameter("upper", "Uppercase the output"),
            .parameter("h__help", "Show help information"),
            .text("\\nNOTE\\n", "The $L{lower} and $L{upper} options shadow each other."),
        ]
    }
    """

let minimalSimpleTreeDaughter = simpleTreeDaughter
