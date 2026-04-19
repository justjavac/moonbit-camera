# justjavac/camera

[![CI](https://github.com/justjavac/moonbit-camera/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/justjavac/moonbit-camera/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/codecov/c/github/justjavac/moonbit-camera/main?label=coverage)](https://codecov.io/gh/justjavac/moonbit-camera)
[![linux](https://img.shields.io/codecov/c/github/justjavac/moonbit-camera/main?flag=linux&label=linux)](https://codecov.io/gh/justjavac/moonbit-camera)
[![macos](https://img.shields.io/codecov/c/github/justjavac/moonbit-camera/main?flag=macos&label=macos)](https://codecov.io/gh/justjavac/moonbit-camera)
[![windows](https://img.shields.io/codecov/c/github/justjavac/moonbit-camera/main?flag=windows&label=windows)](https://codecov.io/gh/justjavac/moonbit-camera)

Native-only camera discovery helpers for MoonBit.

```mbt nocheck
fn main {
  for device in @camera.CameraDevice::list() {
    println(device.label())
  }
}
```

Run examples with `--target native`:

```bash
moon run src/examples/list_cameras --target native
moon run src/examples/parse_listing --target native
```
