use egui::{Context, Vec2, Pos2, Rect, Color32};
use crate::Result;

/// High-level UI helper functions that work with the egui context
pub struct EguiUI;

impl EguiUI {
    /// Create a simple button and return whether it was clicked
    pub fn button(ctx: &mut Context, text: &str, pos: Pos2, size: Vec2) -> Result<bool> {
        let mut clicked = false;
        
        egui::CentralPanel::default().show(ctx, |ui| {
            // Create a button at the specified position
            let button_rect = Rect::from_min_size(pos, size);
            
            let response = ui.allocate_rect(button_rect, egui::Sense::click());
            
            // Draw button background
            let bg_color = if response.hovered() {
                Color32::from_rgb(70, 70, 80)
            } else {
                Color32::from_rgb(50, 50, 60)
            };
            
            ui.painter().rect_filled(button_rect, 4.0, bg_color);
            
            // Draw button border
            ui.painter().rect_stroke(
                button_rect,
                4.0,
                egui::Stroke::new(1.0, Color32::from_rgb(100, 100, 110)),
            );
            
            // Draw button text centered
            let font_id = egui::FontId::default();
            let text_size = ui.painter().layout_no_wrap(
                text.to_string(),
                font_id.clone(),
                Color32::WHITE,
            ).size();
            
            let text_pos = button_rect.center() - Vec2::new(text_size.x / 2.0, text_size.y / 2.0);
            
            ui.painter().text(
                text_pos,
                egui::Align2::LEFT_TOP,
                text,
                font_id,
                Color32::WHITE,
            );
            
            if response.clicked() {
                clicked = true;
            }
        });
        
        Ok(clicked)
    }
    
    /// Display text at a specific position
    pub fn text(ctx: &mut Context, text: &str, pos: Pos2, color: Color32) -> Result<()> {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.painter().text(
                pos,
                egui::Align2::LEFT_TOP,
                text,
                egui::FontId::default(),
                color,
            );
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