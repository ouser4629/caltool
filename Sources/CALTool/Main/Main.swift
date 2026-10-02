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
import CmdArgLibManpage
import CmdArgLibCompletions
import CmdArgLibCommandNodeDef

@main
struct MainDef: CommandNodeDef {

    private static let mainName = "caltool"

    var configuration: CommandNodeConfig<GlobalOptions>? = CommandNodeConfig(
        commandName: mainName,
        embellishments: [
            .embellish("help", label: "h__help"),
            .embellish("generateCompletionScript", typeName: "MetaOption<Shell>"),
            .embellish("tree", label: "t__tree"),
            .embellish("version", label: "v__version"),
        ],
        commandSynopsis: "Swift package development",
        children: subcommands
    )

    var releaseDir: ReleaseDirectory = ".build/release"
    var productDir: ProductDirectory = "~/.local/bin"
    var manpageDir: ManpageDirectory = "~/.local/share/man/man1"
    var fishDir: FishDirectory = "~/.config/fish/completions"
    var zshDir: ZshDirectory = "~/.config/zsh/completions"
    var generateCompletionScript: MetaOption<Shell> = completionScript
    var generateManpage: MetaFlag = MetaFlag(manpageElements: manpageElements)
    var tree: MetaFlag = MetaFlag(treeFor: "caltool", synopsis: "")
    var version: MetaFlag = MetaFlag(string: "caltool 0.5.0")
    var help: MetaFlag = MetaFlag(helpElements: helpElements)

    @MainActor
    func run(state: [GlobalOptions]) async -> [GlobalOptions] {
        let globalOptions = GlobalOptions(
            releaseDir: releaseDir,
            productDir: productDir,
            manpageDir: manpageDir,
            fishDir: fishDir,
            zshDir: zshDir
        )
        return [globalOptions]
    }

    typealias Shell = CompletionGenerator

    private static let initNode = InitDef().commandNode
    private static let installNode = InstallDef().commandNode
    private static let uninstallNode = UninstallDef().commandNode
    private static let initNodeContext = initNode.context
    private static let installNodeContext = installNode.context
    private static let uninstallNodeContext = uninstallNode.context

    private static let subcommands = [initNode, installNode, uninstallNode]
    private static let generator = Shell(name: "caltool", suggestionElements: helpElements)
    private static let completionScript = MetaOption(generator)

    private static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\n", "Create and manage Swift executable products."),
        .synopsis("\nUSAGE\n", line: ["help",  "tree", "version", "$_:Variadic<ConfigurationOption>=", "$_:Subcommand"]),
        .text("\nOPTIONS"),
        .parameter("help", "Show this help screen"),
        .parameter("tree", "Show the command hierarchy"),
        .parameter("version", "Show the version"),
        .pseudoParameter("<configuration-option>...", "Global configuration options passed to subcommands (described in the manual page)"),
        .text("\nSUBCOMMANDS"),
        .commandContext(initNodeContext),
        .commandContext(installNodeContext),
        .commandContext(uninstallNodeContext),
    ]

    static let manpageElements: [ShowElement] = [
        .prologue(description: "create and manage Swift executable products"),
        .synopsis(lines: [
            ["help",  "tree", "version","$_:Subcommand"],
            ["$generateCompletionScript:Variadic<Shell>="],
            ["$generateManpage:Flag="],
        ]),
        .paragraph("DESCRIPTION\n", manpageDescription),
        .paragraph("", cmdArgLibNote),
        .paragraph("", "The following options are available:"),
        .parameter("help", "Show this help screen"),
        .parameter("tree", "Show the command hierarchy"),
        .parameter("version", "Show the version"),
        .paragraph("META-OPTIONS", "The following meta-options are used when configuring the $F{} installation."),
        .parameter("generateCompletionScript","Print a completion script for $F{} for the indicated shell (\(ShellType.orCases()))"),
        .parameter("generateManpage", "Generate the mdoc source for this manual page and write it to stadard output"),
        .paragraph("CONFIGURATION OPTIONS", globalOptionNote),
        .paragraph("", availableGlobalOptions),
        .parameter("fishDir", "The directory for fish completion files", .path),
        .parameter("manpageDir", "The directory in which to install manpages", .path),
        .parameter("productDir", "The directory in which to install the products", .path),
        .parameter("releaseDir", "The directory containing the package's products", .path),
        .parameter("zshDir", "The directory for zsh completion files", .path),
        .paragraph("SUBCOMMANDS", "The available subcommands are:"),
        .commandContext(initNodeContext),
        .commandContext(installNodeContext),
        .commandContext(uninstallNodeContext),
        .mdoc(examples),
        .paragraph("ENVIRONMENT", manpageEnvironmentNote1),
        .paragraph("", manpageEnvironmentNote2),
        .paragraph("", manpageEnvironmentNote3),
        .mdoc(exitStatus),
        .mdoc(seeAlso),
        .mdoc(authors),
    ]

    static let manpageDescription = """
        The $F{} utility initializes packages for building executable products. Generated
        products can include support for generating shell completion scripts and
        manual pages. The utility can also install and uninstall products locally.

        """

    static let cmdArgLibNote = """
        Generated packages depend on modules from Command Argument Library. 
        .Lk https://github.com/ouser4629/cmd-arg-lib.git Command Argument Library .
        
        """

    static let manpageEnvironmentNote1 = """
       The $T{productDir} and $T{manpageDir} should appear in the shell's PATH and MANPATH, respectively. 
       """

    static let manpageEnvironmentNote2 = """
       The $T{zshDir} and $T{fishDir} should be on zsh's FPATH and fish's 
       fish_complete_path, respectively.
       """

    static let manpageEnvironmentNote3 = """
       These directories should be writable without superuser privileges. 
       """

    static let exitStatus = """
        .Sh EXIT STATUS
        The
        .Nm
        utility returns zero on success and non-zero on failure.
        """


    private static let examples = """
        .Sh EXAMPLES
        Initialize, build, install and run a sample product with unit testing
        and completion scripts.
        .Pp
        .Dl > mkdir Demo && cd Demo
        .Dl Demo> \(mainName) init --with-completion --template testing
        .Dl Demo> swift test
        .Dl Demo> swift build -c release 
        .Dl Demo> \(mainName) install --with-shells fish zsh
        .D1 > cd
        .D1 > demo -h
        .D1 > demo -uc2 wolf
        .Pp
        Initialize, build, install and run a sample product with a custom 
        name and a manual page generator, in a new directory
        .Pp
        .Dl > mkdir Demo && cd Demo
        .Dl Demo> \(mainName) init --template manpage -d ManpageExample --name man-ex
        .Dl Demo> cd ManpageExample
        .Dl ManpageExample> swift build -c release 
        .Dl ManpageExample> \(mainName) install
        .Dl ManpageExample> man-ex -h
        .Dl ManpageExample> man man-ex
        .Dl ManpageExample> man-ex -ic2 -g "Good to see you, " Sammy
        """

    static let globalOptionNote = """
        Global options are specified on the top-level command and inherited by its subcommands.
        
        """

    static let availableGlobalOptions = """
        The following global options are available:
        
        """

    static let seeAlso = """
        .Sh SEE ALSO
        .Xr \(mainName)-init 1 ,
        .Xr \(mainName)-install 1 ,
        .Xr \(mainName)-uninstall 1
        """

    static let authors = """
        .Sh AUTHOR
        The 
        .Nm
        utility was written by
        .%A Peter Buenafuente Summerland .
        """
}
