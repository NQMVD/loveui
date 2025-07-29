use egui::{Context, RawInput};
use crate::{Love2DBackend, Result};
use std::time::Instant;

pub struct EguiContext {
    ctx: Context,
    backend: Love2DBackend,
    raw_input: RawInput,
    start_time: Instant,
}

impl EguiContext {
    pub fn new(screen_width: f32, screen_height: f32) -> Result<Self> {
        let ctx = Context::default();
        let backend = Love2DBackend::new(screen_width, screen_height)?;
        
        let mut raw_input = RawInput::default();
        raw_input.screen_rect = Some(egui::Rect::from_min_size(
            egui::Pos2::ZERO,
            egui::Vec2::new(screen_width, screen_height),
        ));
        
        Ok(Self {
            ctx,
            backend,
            raw_input,
            start_time: Instant::now(),
        })
    }
    
    pub fn begin_frame(&mut self, dt: f32) {
        self.raw_input.time = Some(self.start_time.elapsed().as_secs_f64());
        self.raw_input.predicted_dt = dt;
        
        self.ctx.begin_pass(self.raw_input.take());
    }
    
    pub fn end_frame(&mut self) -> Result<()> {
        let full_output = self.ctx.end_pass();
        self.backend.handle_output(&full_output)?;
        Ok(())
    }
    
    pub fn context(&self) -> &Context {
        &self.ctx
    }
    
    pub fn context_mut(&mut self) -> &mut Context {
        &mut self.ctx
    }
    
    pub fn add_mouse_button_input(&mut self, button: egui::PointerButton, pressed: bool) {
        self.raw_input.events.push(egui::Event::PointerButton {
            pos: egui::Pos2::ZERO, // We'll update this with actual mouse position
            button,
            pressed,
            modifiers: self.raw_input.modifiers,
        });
    }
    
    pub fn add_mouse_motion(&mut self, x: f32, y: f32) {
        self.raw_input.events.push(egui::Event::PointerMoved(egui::Pos2::new(x, y)));
    }
    
    pub fn add_mouse_wheel(&mut self, delta_x: f32, delta_y: f32) {
        self.raw_input.events.push(egui::Event::MouseWheel {
            unit: egui::MouseWheelUnit::Point,
            delta: egui::Vec2::new(delta_x, delta_y),
            modifiers: self.raw_input.modifiers,
        });
    }
    
    pub fn add_text_input(&mut self, text: &str) {
        self.raw_input.events.push(egui::Event::Text(text.to_string()));
    }
    
    pub fn add_key_input(&mut self, key: egui::Key, pressed: bool) {
        self.raw_input.events.push(egui::Event::Key {
            key,
            physical_key: None,
            pressed,
            repeat: false,
            modifiers: self.raw_input.modifiers,
        });
    }
    
    pub fn set_modifiers(&mut self, ctrl: bool, alt: bool, shift: bool, meta: bool) {
        self.raw_input.modifiers = egui::Modifiers {
            alt,
            ctrl,
            shift,
            mac_cmd: meta,
            command: if cfg!(target_os = "macos") { meta } else { ctrl },
        };
    }
    
    pub fn resize(&mut self, width: f32, height: f32) -> Result<()> {
        self.raw_input.screen_rect = Some(egui::Rect::from_min_size(
            egui::Pos2::ZERO,
            egui::Vec2::new(width, height),
        ));
        self.backend.resize(width, height)
    }
    
    pub fn backend(&self) -> &Love2DBackend {
        &self.backend
    }
    
    pub fn backend_mut(&mut self) -> &mut Love2DBackend {
        &mut self.backend
    }
}