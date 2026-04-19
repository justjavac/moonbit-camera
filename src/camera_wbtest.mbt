///|
test "show implementations use stable debug text" {
  inspect(Front, content="Front")
  inspect(Nv12, content="Nv12")
  inspect(
    CameraDevice::{
      id: "cam",
      name: "Built-in Camera",
      facing: Front,
      mode: { width: 1280, height: 720, fps: 30, pixel_format: Mjpeg },
      torch: false,
    },
    content=(
      #|{
      #|  id: "cam",
      #|  name: "Built-in Camera",
      #|  facing: Front,
      #|  mode: { width: 1280, height: 720, fps: 30, pixel_format: Mjpeg },
      #|  torch: false,
      #|}
    ),
  )
}

///|
test "native api listing does not raise" {
  ignore(native_camera_listing())
}

///|
test "native api listing decodes c strings" {
  inspect(
    decode_native_camera_listing(b"Front Camera\nUSB Camera\n\x00"),
    content="Front Camera\nUSB Camera\n",
  )
}

///|
test "native api listing tolerates missing c string terminator" {
  inspect(decode_native_camera_listing(b"Front Camera"), content="Front Camera")
}

///|
test "current platform camera discovery does not raise" {
  ignore(CameraDevice::list())
}
