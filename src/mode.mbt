///|
/// Clamp a numeric field to the smallest valid camera value.
fn min_one(value : Int) -> Int {
  if value < 1 {
    1
  } else {
    value
  }
}

///|
/// Normalize a camera capture mode into a safe baseline.
///
/// Width, height, and frames per second are clamped to at least `1`, while the
/// pixel format is preserved. This keeps downstream frame timing and layout
/// calculations from dividing by zero or producing negative sizes.
///
/// # Example
/// ```mbt check
/// test {
///   let mode = @camera.CaptureMode::{
///     width: 0,
///     height: -720,
///     fps: 0,
///     pixel_format: @camera.PixelFormat::Nv12,
///   }.normalize()
///   inspect(mode.width, content="1")
///   inspect(mode.height, content="1")
///   inspect(mode.fps, content="1")
/// }
/// ```
pub fn CaptureMode::normalize(self : CaptureMode) -> CaptureMode {
  {
    width: min_one(self.width),
    height: min_one(self.height),
    fps: min_one(self.fps),
    pixel_format: self.pixel_format,
  }
}

///|
/// Return the capture interval in milliseconds for one frame.
///
/// The mode is normalized before the calculation, so an invalid `fps` value is
/// treated as `1`. The result uses integer milliseconds because native preview
/// schedulers usually accept whole millisecond delays.
///
/// # Example
/// ```mbt check
/// test {
///   let mode = @camera.CaptureMode::{
///     width: 1280,
///     height: 720,
///     fps: 25,
///     pixel_format: @camera.PixelFormat::Mjpeg,
///   }
///   inspect(mode.frame_interval_ms(), content="40")
/// }
/// ```
pub fn CaptureMode::frame_interval_ms(self : CaptureMode) -> Int {
  1_000 / self.normalize().fps
}

///|
/// Return the stable label for camera placement.
///
/// The label is lowercase and intended for UI copy, logs, and serialized
/// metadata where the enum constructor name would be too MoonBit-specific.
/// Values are stable across releases unless the enum itself changes.
///
/// # Example
/// ```mbt check
/// test {
///   inspect(@camera.Facing::Back.name(), content="back")
/// }
/// ```
pub fn Facing::name(self : Facing) -> String {
  match self {
    Front => "front"
    Back => "back"
    External => "external"
  }
}

///|
/// Return the stable label for a pixel format.
///
/// The label is lowercase and mirrors common native camera terminology such as
/// `mjpeg`, `yuy2`, and `nv12`. Use it when printing modes or exposing device
/// metadata to configuration files.
///
/// # Example
/// ```mbt check
/// test {
///   inspect(@camera.PixelFormat::Nv12.name(), content="nv12")
/// }
/// ```
pub fn PixelFormat::name(self : PixelFormat) -> String {
  match self {
    Mjpeg => "mjpeg"
    Yuy2 => "yuy2"
    Nv12 => "nv12"
    Rgba => "rgba"
  }
}

///|
/// Whether the device default mode should be treated as HD.
///
/// This checks the normalized default mode and returns `true` for devices whose
/// default capture dimensions are at least `1280x720`.
///
/// # Example
/// ```mbt check
/// test {
///   let device = @camera.CameraDevice::{
///     id: "camera-0",
///     name: "HD Camera",
///     facing: @camera.Facing::External,
///     mode: @camera.CaptureMode::{
///       width: 1280,
///       height: 720,
///       fps: 30,
///       pixel_format: @camera.PixelFormat::Mjpeg,
///     },
///     torch: false,
///   }
///   inspect(device.is_high_definition(), content="true")
/// }
/// ```
pub fn CameraDevice::is_high_definition(self : CameraDevice) -> Bool {
  let mode = self.mode.normalize()
  mode.width >= 1_280 && mode.height >= 720
}

///|
/// Whether the default mode is suitable for low-latency preview.
///
/// A device is considered low-latency friendly when its normalized default mode
/// runs at `60` frames per second or above.
///
/// # Example
/// ```mbt check
/// test {
///   let device = @camera.CameraDevice::{
///     id: "camera-0",
///     name: "Fast Camera",
///     facing: @camera.Facing::External,
///     mode: @camera.CaptureMode::{
///       width: 640,
///       height: 480,
///       fps: 60,
///       pixel_format: @camera.PixelFormat::Yuy2,
///     },
///     torch: false,
///   }
///   inspect(device.supports_low_latency_preview(), content="true")
/// }
/// ```
pub fn CameraDevice::supports_low_latency_preview(self : CameraDevice) -> Bool {
  self.mode.normalize().fps >= 60
}

///|
/// Produce a concise device label for camera pickers.
///
/// The label uses `facing:name` so UI code can display predictable values while
/// still preserving the native device name exactly as reported.
///
/// # Example
/// ```mbt check
/// test {
///   let device = @camera.CameraDevice::{
///     id: "camera-0",
///     name: "USB Camera",
///     facing: @camera.Facing::External,
///     mode: @camera.CaptureMode::{
///       width: 1280,
///       height: 720,
///       fps: 30,
///       pixel_format: @camera.PixelFormat::Mjpeg,
///     },
///     torch: false,
///   }
///   inspect(device.label(), content="external:USB Camera")
/// }
/// ```
pub fn CameraDevice::label(self : CameraDevice) -> String {
  "\{self.facing.name()}:\{self.name}"
}
