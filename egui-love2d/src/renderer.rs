use crate::{backend::DrawCommand, Result};

/// Renderer that converts egui draw commands to strings that can be executed by Love2D
pub struct Love2DRenderer {
    lua_commands: Vec<String>,
}

impl Love2DRenderer {
    pub fn new() -> Self {
        Self {
            lua_commands: Vec::new(),
        }
    }
    
    /// Convert draw commands to Love2D Lua drawing calls
    pub fn render(&mut self, commands: &[DrawCommand]) -> Result<Vec<String>> {
        self.lua_commands.clear();
        
        for command in commands {
            self.process_command(command)?;
        }
        
        Ok(self.lua_commands.clone())
    }
    
    fn process_command(&mut self, command: &DrawCommand) -> Result<()> {
        match command {
            DrawCommand::Rect { rect, fill, stroke } => {
                self.render_rect(rect, fill, stroke)?;
            },
            DrawCommand::Text { pos, text, color, font_size } => {
                self.render_text(pos, text, color, *font_size)?;
            },
            DrawCommand::Image { rect, texture_id, uv, tint } => {
                self.render_image(rect, *texture_id, uv, tint)?;
            },
            DrawCommand::ClippedPrimitive { clip_rect, primitive } => {
                self.render_clipped(clip_rect, primitive)?;
            },
        }
        Ok(())
    }
    
    fn render_rect(&mut self, rect: &egui::Rect, fill: &egui::Color32, stroke: &egui::Stroke) -> Result<()> {
        // Set fill color
        if fill.a() > 0 {
            let r = fill.r() as f32 / 255.0;
            let g = fill.g() as f32 / 255.0;
            let b = fill.b() as f32 / 255.0;
            let a = fill.a() as f32 / 255.0;
            
            self.lua_commands.push(format!(
                "love.graphics.setColor({}, {}, {}, {})",
                r, g, b, a
            ));
            
            self.lua_commands.push(format!(
                "love.graphics.rectangle('fill', {}, {}, {}, {})",
                rect.min.x, rect.min.y, rect.width(), rect.height()
            ));
        }
        
        // Set stroke
        if stroke.width > 0.0 && stroke.color.a() > 0 {
            let r = stroke.color.r() as f32 / 255.0;
            let g = stroke.color.g() as f32 / 255.0;
            let b = stroke.color.b() as f32 / 255.0;
            let a = stroke.color.a() as f32 / 255.0;
            
            self.lua_commands.push(format!(
                "love.graphics.setColor({}, {}, {}, {})",
                r, g, b, a
            ));
            
            self.lua_commands.push(format!(
                "love.graphics.setLineWidth({})",
                stroke.width
            ));
            
            self.lua_commands.push(format!(
                "love.graphics.rectangle('line', {}, {}, {}, {})",
                rect.min.x, rect.min.y, rect.width(), rect.height()
            ));
        }
        
        Ok(())
    }
    
    fn render_text(&mut self, pos: &egui::Pos2, text: &str, color: &egui::Color32, _font_size: f32) -> Result<()> {
        let r = color.r() as f32 / 255.0;
        let g = color.g() as f32 / 255.0;
        let b = color.b() as f32 / 255.0;
        let a = color.a() as f32 / 255.0;
        
        self.lua_commands.push(format!(
            "love.graphics.setColor({}, {}, {}, {})",
            r, g, b, a
        ));
        
        // Escape quotes in text
        let escaped_text = text.replace('"', r#"\""#);
        
        self.lua_commands.push(format!(
            "love.graphics.print(\"{}\", {}, {})",
            escaped_text, pos.x, pos.y
        ));
        
        Ok(())
    }
    
    fn render_image(&mut self, rect: &egui::Rect, _texture_id: egui::TextureId, uv: &egui::Rect, tint: &egui::Color32) -> Result<()> {
        let r = tint.r() as f32 / 255.0;
        let g = tint.g() as f32 / 255.0;
        let b = tint.b() as f32 / 255.0;
        let a = tint.a() as f32 / 255.0;
        
        self.lua_commands.push(format!(
            "love.graphics.setColor({}, {}, {}, {})",
            r, g, b, a
        ));
        
        // For now, we'll use a placeholder for texture rendering
        // In a real implementation, you'd need to manage texture IDs
        self.lua_commands.push(format!(
            "-- TODO: Draw texture at rect({}, {}, {}, {}) with uv({}, {}, {}, {})",
            rect.min.x, rect.min.y, rect.width(), rect.height(),
            uv.min.x, uv.min.y, uv.width(), uv.height()
        ));
        
        Ok(())
    }
    
    fn render_clipped(&mut self, clip_rect: &egui::Rect, primitive: &DrawCommand) -> Result<()> {
        // Set scissor/stencil test for clipping
        self.lua_commands.push(format!(
            "love.graphics.setScissor({}, {}, {}, {})",
            clip_rect.min.x, clip_rect.min.y, clip_rect.width(), clip_rect.height()
        ));
        
        // Render the primitive
        self.process_command(primitive)?;
        
        // Reset scissor
        self.lua_commands.push("love.graphics.setScissor()".to_string());
        
        Ok(())
    }
}

impl Default for Love2DRenderer {
    fn default() -> Self {
        Self::new()
    }
}