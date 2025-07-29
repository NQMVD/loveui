use thiserror::Error;

#[derive(Error, Debug)]
pub enum EguiLove2DError {
    #[error("Egui-Love2D bridge not initialized")]
    NotInitialized,
    
    #[error("Invalid parameter: {0}")]
    InvalidParameter(String),
    
    #[error("Rendering error: {0}")]
    RenderingError(String),
    
    #[error("Input error: {0}")]
    InputError(String),
    
    #[error("Lua error: {0}")]
    LuaError(#[from] mlua::Error),
    
    #[error("Memory error: {0}")]
    MemoryError(String),
}

pub type Result<T> = std::result::Result<T, EguiLove2DError>;