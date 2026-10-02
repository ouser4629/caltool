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
import CmdArgLibCommandNodeDef

struct UninstallDef: CommandNodeDef {

    typealias Limit = Int

    var confirmEach: Flag = false
    var confirmEachLimit: Limit?? = nil
    var generateManpage: MetaFlag = MetaFlag(manpageElements: manpageElements)
    var help: MetaFlag = MetaFlag(helpElements: helpElements)
    var productNames: Variadic<Product> = []

    @MainActor
    func run(state: [GlobalOptions]) async throws -> [GlobalOptions] {
        guard let globalOptions = state.first else { fatalError() }
        let uninstaller = Uninstaller(globalOptions: globalOptions)
        let limit: Limit? = if let confirmEachLimit, let confirmEachLimit { confirmEachLimit } else { nil }
        try await uninstaller.uninstall(productNames, confirmEach: confirmEach, confirmEachLimit: limit)
        return []
    }

    private static let mainName = "uninstall"

    var configuration: CommandNodeConfig<GlobalOptions>? = CommandNodeConfig(
        commandName: mainName,
        shadowGroups: ["confirmEach confirmEachLimit"],
        embellishments: [
            .embellish("confirmEach", label: "i__confirmEach"),
            .embellish("confirmEachLimit", label: "I__confirmOnce", typeName: "Limit??"),
            .embellish("productNames", label: "_", typeName: "Variadic<Product>"),
            .embellish("help", label: "h__help"),
        ],
        commandSynopsis: "Uninstall executable products.",
    )

    static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\n", helpOverview),
        .synopsis("\nUSAGE\n", line: ["$*", "!generateManpage"],),
        .text("\nOPTIONS"),
        .parameter("confirmEach", "Request confirmation before attempting to remove each product"),
        .parameter("confirmEachLimit", "Request confirmation just once if more than $E{confirmEachLimit} products are being removed"),
        .parameter("help", "Show this help message"),
        .parameter( "productNames", "Names of products to uninstall (default: the names of products in the release directory)"),
        .text("\nNOTE\n", shadowNote),
    ]

    static let helpOverview = """
        Uninstall executable products, including associated shell completion scripts and
        manual pages.
        """

    static let confirmEachLimitNote = """
        Request confirmation just once if more than $E{confirmEachLimit} products are being removed (default: 
        """

    static let shadowNote = """
        The $S{confirmEach} and $S{confirmEachLimit} options override each other; the last one specified
        determines how product removal is confirmed.
        """

    static let manpageElements: [ShowElement] = [
        .prologue(description: "uninstall executable products"),
        .synopsis(lines: [
            ["$*", "!generateManpage"],
            ["$generateManpage:Flag="]
        ]),
        .paragraph("DESCRIPTION", manpageOverview1),
        .paragraph("", manpageOverview2),
        .paragraph("", "The following options are available:"),
        .parameter("confirmEach", "Request confirmation before attempting to remove each file"),
        .parameter("confirmEachLimit", "Request confirmation just once if more than $E{confirmEachLimit} products are being removed"),
        .parameter("generateManpage", "Generate the mdoc source for this manual page and write it to standard output"),
        .parameter("help", "Show a help screen"),
        .paragraph("\n", shadowNote),
        .mdoc(MainDef.exitStatus),
        .mdoc(seeAlso),
        .mdoc(MainDef.authors),
    ]

    static let manpageOverview1 = """
        The $N{-} utility uninstalls the indicated executable products.
        If no product names are specified, it uses the names of executalbe products in the release
        directory.
        """

    static let manpageOverview2 = """
        When a product, say "name" is uninstalled, its associated shell completions are uninstalled, as
        well as any manpage whose name matches the glob pattern "name*". 
        """

    static let manpageEnvironmentNote = """
       The $T{productDir} and $T{manpageDir} should be on the shell's PATH and MANPATH, respectively. The $T{zshDir} 
       and $T{fishDir} should be on zsh's fpath and fish's fish_complete_path, respectively. None of these directories
       can require super user write privileges. 
       """

    static let seeAlso = """
        .Sh SEE ALSO
        .Xr caltool 1 ,
        .Xr caltool-init 1 ,
        .Xr caltool-install 1
        """
}
