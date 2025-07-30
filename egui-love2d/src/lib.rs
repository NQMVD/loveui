use std::sync::Arc;
use parking_lot::RwLock;
use once_cell::sync::Lazy;

mod backend;
mod context;
mod ffi;
mod input;
mod renderer;
mod errors;
mod ui;

pub use backend::Love2DBackend;
pub use context::EguiContext;
pub use errors::{EguiLove2DError, Result};
pub use ui::EguiUI;

// Global context for the egui integration
static GLOBAL_CONTEXT: Lazy<Arc<RwLock<Option<EguiContext>>>> = 
    Lazy::new(|| Arc::new(RwLock::new(None)));

/// Initialize the egui-Love2D bridge
pub fn initialize(screen_width: f32, screen_height: f32) -> Result<()> {
    let context = EguiContext::new(screen_width, screen_height)?;
    let mut global = GLOBAL_CONTEXT.write();
    *global = Some(context);
    Ok(())
}

/// Get a reference to the global egui context
pub fn with_context<T, F>(f: F) -> Result<T>
where
    F: FnOnce(&mut EguiContext) -> T,
{
    let mut global = GLOBAL_CONTEXT.write();
    match global.as_mut() {
        Some(context) => Ok(f(context)),
        None => Err(EguiLove2DError::NotInitialized),
    }
}

/// Shutdown the egui-Love2D bridge
pub fn shutdown() {
    let mut global = GLOBAL_CONTEXT.write();
    *global = None;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_initialization() {
        assert!(initialize(800.0, 600.0).is_ok());
        assert!(with_context(|_| ()).is_ok());
        shutdown();
    }
}