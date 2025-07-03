# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

The ast-grep tool is installed which can be used for structured code replacements instead of grep or ripgrep, those should only be used for normal text search/replace.

## Development Commands

**Running the application:**
```bash
just run          # Start the Love2D application
love src          # Alternative way to run
```

**Development workflow:**
```bash
just watch        # Auto-restart on file changes (uses fd + entr)
```

**Linting:**
```bash
selene src/       # Lua linter (configured for Love2D)
```

## Project Architecture

This is **LoveUI** - a modern UI library for Love2D (Lua game framework). The project demonstrates and tests the UI components with a comprehensive demo application.

### Core Structure

- `src/main.lua` - Demo application showcasing all UI components
- `src/lib/ui/` - The actual UI library modules:
  - `init.lua` - Main UI module and factory functions
  - `theme.lua` - Theme system with dark/light themes and style customization
  - `colors.lua` - Color palette definitions
  - `button.lua`, `card.lua`, `chooser.lua` - Individual UI components
  - `utils.lua` - Utility functions including font loading
  - `layout.lua` - Layout management

### Theme System

The library uses a sophisticated theme system:
- Themes contain both colors and component-specific styling (corner radius, smoothness, etc.)
- Multiple built-in themes: `rounded`, `sharp`, `ios`, `dark`, `light`
- Runtime theme switching supported
- Each component can have style overrides per theme

### UI Components

**Button**: Supports multiple styles (`primary`, `secondary`, `secondary_shine`) with customizable corner radius, smoothness, and shine effects.

**Card**: Container component that can hold text and other elements, with configurable padding and styling.

**Chooser**: Segmented control component for selecting between options.

### Key Patterns

1. **Component Lifecycle**: All components have `update(dt)` and `draw()` methods, plus mouse event handlers
2. **Style Resolution**: Components get styling through `theme.get_style(element_type, property, fallback)`
3. **Theme Integration**: Colors accessed via `theme.get_color(color_name, fallback)`
4. **Factory Pattern**: Create components via `ui.create_button()`, `ui.create_card()`, etc.

### Dependencies

- **Love2D**: Main framework
- **debugui**: Debug interface overlay (external dependency)
- **Camera**: Camera system for pan/zoom (external dependency)
- **serpent**: Lua table serialization
- **lume**: Lua utilities

### Configuration

- `src/conf.lua` - Love2D configuration (window size, MSAA, etc.)
- `selene.toml` - Linter configuration optimized for Love2D globals
- `justfile` - Task runner configuration

### Debug Features

The demo includes extensive debug controls via the debugui overlay:
- Theme switching
- Real-time style parameter adjustment
- Performance monitoring
- Camera controls for freeroam mode

When working on this codebase, follow the existing patterns for component creation and theme integration. All new components should support the theme system and follow the established update/draw/mouse_event lifecycle.