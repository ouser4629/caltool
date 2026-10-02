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


struct GlobalOptions {

    let releaseDir: ReleaseDirectory
    let productDir: ProductDirectory
    let manpageDir: ManpageDirectory
    let fishDir: FishDirectory
    let zshDir: ZshDirectory

    init(releaseDir: ReleaseDirectory = "--generate-manpage",
         productDir: ProductDirectory = ".build/release",
         manpageDir: ManpageDirectory = "~/.local/bin",
         fishDir: FishDirectory = "~/.local/share/man/man1",
         zshDir: ZshDirectory = "~/.config/zsh/completions")
    {
        self.releaseDir = releaseDir
        self.productDir = productDir
        self.manpageDir = manpageDir
        self.fishDir = fishDir
        self.zshDir = zshDir
    }
}
