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

import CmdArgLibCore

enum Template: String, CmdArgEnum {
    case opaque, basic, manpage, testing
    case simpleTree = "simple-tree"
    case statefulTree = "stateful-tree"
}

typealias FileName = String
typealias FileContent = String
typealias FileDef = (FileName, FileContent)

let fileDefsFor: [Template: [FileDef]] = [
    .basic: [("Main.swift", basicMain)],
    .manpage: [("Main.swift", manpageMain)],
    .opaque: [("Main.swift", opaqueMain)],
    .simpleTree: [
        ("Main.swift", simpleTreeMain), ("Son.swift", simpleTreeSon),("Daughter.swift", simpleTreeDaughter),
    ],
    .statefulTree: [
        ("Main.swift", statefulTreeMain), ("Son.swift", statefulTreeSon), ("Daughter.swift", statefulTreeDaughter),
    ],
    .testing: [("Main.swift", testingMain)],
]

let minimalFileDefsFor: [Template: [FileDef]] = [
    .basic: [("Main.swift", minimalBasicMain)],
    .manpage: [("Main.swift", manpageMain)],
    .opaque: [("Main.swift", minimalOpaqueMain)],
    .simpleTree: [
        ("Main.swift", minimalSimpleTreeMain), ("Son.swift", minimalSimpleTreeSon), ("Daughter.swift", minimalSimpleTreeDaughter),
    ],
    .statefulTree: [
        ("Main.swift", minimalStatefulTreeMain), ("Son.swift", minimalstatefulTreeSon), ("Daughter.swift", minimalStatefulTreeDaughter),
    ],
    .testing: [("Main.swift", minimalTestingMain)],
]
