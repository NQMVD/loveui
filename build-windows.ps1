# Build script for the egui-Love2D bridge on Windows
# Run this script in PowerShell as Administrator if needed for dependency installation

param(
    [switch]$SkipDependencies = $false
)

Write-Host "Building egui-Love2D bridge for Windows..." -ForegroundColor Green

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check for Rust/Cargo
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Rust/Cargo not found. Please install Rust from https://rustup.rs/" -ForegroundColor Red
    exit 1
}

# Check for MSVC Build Tools or Visual Studio
$vcvarsPath = ""
$possiblePaths = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $vcvarsPath = $path
        break
    }
}

if (-not $vcvarsPath) {
    Write-Host "Warning: MSVC Build Tools not found. You may need to install Visual Studio Build Tools." -ForegroundColor Yellow
    Write-Host "Download from: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019" -ForegroundColor Yellow
    
    if (-not $SkipDependencies) {
        $continue = Read-Host "Continue anyway? (y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            exit 1
        }
    }
}

# Check for vcpkg (optional, for easier dependency management)
if (Get-Command vcpkg -ErrorAction SilentlyContinue) {
    Write-Host "vcpkg found - dependencies can be managed via vcpkg if needed" -ForegroundColor Green
} else {
    Write-Host "vcpkg not found - this is optional but can help manage C++ dependencies" -ForegroundColor Yellow
}

Write-Host "Prerequisites check complete." -ForegroundColor Green

# Build the Rust library
Write-Host "Building Rust library..." -ForegroundColor Yellow
Set-Location egui-love2d

# Clean previous builds
cargo clean

# Build release version
Write-Host "Building release version..." -ForegroundColor Yellow
cargo build --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "Rust library built successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to build Rust library." -ForegroundColor Red
    exit 1
}

Set-Location ..

# Copy library to example directory for easy testing
Write-Host "Setting up example..." -ForegroundColor Yellow
$LIB_FILE = "egui_love2d.dll"

if (Test-Path "egui-love2d\target\release\$LIB_FILE") {
    Copy-Item "egui-love2d\target\release\$LIB_FILE" "example\"
    Write-Host "Library copied to example directory." -ForegroundColor Green
} else {
    Write-Host "Library file not found: egui-love2d\target\release\$LIB_FILE" -ForegroundColor Red
}

# Create a junction/symlink for the love2d-egui module in the example directory
if (-not (Test-Path "example\love2d-egui")) {
    # Try to create a symbolic link (requires admin privileges)
    try {
        New-Item -ItemType SymbolicLink -Path "example\love2d-egui" -Target "..\love2d-egui" -ErrorAction Stop
        Write-Host "Created symbolic link for love2d-egui module in example directory." -ForegroundColor Green
    } catch {
        # Fallback: create a junction (works without admin privileges)
        try {
            cmd /c mklink /J "example\love2d-egui" "..\love2d-egui"
            Write-Host "Created junction for love2d-egui module in example directory." -ForegroundColor Green
        } catch {
            # Fallback: copy the files
            Copy-Item "love2d-egui" "example\love2d-egui" -Recurse
            Write-Host "Copied love2d-egui module to example directory." -ForegroundColor Yellow
        }
    }
}

Write-Host "Build complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To run the example:" -ForegroundColor Yellow
Write-Host "  cd example"

# Check if Love2D is available
if (Get-Command love -ErrorAction SilentlyContinue) {
    Write-Host "  love ."
} else {
    Write-Host "  # Install Love2D first, then run: love ."
    Write-Host "  # Download from: https://love2d.org/"
}

Write-Host ""
Write-Host "Library files:" -ForegroundColor Yellow
Write-Host "  Rust library: egui-love2d\target\release\$LIB_FILE"
Write-Host "  Lua module: love2d-egui\egui.lua"
Write-Host "  Example: example\main.lua"