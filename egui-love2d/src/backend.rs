use egui::FullOutput;
use crate::Result;
use std::collections::HashMap;

/// Custom backend for integrating egui with Love2D
pub struct Love2DBackend {
    screen_width: f32,
    screen_height: f32,
    
    // Rendering state
    draw_commands: Vec<DrawCommand>,
    textures: HashMap<egui::TextureId, TextureInfo>,
    
    // Cursor state
    cursor_icon: egui::CursorIcon,
}

#[derive(Debug, Clone)]
pub enum DrawCommand {
    Rect {
        rect: egui::Rect,
        fill: egui::Color32,
        stroke: egui::Stroke,
    },
    Text {
        pos: egui::Pos2,
        text: String,
        color: egui::Color32,
        font_size: f32,
    },
    Image {
        rect: egui::Rect,
        texture_id: egui::TextureId,
        uv: egui::Rect,
        tint: egui::Color32,
    },
    ClippedPrimitive {
        clip_rect: egui::Rect,
        primitive: Box<DrawCommand>,
    },
}

#[derive(Debug, Clone)]
pub struct TextureInfo {
    pub width: u32,
    pub height: u32,
    pub pixels: Vec<u8>,
    pub format: TextureFormat,
}

#[derive(Debug, Clone, Copy)]
pub enum TextureFormat {
    Rgba8,
    Alpha8,
}

impl Love2DBackend {
    pub fn new(screen_width: f32, screen_height: f32) -> Result<Self> {
        Ok(Self {
            screen_width,
            screen_height,
            draw_commands: Vec::new(),
            textures: HashMap::new(),
            cursor_icon: egui::CursorIcon::Default,
        })
    }
    
    pub fn handle_output(&mut self, output: &FullOutput) -> Result<()> {
        // Handle platform output
        if !output.platform_output.copied_text.is_empty() {
            // TODO: Set clipboard text via Love2D
        }
        
        // Update cursor
        self.cursor_icon = output.platform_output.cursor_icon;
        
        // Handle texture allocations/updates
        for (texture_id, image_delta) in &output.textures_delta.set {
            self.update_texture(*texture_id, image_delta)?;
        }
        
        // Handle texture deallocations
        for texture_id in &output.textures_delta.free {
            self.textures.remove(texture_id);
        }
        
        // Convert paint jobs to draw commands
        self.draw_commands.clear();
        for clipped_shape in &output.shapes {
            self.process_clipped_shape(clipped_shape)?;
        }
        
        Ok(())
    }
    
    fn update_texture(&mut self, texture_id: egui::TextureId, image_delta: &egui::epaint::ImageDelta) -> Result<()> {
        let image = &image_delta.image;
        
        let (format, pixels) = match image {
            egui::ImageData::Color(color_image) => {
                let pixels = color_image.pixels.iter()
                    .flat_map(|color| [color.r(), color.g(), color.b(), color.a()])
                    .collect();
                (TextureFormat::Rgba8, pixels)
            },
            egui::ImageData::Font(font_image) => {
                let pixels = font_image.pixels.iter()
                    .flat_map(|alpha| [255, 255, 255, (*alpha * 255.0) as u8])
                    .collect();
                (TextureFormat::Rgba8, pixels)
            },
        };
        
        let texture_info = TextureInfo {
            width: image.width() as u32,
            height: image.height() as u32,
            pixels,
            format,
        };
        
        self.textures.insert(texture_id, texture_info);
        Ok(())
    }
    
    fn process_clipped_shape(&mut self, clipped_shape: &egui::epaint::ClippedShape) -> Result<()> {
        let clip_rect = clipped_shape.clip_rect;
        
        match &clipped_shape.shape {
            egui::Shape::Mesh(mesh) => {
                self.process_mesh(mesh, clip_rect)?;
            },
            _ => {
                // Handle other shape types as needed
            }
        }
        
        Ok(())
    }
    
    fn process_mesh(&mut self, mesh: &egui::Mesh, clip_rect: egui::Rect) -> Result<()> {
        // Process mesh triangles and convert to Love2D compatible draw commands
        for triangle in mesh.indices.chunks_exact(3) {
            let v0 = &mesh.vertices[triangle[0] as usize];
            let v1 = &mesh.vertices[triangle[1] as usize];
            let v2 = &mesh.vertices[triangle[2] as usize];
            
            // For simplicity, convert triangles to rectangles when possible
            // In a full implementation, you'd render actual triangles
            let min_x = v0.pos.x.min(v1.pos.x).min(v2.pos.x);
            let max_x = v0.pos.x.max(v1.pos.x).max(v2.pos.x);
            let min_y = v0.pos.y.min(v1.pos.y).min(v2.pos.y);
            let max_y = v0.pos.y.max(v1.pos.y).max(v2.pos.y);
            
            let rect = egui::Rect::from_min_max(
                egui::Pos2::new(min_x, min_y),
                egui::Pos2::new(max_x, max_y),
            );
            
            let command = if mesh.texture_id == egui::TextureId::default() {
                // Solid color primitive
                DrawCommand::Rect {
                    rect,
                    fill: v0.color,
                    stroke: egui::Stroke::NONE,
                }
            } else {
                // Textured primitive
                DrawCommand::Image {
                    rect,
                    texture_id: mesh.texture_id,
                    uv: egui::Rect::from_min_max(v0.uv, v2.uv),
                    tint: v0.color,
                }
            };
            
            if clip_rect != egui::Rect::EVERYTHING {
                self.draw_commands.push(DrawCommand::ClippedPrimitive {
                    clip_rect,
                    primitive: Box::new(command),
                });
            } else {
                self.draw_commands.push(command);
            }
        }
        
        Ok(())
    }
    
    pub fn resize(&mut self, width: f32, height: f32) -> Result<()> {
        self.screen_width = width;
        self.screen_height = height;
        Ok(())
    }
    
    pub fn get_draw_commands(&self) -> &[DrawCommand] {
        &self.draw_commands
    }
    
    pub fn get_texture(&self, texture_id: egui::TextureId) -> Option<&TextureInfo> {
        self.textures.get(&texture_id)
    }
    
    pub fn get_cursor_icon(&self) -> egui::CursorIcon {
        self.cursor_icon
    }
    
    pub fn screen_size(&self) -> (f32, f32) {
        (self.screen_width, self.screen_height)
    }
}