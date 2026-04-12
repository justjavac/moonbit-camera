///|
/// Camera lens placement as reported or inferred from the native device name.
///
/// Native discovery APIs do not always expose a normalized facing field, so the
/// package infers this value from common device names when necessary. Use it as
/// a UI hint rather than as a hardware guarantee.
pub(all) enum Facing {
  Front
  Back
  External
} derive(Debug, Eq)

///|
/// Pixel formats commonly reported by native camera stacks and preview APIs.
///
/// Discovery currently returns a conservative default format because platform
/// APIs often separate device enumeration from stream negotiation. Applications
/// that open a capture session can replace this with the negotiated format.
pub(all) enum PixelFormat {
  Mjpeg
  Yuy2
  Nv12
  Rgba
} derive(Debug, Eq)

///|
/// A concrete camera capture mode with dimensions, frame rate, and pixel format.
///
/// The values are intended to describe a usable preview or capture stream. Use
/// `CaptureMode::normalize` before performing arithmetic with user-provided or
/// native data, because platform APIs can report incomplete mode information.
pub(all) struct CaptureMode {
  width : Int
  height : Int
  fps : Int
  pixel_format : PixelFormat
} derive(Debug, Eq)

///|
/// A camera device descriptor returned by the native discovery helpers.
///
/// The descriptor is intentionally small and portable: `id` is stable within one
/// parsed listing, `name` preserves the native display name, `facing` is a best
/// effort hint, `mode` is the known or default capture mode, and `torch` reports
/// whether torch-style illumination is expected to be available.
pub(all) struct CameraDevice {
  id : String
  name : String
  facing : Facing
  mode : CaptureMode
  torch : Bool
} derive(Debug, Eq)

///|
/// Writes a Debug representation through the Show logger.
fn[T : Debug] write_debug_show(value : T, logger : &Logger) -> Unit {
  logger.write_string(value.to_repr().to_string())
}

///|
/// Formats a facing value for logs and snapshots.
///
/// The output intentionally matches the enum constructor name. This keeps test
/// snapshots compact while preserving enough detail to distinguish front,
/// back, and external devices during debugging.
pub impl Show for Facing with output(self, logger : &Logger) -> Unit {
  write_debug_show(self, logger)
}

///|
/// Formats a pixel format value for logs and snapshots.
///
/// The output is the MoonBit constructor name, which is useful for developer
/// diagnostics. Use `PixelFormat::name` when a lowercase user-facing or
/// serialized label is needed.
pub impl Show for PixelFormat with output(self, logger : &Logger) -> Unit {
  write_debug_show(self, logger)
}

///|
/// Formats a capture mode for logs and snapshots.
///
/// The representation includes every field so tests can snapshot the complete
/// negotiated or default mode. For UI labels, prefer composing the individual
/// fields with `PixelFormat::name`.
pub impl Show for CaptureMode with output(self, logger : &Logger) -> Unit {
  write_debug_show(self, logger)
}

///|
/// Formats a camera device for logs and snapshots.
///
/// The representation includes id, native name, facing hint, mode, and torch
/// metadata. It is intended for diagnostics and snapshot tests rather than
/// compact UI copy.
pub impl Show for CameraDevice with output(self, logger : &Logger) -> Unit {
  write_debug_show(self, logger)
}
