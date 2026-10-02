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
import Foundation

let targetNameKey = "TARGET_NAME"
let productNameKey = "PRODUCT_NAME"
let functionNameKey = "FUNCTION_NAME"

let manpagePackageDependencyKey = "MANPAGE_PACKAGE_DEPENDENCY_LINE"
let manpageTargetDependencyWordKey = "MANPAGE_TARGET_DEPENDENCY_WORD"
let manpagePackageDependencyLineTemplate = """

        .package(url: "https://github.com/ouser4629/CmdArgLibManpage.git", branch: "main"),
"""
let manpageTargetDependencyWordTemplate = "\"CmdArgLibManpage\","


let completionPackageDependencyKey = "COMPLETION_PACKAGE_DEPENDENCY_LINE"
let completionTargetDependencyWordKey = "COMPLETION_TARGET_DEPENDENCY_WORD"
let completionPackageDependencyLineTemplate = """

        .package(url: "https://github.com/ouser4629/CmdArgLibCompletions.git", branch: "main"),
"""
let completionTargetDependencyWordTemplate = "\"CmdArgLibCompletions\","



let completionParameterLineKey = "COMPLETION_PARAMETER_LINE"
let completionImportLineKey = "COMPLETION_IMPORT_LINE"
let completionGeneratorLinesKey = "COMPLETION_GENERATOR_LINES"
let completionShowElementsKey = "COMPLETION_SHOW_ELEMENT_LINE"

let completionParameterLineTemplate = """

        generateCompletionScript : MetaOption<Shell> = MetaOption(generator),
"""

let completionImportLineTemplate = "\nimport CmdArgLibCompletions"

let completionGeneratorLinesTemplate = """

    typealias Shell = CompletionGenerator
    static let generator = CompletionGenerator(name: "PRODUCT_NAME", suggestionElements: helpElements)
"""

let completionGeneratorLinesForTestingTemplate = """

    public typealias Shell = CompletionGenerator
    public static let generator = CompletionGenerator(name: "PRODUCT_NAME", suggestionElements: helpElements)
"""

let completionShowElemenTemplate = """

        .parameter("generateCompletionScript", "Generate a completion script for \\(ShellType.orCases())"),
"""


struct Initializer {
    let packageName: String
    let productName: String
    let functionName: String
    let template: Template
    let populate: Bool
    let packageDirectoryURL: URL

    let completionPackageDependencyLine: String
    let completionTargetDependencyWord: String
    let manpagePackageDependencyLine: String
    let manpageTargetDependencyWord: String


    let completionImportLine: String
    let completionParameterLine: String
    let completionGeneratorLines: String
    let completionShowElementLine: String
    init(template: Template, product maybeName: String?, populate: Bool, completion: Bool, directory: String? = nil) throws
    {
        let url = try Self.ensureDirectory(directory)
        let packageName = url.lastPathComponent
        let executableName = maybeName ?? SymbolFormatter.snake(packageName)
        if template == .manpage {
            self.manpagePackageDependencyLine = manpagePackageDependencyLineTemplate
            self.manpageTargetDependencyWord = manpageTargetDependencyWordTemplate
        }
        else {
            self.manpagePackageDependencyLine = ""
            self.manpageTargetDependencyWord = ""
        }
        if completion {
            self.completionPackageDependencyLine = completionPackageDependencyLineTemplate
            self.completionTargetDependencyWord = completionTargetDependencyWordTemplate
            self.completionImportLine = completionImportLineTemplate
            var generatorLines = ""
            if template == .testing {
                generatorLines = completionGeneratorLinesForTestingTemplate.replacingOccurrences(of: "PRODUCT_NAME", with: executableName)
            }
            else {
                generatorLines = completionGeneratorLinesTemplate.replacingOccurrences(of: "PRODUCT_NAME", with: executableName)
            }
            self.completionGeneratorLines = generatorLines
            self.completionParameterLine = completionParameterLineTemplate.replacingOccurrences(of: "PRODUCT_NAME", with: executableName)
            self.completionShowElementLine = completionShowElemenTemplate
        }
        else {
            self.completionPackageDependencyLine = ""
            self.completionTargetDependencyWord = ""
            self.completionImportLine = ""
            self.completionGeneratorLines = ""
            self.completionParameterLine = ""
            self.completionShowElementLine = ""
        }
        self.packageName = packageName
        self.productName = executableName
        self.functionName = SymbolFormatter.camelCase(productName)
        self.template = template
        self.populate = populate
        self.packageDirectoryURL = url
    }
}

extension Initializer {

    func initialize()  throws
    {
        var packageFileContents = ""
        var fileDefs: [FileDef] = []
        var hasTests = false
        switch template {
        case .opaque:
            packageFileContents = filledPackageTemplate(opaquePackage)
            fileDefs = populate ? fileDefsFor[.opaque]! : minimalFileDefsFor[.opaque]!
        case .basic:
            packageFileContents = filledPackageTemplate(commonPackage)
            fileDefs = populate ? fileDefsFor[.basic]! : minimalFileDefsFor[.basic]!
        case .manpage:
            packageFileContents = filledPackageTemplate(commonPackage)
            fileDefs = populate ? fileDefsFor[.manpage]! : minimalFileDefsFor[.manpage]!
        case .testing:
            hasTests = true
            packageFileContents = filledPackageTemplate(testingPackage)
            fileDefs = populate ? fileDefsFor[.testing]! : minimalFileDefsFor[.testing]!
        case .simpleTree:
            packageFileContents = filledPackageTemplate(commonPackage)
            fileDefs = populate ? fileDefsFor[.simpleTree]! : minimalFileDefsFor[.simpleTree]!
        case .statefulTree:
            packageFileContents = filledPackageTemplate(commonPackage)
            fileDefs = populate ? fileDefsFor[.statefulTree]! : minimalFileDefsFor[.statefulTree]!
        }
        if packageFileContents.isEmpty  || fileDefs.isEmpty {
            throw Exception.errors(["Could not generate Package.swift or Main.swift"])
        }

        let fm = FileManager.default
        let packageFilePath = packageDirectoryURL.appending(path: "Package.swift").path
        guard let packageData = packageFileContents.data(using: .utf8) else {
            throw Exception.errors(["Could not generate Package.swift"])
        }
        if !fm.createFile(atPath: packageFilePath, contents: packageData) {
            throw Exception.errors(["Could not create Package.swift"])
        }
        let sourceURL = packageDirectoryURL.appending(components: "Sources", packageName)
        try fm.createDirectory(at: sourceURL, withIntermediateDirectories: true)

        for (fileName, template) in fileDefs {
            let filledTemplate = fill(template)
            let filePath = sourceURL.appendingPathComponent(fileName).path
            guard let data = filledTemplate.data(using: .utf8) else {
                throw Exception.errors(["Could not generate Main.swift"])
            }
            if !FileManager.default.createFile(atPath: filePath, contents: data) {
                throw Exception.errors(["Could not generate \(fileName)"])
            }
        }

        if hasTests {
            // At this point only the Main target is set. Need to add Support and Tests
            let sourceURL = packageDirectoryURL.appending(components: "Sources", "\(packageName)Support")
            try fm.createDirectory(at: sourceURL, withIntermediateDirectories: true)
            let supportFilePath = sourceURL.appendingPathComponent("\(packageName)Support.swift").path
            let template = populate ? testingSupport : minimalTestingSupport
            let filledTemplate = fill(template)
            guard let supportData = filledTemplate.data(using: .utf8) else {
                throw Exception.errors(["Could not create content for \(packageName)Support.swift"])
            }
            if !fm.createFile(atPath: supportFilePath, contents: supportData) {
                throw Exception.errors(["Could not create \(packageName)Support.swift"])
            }
            let testURL = packageDirectoryURL.appending(components: "Tests", "\(packageName)Tests")
            try fm.createDirectory(at: testURL, withIntermediateDirectories: true)
            let testFilePath = testURL.appendingPathComponent("Tests.swift").path
            let testFileTemplate = populate ? testingTest : minimalTestingTest
            let testFileContent = fill(testFileTemplate)
            guard let testData = testFileContent.data(using: .utf8) else {
                throw Exception.errors(["Could not create content for Test.swift"])
            }
            if !fm.createFile(atPath: testFilePath, contents: testData) {
                throw Exception.errors(["Could not create Tests.swift"])
            }
        }
    }

    func filledPackageTemplate(_ template: String) -> String
    {
        var string = template.replacingOccurrences(of: targetNameKey, with: packageName)
        string = string.replacingOccurrences(of: productNameKey, with: productName)
        string = string.replacingOccurrences(of: completionPackageDependencyKey, with: completionPackageDependencyLine)
        string = string.replacingOccurrences(of: completionTargetDependencyWordKey, with: completionTargetDependencyWord)
        string = string.replacingOccurrences(of: manpagePackageDependencyKey, with: manpagePackageDependencyLine)
        string = string.replacingOccurrences(of: manpageTargetDependencyWordKey, with: manpageTargetDependencyWord)
        return string
    }

    func fill(_ template: String) -> String
    {
        var filledTemplate = template.replacingOccurrences(of: functionNameKey, with: functionName)
        filledTemplate = filledTemplate.replacingOccurrences(of: productNameKey, with: productName)
        filledTemplate = filledTemplate.replacingOccurrences(of: targetNameKey, with: packageName)
        filledTemplate = filledTemplate.replacingOccurrences(of: completionImportLineKey, with: completionImportLine)
        filledTemplate = filledTemplate.replacingOccurrences(of: completionGeneratorLinesKey, with: completionGeneratorLines)
        filledTemplate = filledTemplate.replacingOccurrences(of: completionParameterLineKey, with: completionParameterLine)
        filledTemplate = filledTemplate.replacingOccurrences(of: completionShowElementsKey, with: completionShowElementLine)
        return filledTemplate
    }

    static func ensureDirectory(_ maybePath: String?) throws -> URL
    {
        let fm = FileManager.default
        let directoryPath = maybePath ?? fm.currentDirectoryPath
        let directoryURL = URL(fileURLWithPath: directoryPath)
        var isDirectory: ObjCBool = false
        let isFileOrDirectory = fm.fileExists(atPath: directoryPath, isDirectory: &isDirectory)
        if isFileOrDirectory && !isDirectory.boolValue {
            throw Exception.errors(["There already is a file, not a directory, at \(directoryPath)"])
        }
        if !isFileOrDirectory {
            try fm.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
        }
        let packagePath = directoryURL.appendingPathComponent("Package.swift")
        if fm.fileExists(atPath: packagePath.path) {
            throw Exception.errors(["A manifest file already exists in this directory"])
        }
        let contents = try fm.contentsOfDirectory(atPath: directoryPath)
        if !contents.isEmpty {
            throw Exception.errors(["This directory is not empty. Please specify a clean directory"])
        }
        return directoryURL
    }
}
