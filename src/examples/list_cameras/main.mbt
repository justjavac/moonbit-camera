///|
fn main {
  let devices = @camera.CameraDevice::list()
  if devices.length() == 0 {
    println("No cameras found.")
  } else {
    for device in devices {
      let mode = device.mode.normalize()
      println(
        "\{device.label()} \{mode.width}x\{mode.height}@\{mode.fps} \{mode.pixel_format.name()}",
      )
    }
  }
}
