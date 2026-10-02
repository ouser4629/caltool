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
import CmdArgLibHelpScreen
import CmdArgLibCompletions
import CmdArgLibCommandNodeDef

typealias ReleaseDirectory = String
typealias ProductDirectory = String
typealias ManpageDirectory = String
typealias ZshDirectory = String
typealias FishDirectory = String
typealias Manpage = String
typealias Product = String
typealias Path = String

struct InstallDef: CommandNodeDef {

    typealias Shell = ShellType

    var manpages: Variadic<Manpage> = []
    var shells: Variadic<Shell> = []
    var generateManpage: MetaFlag = MetaFlag(manpageElements: manpageElements)
    var productNames: Variadic<Product> = []
    var help: MetaFlag = MetaFlag(helpElements: helpElements)

    @MainActor
    func run(state: [GlobalOptions]) async throws -> [GlobalOptions] {
        guard let globalOptions = state.first else {
            fatalError("Missing global options")
        }
        let installer = Installer(
            globaleOptions: globalOptions,
            shellIdentifiers: shells,
            manpages: manpages)
        try await installer.install(productNames, with: manpages)
        return []
    }

    private static let mainName = "install"

    var configuration: CommandNodeConfig<GlobalOptions>? = CommandNodeConfig(
        commandName: mainName,
        embellishments: [
            .embellish("manpages", label: "m__withManpages", typeName: "Variadic<Manpage>"),
            .embellish("shells", label: "c__withCompletionScripts", typeName: "Variadic<Shell>"),
            .embellish("productNames", label: "_", typeName: "Variadic<Product>"),
            .embellish("help", label: "h__help"),
        ],
        commandSynopsis: "Install executable products.",
    )

    static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\n", helpOverview),
        .synopsis("\nUSAGE\n", line: ["!generateManpage"]),
        .text("\nOPTIONS"),
        .parameter("help", "Show this help screen"),
        .parameter("manpages", manpageSynopsis),
        .parameter("shells", shellsSynopsis, .list(ShellType.cases)),
        .parameter("productNames", "The names of products to install (default: executable products in the release directory)"),
    ]

    static let helpOverview = """
        Install executable products and generate associated shell completion scripts and manual pages.
        """

    static let shellsSynopsis = """
        For each product, generate and install completion scripts for the indicated shells (available shells: \(ShellType.andCases()))
        """

    static let manpageSynopsis = """
        Generate and install manual pages for the indicated products
        """

    static let manpageElements: [ShowElement] = [
        .prologue(description: "install executable products"),
        .synopsis(lines: [
            ["$*", "!generateManpage"],
            ["$generateManpage:Flag="]
        ]),
        .paragraph("DESCRIPTION", productNote),
        .paragraph("","The following options are available:"),
        .parameter("help", "Show a help screen"),
        .parameter("manpages", manpageSynopsis),
        .parameter("shells", shellsSynopsis, .list(ShellType.cases)),
        .parameter("generateManpage", "Generate the mdoc source for this manual page and write it to standard output"),
        .paragraph("\n", completionInstallationNote),
        .paragraph("\n", manpageInstallationNote),
        .mdoc(MainDef.exitStatus),
        .mdoc(seeAlso),
        .mdoc(MainDef.authors),
    ]

    static let productNote: String = """
        By default, $F{-} installs all of the executable products in the release directory. 
        If one or more product names are specified, only those products will be installed.
        
        """

     static let completionInstallationNote = """
        The $F{-} utility obtains the completion script for a given shell by calling the product with 
        .Fl -generate-completion-script Ar shell_name .
        The fish completion script requires that
        .Dq __fish_completion_tool
        be installed in a directory in the shell's path.
        
        """

    static let manpageInstallationNote = """
       By default, one manpage is installed for each product that can generate a manpage. I.e.,
       a product that has a $L{generateManpage} option. Alternatively, only the manpages
       specified after $S{manpages} or $L{manpages} will be installed. Each name must be a 
       product name or, for subcommands, subcommand path, separated by "/". For example,
       "$S{manpages} caltool/install" generates a manual page for this subcommand named "caltool-install".
       
       """

    static let seeAlso = """
        .Sh SEE ALSO
        .Xr caltool 1 ,
        .Xr caltool-init 1 ,
        .Xr caltool-uninstall 1 
        """
}
