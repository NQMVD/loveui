use egui::{Key, PointerButton};

/// Convert Love2D key names to egui keys
pub fn love2d_key_to_egui(love_key: &str) -> Option<Key> {
    match love_key {
        "a" => Some(Key::A),
        "b" => Some(Key::B),
        "c" => Some(Key::C),
        "d" => Some(Key::D),
        "e" => Some(Key::E),
        "f" => Some(Key::F),
        "g" => Some(Key::G),
        "h" => Some(Key::H),
        "i" => Some(Key::I),
        "j" => Some(Key::J),
        "k" => Some(Key::K),
        "l" => Some(Key::L),
        "m" => Some(Key::M),
        "n" => Some(Key::N),
        "o" => Some(Key::O),
        "p" => Some(Key::P),
        "q" => Some(Key::Q),
        "r" => Some(Key::R),
        "s" => Some(Key::S),
        "t" => Some(Key::T),
        "u" => Some(Key::U),
        "v" => Some(Key::V),
        "w" => Some(Key::W),
        "x" => Some(Key::X),
        "y" => Some(Key::Y),
        "z" => Some(Key::Z),
        
        "0" => Some(Key::Num0),
        "1" => Some(Key::Num1),
        "2" => Some(Key::Num2),
        "3" => Some(Key::Num3),
        "4" => Some(Key::Num4),
        "5" => Some(Key::Num5),
        "6" => Some(Key::Num6),
        "7" => Some(Key::Num7),
        "8" => Some(Key::Num8),
        "9" => Some(Key::Num9),
        
        "escape" => Some(Key::Escape),
        "return" => Some(Key::Enter),
        "tab" => Some(Key::Tab),
        "space" => Some(Key::Space),
        "backspace" => Some(Key::Backspace),
        "delete" => Some(Key::Delete),
        
        "left" => Some(Key::ArrowLeft),
        "right" => Some(Key::ArrowRight),
        "up" => Some(Key::ArrowUp),
        "down" => Some(Key::ArrowDown),
        
        "home" => Some(Key::Home),
        "end" => Some(Key::End),
        "pageup" => Some(Key::PageUp),
        "pagedown" => Some(Key::PageDown),
        
        "f1" => Some(Key::F1),
        "f2" => Some(Key::F2),
        "f3" => Some(Key::F3),
        "f4" => Some(Key::F4),
        "f5" => Some(Key::F5),
        "f6" => Some(Key::F6),
        "f7" => Some(Key::F7),
        "f8" => Some(Key::F8),
        "f9" => Some(Key::F9),
        "f10" => Some(Key::F10),
        "f11" => Some(Key::F11),
        "f12" => Some(Key::F12),
        
        "lctrl" | "rctrl" => Some(Key::Backspace), // No direct equivalent
        "lalt" | "ralt" => Some(Key::Backspace),   // No direct equivalent  
        "lshift" | "rshift" => Some(Key::Backspace), // No direct equivalent
        
        _ => None,
    }
}

/// Convert Love2D mouse button to egui pointer button
pub fn love2d_mouse_button_to_egui(button: u32) -> Option<PointerButton> {
    match button {
        1 => Some(PointerButton::Primary),   // Left click
        2 => Some(PointerButton::Secondary), // Right click  
        3 => Some(PointerButton::Middle),    // Middle click
        _ => None,
    }
}

/// Love2D input event types that we need to handle
#[derive(Debug, Clone)]
pub enum Love2DInputEvent {
    KeyPressed { key: String },
    KeyReleased { key: String },
    TextInput { text: String },
    MousePressed { x: f32, y: f32, button: u32 },
    MouseReleased { x: f32, y: f32, button: u32 },
    MouseMoved { x: f32, y: f32 },
    WheelMoved { x: f32, y: f32 },
}

impl Love2DInputEvent {
    /// Apply this input event to the egui context
    pub fn apply_to_context(self, ctx: &mut crate::EguiContext) -> crate::Result<()> {
        match self {
            Love2DInputEvent::KeyPressed { key } => {
                if let Some(egui_key) = love2d_key_to_egui(&key) {
                    ctx.add_key_input(egui_key, true);
                }
            },
            Love2DInputEvent::KeyReleased { key } => {
                if let Some(egui_key) = love2d_key_to_egui(&key) {
                    ctx.add_key_input(egui_key, false);
                }
            },
            Love2DInputEvent::TextInput { text } => {
                ctx.add_text_input(&text);
            },
            Love2DInputEvent::MousePressed { x, y, button } => {
                ctx.add_mouse_motion(x, y);
                if let Some(egui_button) = love2d_mouse_button_to_egui(button) {
                    ctx.add_mouse_button_input(egui_button, true);
                }
            },
            Love2DInputEvent::MouseReleased { x, y, button } => {
                ctx.add_mouse_motion(x, y);
                if let Some(egui_button) = love2d_mouse_button_to_egui(button) {
                    ctx.add_mouse_button_input(egui_button, false);
                }
            },
            Love2DInputEvent::MouseMoved { x, y } => {
                ctx.add_mouse_motion(x, y);
            },
            Love2DInputEvent::WheelMoved { x, y } => {
                ctx.add_mouse_wheel(x, y);
            },
        }
        Ok(())
    }
}