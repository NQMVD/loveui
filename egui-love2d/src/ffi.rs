use crate::{input::Love2DInputEvent, with_context, initialize, shutdown, EguiUI};
use std::ffi::CStr;
use std::os::raw::{c_char, c_int, c_float};

/// FFI functions for C interop
#[no_mangle]
pub extern "C" fn egui_love2d_init(width: c_float, height: c_float) -> c_int {
    match initialize(width, height) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_shutdown() {
    shutdown();
}

#[no_mangle]
pub extern "C" fn egui_love2d_begin_frame(dt: c_float) -> c_int {
    match with_context(|ctx| ctx.begin_frame(dt)) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_end_frame() -> c_int {
    match with_context(|ctx| ctx.end_frame()) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_handle_key(key_ptr: *const c_char, pressed: c_int) -> c_int {
    if key_ptr.is_null() {
        return 0;
    }
    
    let key_cstr = unsafe { CStr::from_ptr(key_ptr) };
    let key = match key_cstr.to_str() {
        Ok(s) => s.to_string(),
        Err(_) => return 0,
    };
    
    let event = if pressed != 0 {
        Love2DInputEvent::KeyPressed { key }
    } else {
        Love2DInputEvent::KeyReleased { key }
    };
    
    match with_context(|ctx| event.apply_to_context(ctx)) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_handle_text(text_ptr: *const c_char) -> c_int {
    if text_ptr.is_null() {
        return 0;
    }
    
    let text_cstr = unsafe { CStr::from_ptr(text_ptr) };
    let text = match text_cstr.to_str() {
        Ok(s) => s.to_string(),
        Err(_) => return 0,
    };
    
    let event = Love2DInputEvent::TextInput { text };
    
    match with_context(|ctx| event.apply_to_context(ctx)) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_handle_mouse_button(x: c_float, y: c_float, button: c_int, pressed: c_int) -> c_int {
    let event = if pressed != 0 {
        Love2DInputEvent::MousePressed { x, y, button: button as u32 }
    } else {
        Love2DInputEvent::MouseReleased { x, y, button: button as u32 }
    };
    
    match with_context(|ctx| event.apply_to_context(ctx)) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_handle_mouse_move(x: c_float, y: c_float) -> c_int {
    let event = Love2DInputEvent::MouseMoved { x, y };
    
    match with_context(|ctx| event.apply_to_context(ctx)) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_handle_wheel(x: c_float, y: c_float) -> c_int {
    let event = Love2DInputEvent::WheelMoved { x, y };
    
    match with_context(|ctx| event.apply_to_context(ctx)) {
        Ok(_) => 1,
        Err(_) => 0,
    }
}

// UI element creation functions
#[no_mangle]
pub extern "C" fn egui_love2d_button(text_ptr: *const c_char, x: c_float, y: c_float, width: c_float, height: c_float) -> c_int {
    if text_ptr.is_null() {
        return 0;
    }
    
    let text_cstr = unsafe { CStr::from_ptr(text_ptr) };
    let text = match text_cstr.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    
    match with_context(|ctx| {
        EguiUI::button(
            ctx.context_mut(),
            text,
            egui::Pos2::new(x, y),
            egui::Vec2::new(width, height),
        )
    }) {
        Ok(Ok(clicked)) => if clicked { 1 } else { 0 },
        _ => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_text(text_ptr: *const c_char, x: c_float, y: c_float) -> c_int {
    if text_ptr.is_null() {
        return 0;
    }
    
    let text_cstr = unsafe { CStr::from_ptr(text_ptr) };
    let text = match text_cstr.to_str() {
        Ok(s) => s,
        Err(_) => return 0,
    };
    
    match with_context(|ctx| {
        EguiUI::text(
            ctx.context_mut(),
            text,
            egui::Pos2::new(x, y),
            egui::Color32::WHITE,
        )
    }) {
        Ok(Ok(_)) => 1,
        _ => 0,
    }
}

#[no_mangle]
pub extern "C" fn egui_love2d_get_draw_commands_count() -> c_int {
    match with_context(|ctx| {
        let commands = ctx.backend().get_draw_commands();
        commands.len() as c_int
    }) {
        Ok(count) => count,
        Err(_) => 0,
    }
}