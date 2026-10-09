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
// limitations under the License.

let simpleTreeSon = """
    // Copyright (c) <YEAR> <AUTHOR>

    import CmdArgLibCore
    import CmdArgLibMacros
    import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

    struct Son {COMPLETION_GENERATOR_LINES

        @CommandNodeMacro(shadowGroups: ["lower upper"], synopsis: "Simulate son speaking.")
        static func son(
            l lower: Flag,
            u upper: Flag,
            h__help: MetaFlag = MetaFlag(helpElements: helpElements)
        ) {
            var text = "I want to play chess with my sister."
            if lower { text = text.lowercased() }
            if upper { text = text.uppercased() }
            print(text)
        }

        private static let helpElements: [ShowElement] = [
            .text("DESCRIPTION\\n", "Simulate son speaking."),
            .synopsis("\\nUSAGE\\n"),
            .text("\\nOPTIONS"),
            .parameter("lower", "Lowercase the output"),
            .parameter("upper", "Uppercase the output"),
            .parameter("h__help", "Show help information"),
            .text("\\nNOTE\\n", "The $L{lower} and $L{upper} options shadow each other."),
        ]
    }
    """

let minimalSimpleTreeSon = simpleTreeSon
