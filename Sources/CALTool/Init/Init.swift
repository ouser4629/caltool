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
import InitCommon
import InitProtocolSupport
import InitMacroSupport

typealias Directory = String

struct InitDef: CommandNodeDef {

    var h__help: MetaFlag = MetaFlag(helpElements: helpElements)
    var generateManpage: MetaFlag = MetaFlag(manpageElements: manpageElements)
    var m__useMacros: Flag = false
    var c__withCompletion: Flag = false
    var v__verbose: Flag = false
    var d__directory: Directory?? = Optional(nil)
    var p__productName: Product?? = Optional(nil)
    var t__template: Template? = nil

    var commandNodeAttributes: CommandNodeAttributes<GlobalOptions>? = CommandNodeAttributes(
        commandName: "init",
        commandSynopsis: "Initialize a new package.",
    )

    @MainActor
    func run(state: [GlobalOptions]) async throws -> [GlobalOptions] {
        if t__template == .opaque && c__withCompletion {
            throw Exception.error("$J{c__withCompletion} is not supported for opaque templates")
        }
        if v__verbose {
            switch t__template {
            case .basic, .testing:
                break
            default:
                throw Exception.error("$J{v__verbose} is not supported for the \(t__template!) template")
            }
        }
        let product: Product? = if let p__productName { p__productName } else { nil }
        let dir: Directory? = if let d__directory { d__directory } else { nil }
        if m__useMacros {
            let initializer = try InitMacroSupport.Initializer(
                template: t__template!, product: product, populate: v__verbose, completion: c__withCompletion, directory: dir)
            try initializer.initialize()
        }
        else {
            let initializer = try InitProtocolSupport.Initializer(
                template: t__template!, product: product, populate: v__verbose, completion: c__withCompletion, directory: dir)
            try initializer.initialize()
        }
        return []
    }

    static let argumentAttributes = ArgumentAttributes(
        showElements: helpElements
    )

    private static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\n", "Initialize a Swift package containing an executable product."),
        .synopsis("\nUSAGE\n", line: ["$*", "!generateManpage"]),
        .text("\nOPTIONS"),
        .parameter("h__help", "Show this help screen"),
        .parameter("m__useMacros", protocolNote),
        .parameter("c__withCompletion", completionNote),
        .parameter("v__verbose", verboseNote),
        .parameter("d__directory", directoryNote, .path, typeName: "Directory??"),
        .parameter("t__template", "The template to use", .list(Template.cases)),
        .parameter("p__productName",
                   "The name of the product (default: the package name in kebab-case)",
                  typeName: "Product??"),
        .text("\nTEMPLATES"),
        .pseudoParameter("opaque", "A product without a help screen"),
        .pseudoParameter("basic", "A product with a help screen"),
        .pseudoParameter("testing", "A product with unit tests"),
        .pseudoParameter("manpage", "A product with a manual page"),
        .pseudoParameter("simple-tree", "A product with commands and subcommands"),
        .pseudoParameter("stateful-tree", "A product with stateful commands and subcommands"),
        .text("\nNOTES\n", packageNameNote),
    ]

    private static let completionNote = """
        Add zsh and fish completion generation support to the executable product.
        Does not apply to the "opaque" template
        """

    private static let verboseNote = """
        Use a template variant with more example parameters. Applies only to
        "basic" and "testing"
        """

    private static let protocolNote = """
        Use a template variant that uses CAL's macro-based API instead of the
        its protocol-based API.
        """

    private static let productNameNote = """
       The name of the product. If not specified, the name defaults to the kebab-case
       form of the package name.
       """

    private static let directoryNote = """
        The directory containing the new package (default: the current directory). If the 
        $E{d__directory} is specified and does not exist, it will be created
        """

    private static let packageNameNote = """
        The package name defaults to the last component of the specified directory path.
        
        """
}

extension InitDef {

    private static let manpageElements: [ShowElement] = [
        .prologue(description: "initialize a Swift package containing an executable product"),
        .synopsis(lines: [
            ["$*", "!generateManpage"],
            ["$generateManpage:Flag="]
        ]),
        .paragraph("DESCRIPTION", manpageDescriptionNote1),
        .paragraph("","The following options are available:"),
        .parameter("c__withCompletion", completionNote),
        .parameter("d__directory", directoryNote, .path),
        .parameter("generateManpage", "Generate the mdoc source for this manual page and write it to standard output"),
        .parameter("h__help", "Show a help screen"),
        .parameter("m__useMacros", protocolNote),
        .parameter("v__verbose", verboseNote),
        .parameter("p__productName", productNameNote),
        .parameter("t__template", "The template to use"),
        .paragraph("", packageNameNote),
        .paragraph("TEMPLATES",templateNote),
        .pseudoParameter("opaque", "A product without help screen generation"),
        .pseudoParameter("basic", "A product with a basic help screen"),
        .pseudoParameter("testing", "A product with unit testing"),
        .pseudoParameter("manpage", "A product with manual page generation."),
        .pseudoParameter("simple-tree", "A product with commands and subcommands"),
        .pseudoParameter("stateful-tree", "A product with stateful commands and subcommands"),
        .mdoc(Caltool.exitStatus),
        .mdoc(seeAlso),
        .mdoc(Caltool.authors),
    ]

    private static let templateNote = """
        Templates provide starting points for different executable product configurations.
        All generated products can generate help screens 
        except those based on the "opaque" template. Only products based on the "manpage" template 
        can generate manual pages.
        """

    private static let manpageDescriptionNote1 = """
        The $F{-} utility initializes a package containing an executable product based on a given $E{t__template}.
        Some templates also have variants with fewer example parameters.
        """

    private static let seeAlso = """
        .Sh SEE ALSO
        .Xr caltool 1 ,
        .Xr caltool-install 1 ,
        .Xr caltool-uninstall 1
        """
}
