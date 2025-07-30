use mlua::{Lua, Result as LuaResult, Table, UserData, UserDataMethods};
use crate::{input::Love2DInputEvent, renderer::Love2DRenderer, with_context, initialize, shutdown, EguiUI};
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

/// Lua API implementation
pub struct EguiLua {
    renderer: Love2DRenderer,
}

impl UserData for EguiLua {
    fn add_methods<M: UserDataMethods<Self>>(methods: &mut M) {
        methods.add_method_mut("button", |_, _this, (text, x, y, width, height): (String, f32, f32, f32, f32)| {
            match with_context(|ctx| {
                EguiUI::button(
                    ctx.context_mut(),
                    &text,
                    egui::Pos2::new(x, y),
                    egui::Vec2::new(width, height),
                )
            }) {
                Ok(Ok(clicked)) => Ok(clicked),
                _ => Ok(false),
            }
        });
        
        methods.add_method_mut("text", |_, _this, (text, x, y): (String, f32, f32)| {
            match with_context(|ctx| {
                EguiUI::text(
                    ctx.context_mut(),
                    &text,
                    egui::Pos2::new(x, y),
                    egui::Color32::WHITE,
                )
            }) {
                Ok(Ok(_)) => Ok(()),
                _ => Ok(()),
            }
        });
        
        methods.add_method_mut("get_draw_commands", |_, this, ()| {
            match with_context(|ctx| {
                let commands = ctx.backend().get_draw_commands();
                this.renderer.render(commands)
            }) {
                Ok(Ok(commands)) => Ok(commands),
                _ => Ok(Vec::<String>::new()),
            }
        });
    }
}

/// Create Lua module
pub fn create_lua_module(lua: &Lua) -> LuaResult<Table> {
    let module = lua.create_table()?;
    
    // Initialize function
    let init_fn = lua.create_function(|_, (width, height): (f32, f32)| {
        match initialize(width, height) {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })?;
    module.set("init", init_fn)?;
    
    // Shutdown function
    let shutdown_fn = lua.create_function(|_, ()| {
        shutdown();
        Ok(())
    })?;
    module.set("shutdown", shutdown_fn)?;
    
    // Begin frame function
    let begin_frame_fn = lua.create_function(|_, dt: f32| {
        match with_context(|ctx| ctx.begin_frame(dt)) {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })?;
    module.set("begin_frame", begin_frame_fn)?;
    
    // End frame function
    let end_frame_fn = lua.create_function(|_, ()| {
        match with_context(|ctx| ctx.end_frame()) {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })?;
    module.set("end_frame", end_frame_fn)?;
    
    // Input handling functions
    let handle_key_fn = lua.create_function(|_, (key, pressed): (String, bool)| {
        let event = if pressed {
            Love2DInputEvent::KeyPressed { key }
        } else {
            Love2DInputEvent::KeyReleased { key }
        };
        
        match with_context(|ctx| event.apply_to_context(ctx)) {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })?;
    module.set("handle_key", handle_key_fn)?;
    
    let handle_text_fn = lua.create_function(|_, text: String| {
        let event = Love2DInputEvent::TextInput { text };
        
        match with_context(|ctx| event.apply_to_context(ctx)) {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })?;
    module.set("handle_text", handle_text_fn)?;
    
    let handle_mouse_fn = lua.create_function(|_, (x, y, button, pressed): (f32, f32, u32, bool)| {
        let event = if pressed {
            Love2DInputEvent::MousePressed { x, y, button }
        } else {
            Love2DInputEvent::MouseReleased { x, y, button }
        };
        
        match with_context(|ctx| event.apply_to_context(ctx)) {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })?;
    module.set("handle_mouse", handle_mouse_fn)?;
    
    let handle_mouse_move_fn = lua.create_function(|_, (x, y): (f32, f32)| {
        let event = Love2DInputEvent::MouseMoved { x, y };
        
        match with_context(|ctx| event.apply_to_context(ctx)) {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })?;
    module.set("handle_mouse_move", handle_mouse_move_fn)?;
    
    let handle_wheel_fn = lua.create_function(|_, (x, y): (f32, f32)| {
        let event = Love2DInputEvent::WheelMoved { x, y };
        
        match with_context(|ctx| event.apply_to_context(ctx)) {
            Ok(_) => Ok(true),
            Err(_) => Ok(false),
        }
    })?;
    module.set("handle_wheel", handle_wheel_fn)?;
    
    // UI creation functions
    let create_ui_fn = lua.create_function(|_, ()| {
        Ok(EguiLua {
            renderer: Love2DRenderer::new(),
        })
    })?;
    module.set("create_ui", create_ui_fn)?;
    
    Ok(module)
}