///|
test "capture modes are normalized" {
  let mode = @camera.CaptureMode::{
    width: 0,
    height: -10,
    fps: 0,
    pixel_format: Nv12,
  }.normalize()
  inspect(mode.width, content="1")
  inspect(mode.frame_interval_ms(), content="1000")
}

///|
test "format names are stable" {
  inspect(@camera.PixelFormat::Mjpeg.name(), content="mjpeg")
  inspect(@camera.PixelFormat::Yuy2.name(), content="yuy2")
  inspect(@camera.PixelFormat::Nv12.name(), content="nv12")
  inspect(@camera.PixelFormat::Rgba.name(), content="rgba")
}

///|
test "hd and low latency checks stay explicit" {
  let device = @camera.CameraDevice::{
    id: "cam-1",
    name: "FaceTime HD",
    facing: Front,
    mode: { width: 1_920, height: 1_080, fps: 60, pixel_format: Mjpeg },
    torch: false,
  }
  inspect(device.is_high_definition(), content="true")
  inspect(device.supports_low_latency_preview(), content="true")
}

///|
test "camera labels are stable" {
  let device = @camera.CameraDevice::{
    id: "cam-2",
    name: "USB Camera",
    facing: External,
    mode: { width: 640, height: 480, fps: 30, pixel_format: Yuy2 },
    torch: true,
  }
  inspect(device.label(), content="external:USB Camera")
  inspect(
    device,
    content=(
      #|{
      #|  id: "cam-2",
      #|  name: "USB Camera",
      #|  facing: External,
      #|  mode: { width: 640, height: 480, fps: 30, pixel_format: Yuy2 },
      #|  torch: true,
      #|}
    ),
  )
}

///|
test "native camera listings parse into devices" {
  let devices = @camera.CameraDevice::parse_listing(
    "\nFront Camera\nUSB Camera\nRear Camera\n",
  )
  inspect(devices.length(), content="3")
  inspect(devices[0].id, content="camera-0")
  inspect(devices[0].label(), content="front:Front Camera")
  inspect(devices[1].label(), content="external:USB Camera")
  inspect(devices[2].label(), content="back:Rear Camera")
  inspect(
    devices[0].mode,
    content="{ width: 1280, height: 720, fps: 30, pixel_format: Mjpeg }",
  )
}
