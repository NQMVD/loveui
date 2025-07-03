# LoveUI Styling Rewrite - TODO List

## Core Architecture & Configuration System

- [ ] **Extract all hardcoded values** - absolute priority, no hardcoded styling values allowed
- [ ] **Implement modular configuration system**
  - [ ] Create distinction between `Settings` (app-level: API refresh rates, etc.) and `Configurations` (UI-level: corner radius, etc.)
  - [ ] Remove all default values from library components
  - [ ] Ensure all components require explicit configuration to function
  - [ ] Implement configuration validation system

- [ ] **State Management**
  - [ ] Create centralized UI instance state tracking
  - [ ] Track all themes, configurations, and runtime changes
  - [ ] Implement runtime configuration updates

## Theme System

- [ ] **Theme Architecture**
  - [ ] Design theme structure to hold both styling and color configurations
  - [ ] Implement **Color Palettes** (not "color themes" - use this terminology)
  - [ ] Include font definitions within themes
  - [ ] Create theme switching mechanism

- [ ] **Styling Configurations**
  - [ ] Corner radius system
  - [ ] Border width configurations
  - [ ] Drop shadow intensity settings
  - [ ] Inner glowing/shining effects system

## Font System

- [ ] **Font Management**
  - [ ] Implement font loading with configurable default sizes
  - [ ] Support normal text and heading text size definitions
  - [ ] Enable runtime font switching
  - [ ] Integrate system font support (prioritize macOS system font if possible in Love2D)
  - [ ] Default fallback to Love2D standard font

## Component Development

### Existing Components (Refactor)
- [ ] **Buttons** - apply new configuration system
- [ ] **Panes** (rename from Cards/Container)
  - [ ] Implement layout engine
  - [ ] Support Top-to-Bottom and Left-to-Right layouts
  - [ ] Support XY coordinate positioning within panes
  - [ ] Add component scaling capabilities
- [ ] **Choosers** (Tab like chooser) - apply new configuration system

### New Components
- [ ] **Sliders**
  - [ ] Floating precision mode
  - [ ] Integer precision mode with tick snapping
  - [ ] Display tick marks below slider
  - [ ] Show min/max values (left/right positions)
  - [ ] Display current value above slider head
  - [ ] Full theme integration

- [ ] **Checkboxes**
  - [ ] Basic checkbox functionality
  - [ ] Theme integration for styling

- [ ] **Dropdown**
  - [ ] Predefined selection list
  - [ ] Default state: nothing selected
  - [ ] No text input capability (separate component)

- [ ] **Text Input**
  - [ ] Separate from dropdown
  - [ ] Optional button on right side
  - [ ] Theme integration

- [ ] **Text Component** (Label)
  - [ ] Standalone text rendering
  - [ ] Configurable font selection
  - [ ] Configurable text color
  - [ ] Wrap limit settings
  - [ ] Full theme integration

## Layout System

- [ ] **Free Positioning**
  - [ ] Support XY coordinate placement for all components
  - [ ] Implement positioning relative to parent containers

- [ ] **Pane Layout Engine**
  - [ ] Top-to-Bottom layout mode
  - [ ] Left-to-Right layout mode
  - [ ] Mixed positioning (XY coordinates within layout panes)
  - [ ] Component scaling within layouts

## Implementation Priority

1. **Phase 1: Core Architecture**
   - Configuration system
   - State management
   - Remove hardcoded values

2. **Phase 2: Theme Foundation**
   - Basic theme structure
   - Color palette system
   - Font system

3. **Phase 3: Component Refactoring**
   - Update existing components
   - Implement layout system

4. **Phase 4: New Components**
   - Implement remaining components
   - Full theme integration testing
