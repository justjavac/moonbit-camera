# moonbit_native/camera

[![CI](https://github.com/moonbit-native/moonbit-camera/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/moonbit-native/moonbit-camera/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/codecov/c/github/moonbit-native/moonbit-camera/main?label=coverage)](https://codecov.io/gh/moonbit-native/moonbit-camera)
[![linux](https://img.shields.io/codecov/c/github/moonbit-native/moonbit-camera/main?flag=linux&label=linux)](https://codecov.io/gh/moonbit-native/moonbit-camera)
[![macos](https://img.shields.io/codecov/c/github/moonbit-native/moonbit-camera/main?flag=macos&label=macos)](https://codecov.io/gh/moonbit-native/moonbit-camera)
[![windows](https://img.shields.io/codecov/c/github/moonbit-native/moonbit-camera/main?flag=windows&label=windows)](https://codecov.io/gh/moonbit-native/moonbit-camera)

`moonbit_native/camera` is a native-only MoonBit package for camera discovery and
small capture-mode helpers. It gives applications a portable first pass over
available camera devices before they open a platform-specific capture session.

## What It Does

- Enumerates camera devices through platform APIs, not shell scripts.
- Builds portable `CameraDevice` descriptors from native display names.
- Infers a best-effort facing hint from common camera names.
- Provides stable labels for UI pickers, logs, and snapshots.
- Normalizes capture modes before arithmetic such as frame timing.
- Ships runnable examples for real discovery and deterministic parsing.

## Platform Backends

The native backend uses one small C entry point and a platform-specific
implementation file for each operating system.

| System | Native API path | Notes |
| --- | --- | --- |
| Windows | SetupAPI device classes | `setupapi.dll` is loaded dynamically with `LoadLibraryA`; there is no static `setupapi.lib` link requirement. |
| Linux | V4L2 plus sysfs | `/dev/video*` entries are validated with `VIDIOC_QUERYCAP`; sysfs names are preferred when available. |
| macOS | AVFoundation | AVFoundation is accessed through the Objective-C runtime with `dlopen` and `dlsym`. |

## Install

```bash
moon add moonbit_native/camera
```

The package is native-only. Use `--target native` when checking, testing, or
running examples.

## Quick Start

```moonbit
fn main {
  for device in @camera.CameraDevice::list() {
    let mode = device.mode.normalize()
    println(
      "\{device.label()} \{mode.width}x\{mode.height}@\{mode.fps}",
    )
  }
}
```

Run the live discovery example:

```bash
moon run src/examples/list_cameras --target native
```

Run the deterministic parsing example:

```bash
moon run src/examples/parse_listing --target native
```

## Examples

`src/examples/list_cameras` performs real native discovery and prints one line
per device:

```bash
moon run src/examples/list_cameras --target native
```

Example output:

```text
external:Integrated Camera 1280x720@30 mjpeg
```

`src/examples/parse_listing` parses a fixed sample listing. It is useful when
you want to understand the portable descriptor shape without relying on local
hardware:

```bash
moon run src/examples/parse_listing --target native
```

Example output:

```text
camera-0: front:Front Camera
camera-1: external:USB Capture Card
camera-2: back:Rear Camera
```

## License

MIT. See `LICENSE`.
