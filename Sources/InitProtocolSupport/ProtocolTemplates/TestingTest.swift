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

let testingTest = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibTestSupport
import Testing
@testable import TARGET_NAMESupport


// These require CmdArgLibCore and CmdArgLibTestSupport
struct TARGET_NAMEOutputTests {

    @Test func simpleInput() async {
        let input = "-iuc2 wolf"
        let output = \"\"\"
        1: WOLF
        2: WOLF
        \"\"\"
        let ok = await testOutput(of: TARGET_NAME.run, with: input, expecting: output)
        #expect(ok)
    }

    @Test func ErrorsTest() async {
        let input = "-iuxyz --count"
        let output = \"\"\"
        Errors:
          unrecognized options: "-x", "-y" and "-z", in "-iuxyz"
          missing expected value after "--count"
          missing value: "<animal>"
        See "PRODUCT_NAME --help" for more information.
        \"\"\"
        let ok = await testOutput(of: TARGET_NAME.run, with: input, expecting: output)
        #expect(ok)
    }

    /* -- Decomment to see failed test reporting
    // This test will fail because the contrived expected output is purposely incorrect
    @Test func FailedErrorsTest() async {
        let input = "-iuxyz --count"
        let output = \"\"\"
        Errors:
          unrecognized options: "-x", "-y" and "-z", in "-iuxyz"
          missing an expected value after "--count"
          missing an "<animal>"
        See "PRODUCT_NAME --help" for more information.
        \"\"\"
        let ok = await testOutput(of: TARGET_NAME.run, with: input, expecting: output)
        #expect(ok)
    }
    */
}
"""

let minimalTestingTest = """
// Copyright (c) <YEAR> <AUTHOR>

import CmdArgLibCore
import CmdArgLibTestSupport
import Testing
@testable import TARGET_NAMESupport


// These require CmdArgLibCore and CmdArgLibTestSupport
struct TARGET_NAMEOutputTests {

    @Test func SimpleTest()  async {
        let input = "--upper"
        let output = \"\"\"
        A GNU IS AN ANIMAL.
        \"\"\"
        let ok = await testOutput(of: TARGET_NAME.run, with: input, expecting: output)
        #expect(ok)
    }

    @Test func ErrorsTest()  async {
        let input = "-iuc2 wolf"
        let output = \"\"\"
        Errors:
          unrecognized options: "-i", "-c" and "-2", in "-iuc2"
          unassigned argument: "wolf"
        See "my-testing --help" for more information.
        \"\"\"
        let ok = await testOutput(of: TARGET_NAME.run, with: input, expecting: output)
        #expect(ok)
    }

    @Test func HelpTest() async {
        let input = "--help"
        let output = \"\"\"
        DESCRIPTION
          Explain GNU.

        USAGE
          my-testing [-uh] [--version]

        OPTIONS
          -u/--upper            Uppercase the output.
          -h/--help             Show this help message.
          --version             Show version information.

        NOTES
          A gnu is an animal.
        \"\"\"
        let ok = await testOutput(of: TARGET_NAME.run, with: input, expecting: output)
        #expect(ok)
    }

    /* -- Decomment to see failed test reporting
    // This test will fail because the contrived expected output is purposely incorrect
    @Test func FailedTest()  async {
            let input = "--upper"
            let output = \"\"\"
            GNU’s Not Unix!
            \"\"\"
            let ok = await testOutput(of: TARGET_NAME.run, with: input, expecting: output)
            #expect(ok)
        }
    */
}
"""
