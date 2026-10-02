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

let statefulTreeDaughter = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibMacros
import CmdArgLibHelpScreen COMPLETION_IMPORT_LINE

struct Daughter {COMPLETION_GENERATOR_LINES

    @CommandNodeMacro<Format>(synopsis: "Simulate daughter speaking.")
    static func daughter(
       h__help: MetaFlag = MetaFlag(helpElements: helpElements),
       state: [Format]) -> [Format]
    {
        var text = "I want to play chess with my brother."
        if let format = state.first {
            if format.lower { text = text.lowercased() }
            if format.upper { text = text.uppercased() }
        }
        print(text)
        return []
    }

    private static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\\n", "Simulate daughter speaking."),
        .synopsis("\\nUSAGE\\n"),
        .text("\\nOPTIONS"),
        .parameter("h__help", "Show help information"),
    ]
}
"""

let minimalStatefulTreeDaughter = statefulTreeDaughter
