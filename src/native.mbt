///|
/// Enumerate camera names with the native platform API.
extern "C" fn native_camera_listing_bytes() -> Bytes = "moonbit_camera_devices"

///|
/// Decode native camera names as newline-separated text.
fn native_camera_listing() -> String {
  @ffi.from_cstr(native_camera_listing_bytes())
}
