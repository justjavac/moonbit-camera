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
test "current platform camera discovery does not raise" {
  ignore(CameraDevice::list())
}
