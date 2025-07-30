# egui-Love2D Bridge

A comprehensive bridge that enables [egui](https://github.com/emilk/egui) (Rust immediate mode GUI library) to work seamlessly within [LÖVE2D](https://love2d.org/) applications.

## Features

- **Cross-Platform**: Works on Windows, macOS, and Linux
- **Real UI Integration**: Actual egui buttons and text rendering (not fake implementations)
- **Complete Input Handling**: Keyboard, mouse, and text input forwarding
- **Performance Optimized**: Rust backend with minimal overhead
- **Easy Integration**: Simple Lua API that integrates with Love2D callbacks

## Building

### Prerequisites

All platforms require:
- [Rust](https://rustup.rs/) (latest stable version)
- [Love2D](https://love2d.org/) for running examples

### Cross-Platform Build Script

The easiest way to build is using the cross-platform build script:

```bash
./build.sh
```

This script automatically detects your platform and runs the appropriate build commands.

### Platform-Specific Building

#### Linux
```bash
./build-linux.sh
```

Automatically installs dependencies via your system's package manager:
- Ubuntu/Debian: `apt`
- RHEL/CentOS: `yum` or `dnf`
- Arch: `pacman`
- openSUSE: `zypper`

#### macOS
```bash
./build-macos.sh
```

Uses Homebrew to install dependencies. Make sure you have [Homebrew](https://brew.sh/) installed.

#### Windows
```powershell
.\build-windows.ps1
```

Run in PowerShell. The script will guide you through installing required dependencies like Visual Studio Build Tools.

### Rust Integration (Advanced)

For Rust developers, you can integrate the build process into Cargo:

```bash
cd egui-love2d
cargo build --release
```

The `build.rs` file handles platform-specific linking automatically.

## Usage

### Basic Example

```lua
local egui = require("love2d-egui.egui")

function love.load()
    local width, height = love.graphics.getDimensions()
    egui.init(width, height)
    egui.setup_callbacks()  -- Automatic input handling
end

function love.update(dt)
    egui.begin_frame(dt)
    
    local ui = egui.create_ui()
    if ui:button("Click me!", 100, 100, 120, 30) then
        print("Button clicked!")
    end
    ui:text("Hello from egui!", 100, 150)
    
    egui.end_frame()
end

function love.draw()
    -- Your game content
    love.graphics.print("My Game", 10, 10)
    
    -- egui UI overlay
    egui.render()
end

function love.quit()
    egui.shutdown()
end
```

### Running the Example

After building:

```bash
cd example
love .
```

## Files Structure

```
egui-love2d/           # Rust library source
├── src/
│   ├── lib.rs        # Main library entry
│   ├── ffi.rs        # C FFI interface
│   ├── ui.rs         # High-level UI functions
│   ├── context.rs    # egui context management
│   ├── backend.rs    # Love2D backend implementation
│   ├── input.rs      # Input handling
│   ├── renderer.rs   # Rendering commands
│   └── errors.rs     # Error types
├── Cargo.toml        # Rust dependencies
└── build.rs          # Build configuration

love2d-egui/           # Lua integration module
└── egui.lua          # Love2D Lua API

example/               # Working example
└── main.lua          # Demo application

build*.sh/*.ps1        # Platform-specific build scripts
```

## API Reference

### Initialization

```lua
egui.init(width, height)          -- Initialize with screen dimensions
egui.setup_callbacks()            -- Setup automatic input handling
egui.shutdown()                   -- Clean shutdown
```

### Frame Management

```lua
egui.begin_frame(dt)              -- Start UI frame
egui.end_frame()                  -- End UI frame
egui.render()                     -- Render UI to screen
```

### UI Elements

```lua
local ui = egui.create_ui()

-- Button (returns true when clicked)
local clicked = ui:button("Text", x, y, width, height)

-- Text display
ui:text("Text", x, y)
```

### Input Handling

The library automatically handles input when `egui.setup_callbacks()` is called. Manual input handling is also available:

```lua
egui.keypressed(key, scancode, isrepeat)
egui.keyreleased(key, scancode)
egui.textinput(text)
egui.mousepressed(x, y, button, istouch, presses)
egui.mousereleased(x, y, button, istouch, presses)
egui.mousemoved(x, y, dx, dy, istouch)
egui.wheelmoved(x, y)
```

## Troubleshooting

### Library Loading Issues

If you get "library not found" errors:

1. Make sure the library file is in the correct location:
   - Linux: `libegui_love2d.so`
   - macOS: `libegui_love2d.dylib`
   - Windows: `egui_love2d.dll`

2. Check that the `love2d-egui` module is accessible from your Lua script

3. Verify dependencies are installed (run the appropriate build script)

### Build Issues

1. **Missing Rust**: Install from https://rustup.rs/
2. **Missing pkg-config**: Install via your system package manager
3. **Missing Lua dev headers**: Install lua development packages
4. **Windows MSVC**: Install Visual Studio Build Tools

### Runtime Issues

1. **Segfaults**: Usually indicates FFI interface issues - make sure the library was built correctly
2. **No UI visible**: Check that `egui.render()` is called in `love.draw()`
3. **Input not working**: Ensure `egui.setup_callbacks()` was called

## Contributing

1. Fork the repository
2. Create your feature branch
3. Make changes to either the Rust code (egui-love2d/) or Lua code (love2d-egui/)
4. Test on your platform using the build scripts
5. Submit a pull request

## License

MIT License - see the individual source files for details.