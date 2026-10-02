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

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "caltool",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "caltool", targets: ["CALTool"]),
        .executable(name: "__cal_fish_completion_tool", targets: ["FishCompletionTool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ouser4629/CmdArgLibCore.git", branch: "main"),
        .package(url: "https://github.com/ouser4629/CmdArgLibHelpScreen.git", branch: "main"),
        .package(url: "https://github.com/ouser4629/CmdArgLibManpage.git", branch: "main"),
        .package(url: "https://github.com/ouser4629/NewCmdArgLibCommandNodeDef.git", branch: "main"),
//        .package(path: "/Users/po/ZLocal/ZDev/Swift/PS2Lib/User4629/CmdArgLibCommandNodeDef"),
        .package(url: "https://github.com/ouser4629/CmdArgLibCompletions.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "CALTool",
            dependencies: ["CmdArgLibCore" , "CmdArgLibCommandNodeDef",
                           "CmdArgLibHelpScreen", "CmdArgLibManpage", "CmdArgLibCompletions"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .executableTarget(
            name: "FishCompletionTool",
            dependencies: ["CmdArgLibCore", ],
//            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
    ]
)
