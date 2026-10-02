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

struct Uninstaller {
    let releaseDirURL: URL
    let productDirURL: URL
    let manpageDirURL: URL
    let fishDirURL: URL
    let zshDirURL: URL

    init(globalOptions go: GlobalOptions)
    {
        self.releaseDirURL = urlOf(go.releaseDir)
        self.productDirURL = urlOf(go.productDir)
        self.zshDirURL = urlOf(go.zshDir)
        self.fishDirURL = urlOf(go.fishDir)
        self.manpageDirURL = urlOf(go.manpageDir)
    }

    init(
        releaseDir: ReleaseDirectory?, productDir: ProductDirectory,
        manpageDir: ManpageDirectory, fishDir: FishDirectory, zshDir: ZshDirectory)
    {
        self.releaseDirURL = urlOf(releaseDir!)
        self.productDirURL = urlOf(productDir)
        self.zshDirURL = urlOf(zshDir)
        self.fishDirURL = urlOf(fishDir)
        self.manpageDirURL = urlOf(manpageDir)
    }
}

extension Uninstaller {

    /// Uninstall the indicated files
    /// - Parameters:
    ///   - names: names of files to remove
    ///   - confirmationLimit: If nil, no confirmation required. Else, if more than this limi, confrim  all at once.
    ///
    func uninstall(_ specificNames: [String], confirmEach: Bool, confirmEachLimit: Int?) async throws {
        var output: [String] = []
        var errorMessages: [String] = []
        try await validateParameters()
        var names = specificNames
        if names.isEmpty {
            names = try namesOfExecutableFilesIn(releaseDirURL)
        }
        else {
            validateUninstallNames(names, &errorMessages)
        }
        if let confirmEachLimit, confirmEachLimit < 1 {
            errorMessages.append("The value for $E{confirmEachLimit} must be positive")
        }
        if !errorMessages.isEmpty {
            throw Exception.errors(errorMessages)
        }

        var productNames: [String] = []
        if let confirmEachLimit, names.count > confirmEachLimit {
            let ok = askForConfirmation(question: "Remove \(names.count) products?")
            if ok { productNames = names }
        }
        else if confirmEach {
            for name in names {
                let ok = askForConfirmation(question: "Remove \(name)?")
                if ok { productNames.append(name) }
            }
        }
        else {
            productNames = names
        }

        productNames.sort { $0 < $1 }
        for productName in productNames {
            output.append(productName)
            try await uninstallExecutable(for: productName, &output)
            try await uninstallFishCompletionScript(for: productName, &output)
            try await uninstallZshCompletionScript(for: productName, &output)
            try await uninstallManpages(for: productName, &output)
        }
        if !output.isEmpty {
            throw Exception.stdout(output.joined(separator: "\n"))
        }
    }
}

extension Uninstaller {

    func uninstallExecutable(for productName: String, _ output: inout [String]) async throws {
        let fm = FileManager.default
        let executablePath = productDirURL.appending(path: productName).path
        if fm.fileExists(atPath: executablePath) {
            try? fm.removeItem(atPath: executablePath)
            output.append(#"    uninstalled "\#(productName)" in "\#(productDirURL.path)""#)
        }
    }

    func uninstallFishCompletionScript(for productName: String, _ output: inout [String]) async throws {
        let fm = FileManager.default
        let scriptPath = fishDirURL.appending(path: "\(productName).fish").path
        if fm.fileExists(atPath: scriptPath) {
            try? fm.removeItem(atPath: scriptPath)
            output.append(#"    uninstalled "\#(productName).fish" in "\#(fishDirURL.path)""#)
        }
    }

    func uninstallZshCompletionScript(for productName: String, _ output: inout [String]) async throws {
        let fm = FileManager.default
        let scriptPath = zshDirURL.appending(path: "_\(productName)").path
        if fm.fileExists(atPath: scriptPath) {
            try? fm.removeItem(atPath: scriptPath)
            output.append(#"    uninstalled "_\#(productName)" in "\#(zshDirURL.path)""#)
        }
    }

    // Uninstalls all whose name matches productName*
    func uninstallManpages(for productName: String, _ output: inout [String]) async throws {
        let fm = FileManager.default
        var names = try fm.contentsOfDirectory(atPath: manpageDirURL.path)
            .map { URL(filePath: $0) }
            .compactMap { manpageName(of: $0, for: productName) }
        names.sort(by: >)
        for name in names {
            let path = manpageDirURL.appending(path: name).path
            if fm.fileExists(atPath: path) {
                try? fm.removeItem(atPath: path)
                output.append(#"    uninstalled "\#(name)\" in "\#(manpageDirURL.path)""#)
            }
        }
    }

    func manpageName(of url: URL, for productName: String) -> String? {
        let parts = url.pathComponents
        guard let name = parts.last, name.hasSuffix(".1"), name.hasPrefix(productName) else { return nil }
        return name
    }
}

extension Uninstaller {

    func validateParameters() async throws {
        var errors: [String] = []
        var isDirectory: ObjCBool = false
        func check(_ dirURL: URL) {
            let dirPath = dirURL.path
            let exists = FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDirectory)
            if !(exists && isDirectory.boolValue) {
                errors.append(#""\#(dirPath)" is not a directory"#)
            }
        }
        check(releaseDirURL)
        check(productDirURL)
        if !errors.isEmpty {
            throw Exception.errors(errors)
        }
    }

    func validateUninstallNames(_ names: [String], _ errorMessages: inout [String]) {
        if names.isEmpty { return }
        let fm = FileManager.default
        let productDir = productDirURL.path
        for name in names {
            let namePath = productDirURL.appending(path: name).path
            if !fm.fileExists(atPath: namePath) {
                errorMessages.append(#"Cannot uninstall "\#(name)" because it is not in "\#(productDir)""#)
            }
        }
    }

    /// Asks the user for confirmation in the terminal.
    /// - Parameter question: The prompt to display.
    /// - Returns: True if user enters 'y' or 'yes', false otherwise.
    func askForConfirmation(question: String) -> Bool {
        print("\(question) (y/n): ", terminator: "")
        guard let response = readLine() else {
            return false  // Handle empty input or EOF
        }
        let allowedResponses = ["y", "yes"]
        return allowedResponses.contains(response.lowercased())
    }
}
