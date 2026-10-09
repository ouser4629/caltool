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
import CmdArgLibCompletions
import Foundation

struct Installer {
    let releaseDirURL: URL
    let productDirURL: URL
    let manpageDirURL: URL
    let fishDirURL: URL
    let zshDirURL: URL
    let shellIdentifiers: [ShellType]
    let manpages: [Manpage]

    init(globaleOptions go: GlobalOptions,
        shellIdentifiers: [ShellType],
         manpages: [Manpage])
    {
        self.releaseDirURL = urlOf(go.releaseDir)
        self.productDirURL = urlOf(go.productDir)
        self.manpageDirURL = urlOf(go.manpageDir)
        self.fishDirURL = urlOf(go.fishDir)
        self.zshDirURL = urlOf(go.zshDir)
        self.shellIdentifiers = shellIdentifiers
        self.manpages = manpages
    }

    init(
        releaseDir: ReleaseDirectory, productDir: ProductDirectory,
        manpageDir: ManpageDirectory, fishDir: FishDirectory, zshDir: ZshDirectory,
        shellIdentifiers: [ShellType], manpages: [Manpage])
    {
        self.releaseDirURL = urlOf(releaseDir)
        self.productDirURL = urlOf(productDir)
        self.manpageDirURL = urlOf(manpageDir)
        self.fishDirURL = urlOf(fishDir)
        self.zshDirURL = urlOf(zshDir)
        self.shellIdentifiers = shellIdentifiers
        self.manpages = manpages
    }
}

extension Installer {

    func install(_ names: [String], with manpageNames: [String]) async throws
    {
        var output: [String] = []
        try await validateParameters()
        let fm = FileManager.default
        let productDir = productDirURL.path
        let executableFileNames = try namesOfExecutableFilesIn(releaseDirURL)
        var productsToInstall = names
        if names.isEmpty {
            productsToInstall = executableFileNames
        } else {
            try await validateNames(names, in: executableFileNames)
        }
        productsToInstall.sort(by: <)
        var manpagesToInstall = manpageNames.isEmpty ? productsToInstall : manpageNames
        manpagesToInstall.sort(by: <)
        for releaseName in productsToInstall {
            output.append(releaseName)
            let installedURL = productDirURL.appending(path: releaseName)
            try? fm.removeItem(at: installedURL)
            let releaseURL = releaseDirURL.appending(path: releaseName)
            try fm.copyItem(at: releaseURL, to: installedURL)
            output.append(#"    installed "\#(releaseName)" in "\#(productDir)""#)
            let releasePath = releaseURL.path
            try await installCompletionScript(for: releaseName, calling: releasePath, &output)
            try await installManpages(named: manpagesToInstall.filter{$0.hasPrefix(releaseName)}, &output)
        }
        if !output.isEmpty {
            throw Exception.stdout(output.joined(separator: "\n"))
        }
    }

    /// Only installs manpates for gieven product
    func installManpages(named manpagePaths: [String], _ output: inout [String]) async throws
    {
        for manpagePath in manpagePaths {
            let callNames = manpagePath.components(separatedBy: "/")
            let cliName = callNames[0]
            let arguments =  Array(callNames.dropFirst(1)) + ["--generate-manpage"]
            let releasePath = releaseDirURL.appending(path: cliName).path()
            let fm = FileManager.default
            guard let script = try await generatedScript(calling: releasePath, with: arguments) else {
                continue
            }
            let manpageName = callNames.joined(separator: "-") + ".1"
            let scriptPath = manpageDirURL.appending(path: manpageName).path
            try? fm.removeItem(atPath: scriptPath)
            if !fm.createFile(atPath: scriptPath, contents: Data(script.utf8)) {
                throw Exception.stderr("Failed to create \"\(manpageName)\"")
            }
            if fm.fileExists(atPath: scriptPath) {
                output.append(#"    installed "\#(manpageName)" in "\#(manpageDirURL.path)""#)
            }
        }
    }

    func installCompletionScript(for releaseName: String, calling releasePath: String, _ output: inout [String]) async throws
    {
        for shellIdentifier in shellIdentifiers {
            let args = ["--generate-completion-script", shellIdentifier.rawValue]

            let fm = FileManager.default
            guard let script = try await generatedScript(calling: releasePath, with: args) else {
                return
            }
            var scriptPath = ""
            var installPath = ""
            var scriptName = ""
            switch shellIdentifier {
            case .fish:
                scriptName = "\(releaseName).fish"
                scriptPath = fishDirURL.appending(path: scriptName).path
                installPath = fishDirURL.path
            case .zsh:
                scriptName = "_\(releaseName)"
                scriptPath = zshDirURL.appending(path: scriptName).path
                installPath = zshDirURL.path
            }
            try? fm.removeItem(atPath: scriptPath)
            if !fm.createFile(atPath: scriptPath, contents: Data(script.utf8)) {
                throw Exception.stderr(#"Failed to create "\#(scriptPath)""#)
            }
            if fm.fileExists(atPath: scriptPath) {
                output.append(#"    installed "\#(scriptName)" in "\#(installPath)""#)
            }
        }

    }
}

// Return full paths of executables in the indicated directory
func namesOfExecutableFilesIn(_ url: URL) throws -> [String]
{
    let fm = FileManager.default
    let releaseDir = url.path
    var executables: [Path] = []
    let directoryContents = try fm.contentsOfDirectory(atPath: releaseDir)
    for path in directoryContents {
        let fullPath = url.appending(path: path).path
        if isExecutable(fullPath) && !path.contains("Module") {
            executables.append(path)
        }
    }
    return executables
}

extension Installer {

    func generatedScript(calling releasePath: String, with arguments: [String]) async throws -> String?
    {
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.launchPath = releasePath
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            return nil
        }
        var data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        if !data.isEmpty {
            return nil
        }
        data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        if data.isEmpty {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func isDirectory(_ path: String) -> Bool
    {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    func validateParameters() async throws
    {
        var errors: [String] = []
        var isDirectory: ObjCBool = false
        func check(_ dirURL: URL) {
            let dirPath = dirURL.path
            let exists = FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDirectory)
            if !(exists && isDirectory.boolValue) {
                errors.append("Not a directory: \(dirPath).")
            }
        }
        if shellIdentifiers.contains(.fish) && !fishToolnstalled() {
            errors.append("__cal_fish_completion_tool is not installed.")
        }
        check(releaseDirURL)
        check(productDirURL)
        if shellIdentifiers.contains(.fish) {
            check(fishDirURL)
        }
        if shellIdentifiers.contains(.zsh) {
            check(zshDirURL)
        }
        if !errors.isEmpty {
            throw Exception.errors(errors)
        }
    }

    func validateNames(_ names: [String], in executableFiles: [String]) async throws
    {
        if names.isEmpty { return }
        let fm = FileManager.default
        let releaseDir = releaseDirURL.path
        var errors: [String] = []
        for name in names {
            let namePath = releaseDirURL.appending(path: name).path
            if !fm.fileExists(atPath: namePath) {
                errors.append("Could not find \(name) in \(releaseDir)")
            }
            if !executableFiles.contains(name) {
                errors.append("Could not find \(namePath) is not executable")
                continue
            }
        }
    }
}

func urlOf(_ path: Path) -> URL
{
    // FIXME - us NSString trick for ~/
    let fm = FileManager.default
    let url: URL
    if path.hasPrefix("/") {
        url = URL(fileURLWithPath: path)
    } else if path.hasPrefix("~/") {
        let userHomeDirURL = fm.homeDirectoryForCurrentUser
        let rest = path.dropFirst(2)
        url = userHomeDirURL.appendingPathComponent(String(rest))
    } else if path == "." {
        url = URL(fileURLWithPath: fm.currentDirectoryPath)
    } else {
        let currentWorkingDirURL = URL(fileURLWithPath: fm.currentDirectoryPath)
        url = currentWorkingDirURL.appendingPathComponent(path)
    }
    return url
}

func isExecutable(_ path: String) -> Bool
{
    if path.hasSuffix("Module-tool") {
        return false
    }
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
    if !exists || isDirectory.boolValue { return false }
    return fileManager.isExecutableFile(atPath: path)
}

#if DEBUG
    func fishToolnstalled() -> Bool { return true }
#else
    func fishToolnstalled() -> Bool {
        let process = Process()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["__cal_fish_completion_tool"]
        try! process.run()
        process.waitUntilExit()
        return process.terminationStatus == 0
    }
#endif
