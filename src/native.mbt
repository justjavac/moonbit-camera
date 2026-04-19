///|
/// Enumerate camera names with the native platform API.
extern "C" fn native_camera_listing_bytes() -> Bytes = "moonbit_camera_devices"

///|
/// Decode a null-terminated native UTF-8 listing.
fn decode_native_camera_listing(bytes : Bytes) -> String {
  let length = bytes.length()
  let end = if length > 0 && bytes[length - 1] == 0x00 {
    length - 1
  } else {
    length
  }
  @utf8.decode_lossy(bytes[0:end])
}

///|
/// Decode native camera names as newline-separated text.
fn native_camera_listing() -> String {
  decode_native_camera_listing(native_camera_listing_bytes())
}
