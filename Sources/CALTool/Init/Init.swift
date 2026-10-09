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
import CmdArgLibProtocols
import CmdArgLibHelpScreen
import CmdArgLibManpage
import InitCommon
import InitProtocolSupport
import InitMacroSupport

typealias Directory = String

struct InitDef: CommandNodeDef {

    var help: MetaFlag = MetaFlag(helpElements: helpElements)
    var generateManpage: MetaFlag = MetaFlag(manpageElements: manpageElements)
    var useMacros: Flag = false
    var completion: Flag = false
    var more: Flag = false
    var directory: Maybe<Directory> = nil
    var productName: Maybe<Product> = nil
    var template: Template? = nil

    var configuration: CommandNodeConfig<GlobalOptions>? = CommandNodeConfig(
        commandName: mainName,
        embellishments: [
            .embellish("help", label: "h__help"),
            .embellish("completion", label: "c__withCompletion"),
            .embellish("useMacros", label: "m__useMacros"),
            .embellish("more", label: "v__verbose"),
            .embellish("directory", label: "d__directory", typeName: "Maybe<Directory>"),
            .embellish("productName", label: "p__product", typeName: "Maybe<Product>"),
            .embellish("template", label: "t__template", typeName: "Template?"),
        ],
        commandSynopsis: "Initialize a new package.",
    )

    @MainActor
    func run(state: [GlobalOptions]) async throws -> [GlobalOptions] {
        if template == .opaque && completion {
            throw Exception.error("$J{completion} is not supported for opaque templates")
        }
        if more {
            switch template {
            case .basic, .testing:
                break
            default:
                throw Exception.error("$J{more} is not supported for the \(template!) template")
            }
        }
        let product: Product? = if let productName { productName } else { nil }
        let dir: Directory? = if let directory { directory } else { nil }
        if useMacros {
            let initializer = try InitMacroSupport.Initializer(
                template: template!, product: product, populate: more, completion: completion, directory: dir)
            try initializer.initialize()
        }
        else {
            let initializer = try InitProtocolSupport.Initializer(
                template: template!, product: product, populate: more, completion: completion, directory: dir)
            try initializer.initialize()
        }
        return []
    }

    private static let mainName = "init"

    private static let helpElements: [ShowElement] = [
        .text("DESCRIPTION\n", "Initialize a Swift package containing an executable product."),
        .synopsis("\nUSAGE\n", line: ["$*", "!generateManpage"]),
        .text("\nOPTIONS"),
        .parameter("help", "Show this help screen"),
        .parameter("useMacros", protocolNote),
        .parameter("completion", completionNote),
        .parameter("more", moreNote),
        .parameter("directory", directoryNote, .path),
        .parameter("template", "The template to use", .list(Template.cases)),
        .parameter("productName", "The name of the product (default: the package name in kebab-case)"),
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

    private static let moreNote = """
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
        $E{directory} is specified and does not exist, it will be created
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
        .parameter("completion", completionNote),
        .parameter("directory", directoryNote, .path),
        .parameter("generateManpage", "Generate the mdoc source for this manual page and write it to standard output"),
        .parameter("help", "Show a help screen"),
        .parameter("useMacros", protocolNote),
        .parameter("more", moreNote),
        .parameter("productName", productNameNote),
        .parameter("template", "The template to use"),
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
        The $F{-} utility initializes a package containing an executable product based on a given $E{template}.
        Some templates also have variants with fewer example parameters.
        """

    private static let seeAlso = """
        .Sh SEE ALSO
        .Xr caltool 1 ,
        .Xr caltool-install 1 ,
        .Xr caltool-uninstall 1
        """
}
