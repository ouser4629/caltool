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

let simpleTreeSon = """
    // Copyright (c) <YEAR> <AUTHOR>

    import CmdArgLibCore
    import CmdArgLibProtocols
    import CmdArgLibHelpScreen

    struct Son: CommandNodeDef {
    
        var count: Int?? = nil
        var phrase = "I want to play chess with my sister."
        var h__help: MetaFlag = MetaFlag(helpElements: helpElements)
    
        var configuration: CommandNodeConfig<Void>? = CommandNodeConfig(
            embellishments: [
                // .embellish("maybeCount", label: "c__count", typeName: "Maybe<Int>")
            ],
            commandSynopsis: "Simulate son speaking."
        )

        func run(state: [Void]) throws -> [Void] {
            let repeats = if let count { count! } else { Int.random(in: 1...3) }
            if repeats < 1 || repeats > 3 {
                throw Exception.error("The value for $L{count} must be between 1 and 3.")
            }
            for _ in 1...repeats {
                print(phrase)
            }
            return []
        }

        private static let helpElements: [ShowElement] = [
            .text("DESCRIPTION\\n", "Simulate son speaking."),
            .synopsis("\\nUSAGE\\n"),
            .text("\\nOPTIONS"),
            .parameter("count", "The number of times to repeat (default is a random number)"),
            .parameter("phrase", "The phrase to print"),
            .parameter("h__help", "Show help information"),
        ]
    }
    """

let minimalSimpleTreeSon = simpleTreeSon
