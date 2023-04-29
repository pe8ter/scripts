#
# nvm-use.ps1
# Peter Safranek
# https://github.com/pe8ter/
#
# ABOUT
#
# nvm-use.ps1 is a convenience script for NVM for Windows that makes installing Node.js easier when your project has
# a .nvmrc file. It reads this file, installs the desired version of Node.js if necessary, then activates it.
#
# USAGE
#
# 1. You must already have NVM for Windows installed: https://github.com/coreybutler/nvm-windows.
# 2. Copy nvm-use.ps1 to a directory that is available on your System Path.
# 3. From a directory in PowerShell that has a .nvmrc file, run `nvm-use`.
#
# LICENSE
#
# Copyright © 2023 Peter Safranek
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

########################################################################################################################
# Verify that .nvmrc file exists in the current directory.
########################################################################################################################

$nvmrc_exists = Test-Path .\.nvmrc -PathType Leaf

if (!$nvmrc_exists) {
    Write-Host "Local .nvmrc not found." -ForegroundColor Red
    Exit 1
}

########################################################################################################################
# Read and validate .nvmrc contents.
########################################################################################################################

$nvmrc_contents = (Get-Content .\.nvmrc).Trim()
$node_version_regex = "^v?([0-9]+\.[0-9]+\.[0-9]+)$"
$is_valid_nodejs_version = $nvmrc_contents -match $node_version_regex

if ($is_valid_nodejs_version) {
    $desired_nodejs_version = $matches[1]   # Save for later.
} else {
    Write-Host "Node.js version format in .nvmrc is invalid. Found `"$nvmrc_contents`"." -ForegroundColor Red
    Exit 1
}

########################################################################################################################
# Verify that nvm is installed.
########################################################################################################################

$is_nvm_installed = Get-Command "nvm" -ErrorAction SilentlyContinue

if (!$is_nvm_installed) {
    Write-Host "nvm is not installed." -ForegroundColor Red
    Exit 1
}

########################################################################################################################
# Install desired version of Node.js if necessary.
########################################################################################################################

$is_desired_nodejs_version_installed = $false

ForEach ($line in $((nvm list installed) -split "\r?\n")) {
    $line_contains_correct_version = $line -match $desired_nodejs_version
    if ($line_contains_correct_version) {
        $is_desired_nodejs_version_installed = $true
        Break
    }
}

if (!$is_desired_nodejs_version_installed) {
    nvm install $desired_nodejs_version
}

########################################################################################################################
# Use the desired version.
########################################################################################################################

nvm use $desired_nodejs_version
