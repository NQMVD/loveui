use egui::{Context, Vec2, Pos2, Color32};
use crate::Result;

/// High-level UI helper functions that work with the egui context
pub struct EguiUI;

impl EguiUI {
    /// Create a simple button and return whether it was clicked
    pub fn button(ctx: &mut Context, text: &str, pos: Pos2, size: Vec2) -> Result<bool> {
        let mut clicked = false;
        
        // Create a custom area for the button at the specified position
        let area = egui::Area::new(format!("button_{}_{}_{}", text, pos.x, pos.y).into())
            .fixed_pos(pos)
            .movable(false)
            .enabled(true)
            .order(egui::Order::Foreground);
            
        area.show(ctx, |ui| {
            ui.set_max_size(size);
            if ui.button(text).clicked() {
                clicked = true;
            }
        });
        
        Ok(clicked)
    }
    
    /// Display text at a specific position
    pub fn text(ctx: &mut Context, text: &str, pos: Pos2, color: Color32) -> Result<()> {
        // Create a custom area for the text at the specified position
        let area = egui::Area::new(format!("text_{}_{}_{}", text, pos.x, pos.y).into())
            .fixed_pos(pos)
            .movable(false)
            .enabled(false)
            .order(egui::Order::Background);
            
        area.show(ctx, |ui| {
            ui.colored_label(color, text);
        });
        
        Ok(())
    }
    
    /// Create a window with content
    pub fn window<F>(
        ctx: &mut Context,
        title: &str,
        pos: Pos2,
        size: Vec2,
        content: F,
    ) -> Result<()>
    where
        F: FnOnce(&mut egui::Ui),
    {
        egui::Window::new(title)
            .default_pos(pos)
            .default_size(size)
            .show(ctx, content);
        
        Ok(())
    }
}