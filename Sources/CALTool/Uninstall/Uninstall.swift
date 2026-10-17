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

struct UninstallDef: CommandNodeDef {

    typealias Limit = Int

    var i__confirmEach: Flag = false
    var I__confirmOnce: Limit?? = Optional(nil)
    var generateManpage: MetaFlag = MetaFlag(manpageElements: manpageElements)
    var h__help: MetaFlag = MetaFlag(helpElements: helpElements)
    var productNames: Variadic<Product> = []

    @MainActor
    func run(state: [GlobalOptions]) async throws -> [GlobalOptions] {
        guard let globalOptions = state.first else { fatalError() }
        let uninstaller = Uninstaller(globalOptions: globalOptions)
        // FIXME
        let limit: Int? = if let I__confirmOnce, let I__confirmOnce { I__confirmOnce } else { nil }
        try await uninstaller.uninstall(productNames, confirmEach: i__confirmEach, confirmEachLimit: limit)
        return []
    }

    var commandNodeAttributes: CommandNodeAttributes<GlobalOptions>? = CommandNodeAttributes(
        commandName: "uninstall",
        commandSynopsis: "Uninstall executable products.",
    )

    static let argumentAttributes = ArgumentAttributes(
        showElements: helpElements
    )

    static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\n", helpOverview),
        .synopsis("\nUSAGE\n", line: ["$*", "!generateManpage"],),
        .text("\nOPTIONS"),
        .parameter("i__confirmEach", "Request confirmation before attempting to remove each product"),
        .parameter("I__confirmOnce",
                   "Request confirmation just once if more than $E{I__confirmOnce} products are being removed",
                   typeName: "Limit??"),
        .parameter("h__help", "Show this help message"),
        .parameter(
            "productNames",
            "Names of products to uninstall (default: the names of products in the release directory)",
            typeName: "Variadic<Product>"),
        .text("\nNOTE\n", shadowNote),
    ]

    static let helpOverview = """
        Uninstall executable products, including associated shell completion scripts and
        manual pages.
        """

    static let confirmEachLimitNote = """
        Request confirmation just once if more than $E{I__confirmOnce} products are being removed (default: 
        """

    static let shadowNote = """
        The $S{i__confirmEach} and $S{I__confirmOnce} options shadow each other; the last one specified
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
        .parameter("generateManpage", "Generate the mdoc source for this manual page and write it to standard output"),
        .parameter("h__help", "Show a help screen"),
        .parameter("i__confirmEach", "Request confirmation before attempting to remove each file"),
        .parameter("I__confirmOnce", "Request confirmation just once if more than $E{I__confirmOnce} products are being removed"),
        .paragraph("\n", shadowNote),
        .mdoc(Caltool.exitStatus),
        .mdoc(seeAlso),
        .mdoc(Caltool.authors),
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
