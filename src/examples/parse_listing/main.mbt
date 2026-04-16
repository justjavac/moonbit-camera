///|
fn main {
  let sample = "Front Camera\nUSB Capture Card\nRear Camera\n"
  for device in @camera.CameraDevice::parse_listing(sample) {
    println("\{device.id}: \{device.label()}")
  }
}
