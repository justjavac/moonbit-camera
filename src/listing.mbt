///|
/// Return the default capture mode used when native listings omit mode details.
fn default_mode() -> CaptureMode {
  { width: 1_280, height: 720, fps: 30, pixel_format: Mjpeg }
}

///|
/// Infer a facing value from the native camera display name.
fn infer_facing(name : String) -> Facing {
  let lower = name.to_lower()
  if lower.contains("rear") || lower.contains("back") {
    Back
  } else if lower.contains("front") ||
    lower.contains("facetime") ||
    lower.contains("built-in") {
    Front
  } else {
    External
  }
}

///|
/// Build a stable camera id from its compact discovery index.
fn camera_id(index : Int) -> String {
  "camera-\{index}"
}

///|
/// Parse a native camera listing into camera descriptors.
///
/// Each non-empty line is treated as one camera name. Native platform APIs
/// usually omit capture modes at this discovery stage, so parsed devices
/// receive a conservative `1280x720@30 MJPEG` default mode and `torch=false`.
///
/// # Example
/// ```mbt check
/// test {
///   let devices = @camera.CameraDevice::parse_listing(
///     "Front Camera\nUSB Camera\n",
///   )
///   inspect(devices.length(), content="2")
///   inspect(devices[0].label(), content="front:Front Camera")
///   inspect(devices[1].label(), content="external:USB Camera")
/// }
/// ```
pub fn CameraDevice::parse_listing(output : String) -> Array[CameraDevice] {
  let devices : Array[CameraDevice] = []
  for line in output.split("\n").to_array() {
    let name = line.trim().to_string()
    if name != "" {
      devices.push({
        id: camera_id(devices.length()),
        name,
        facing: infer_facing(name),
        mode: default_mode(),
        torch: false,
      })
    }
  }
  devices
}

///|
/// List camera devices visible to the current native platform.
///
/// Discovery is intentionally lightweight: the backend uses platform APIs to
/// enumerate camera names and turns them into portable descriptors. Applications
/// that need negotiated frame formats can use these descriptors as a first
/// discovery pass before opening a platform-specific capture session.
///
/// # Example
/// ```mbt check
/// test {
///   for device in @camera.CameraDevice::list() {
///     ignore(device.label())
///   }
/// }
/// ```
pub fn CameraDevice::list() -> Array[CameraDevice] {
  CameraDevice::parse_listing(native_camera_listing())
}
