#include <string.h>

#include "camera_native.h"

MOONBIT_FFI_EXPORT moonbit_bytes_t moonbit_camera_devices(void) {
  struct camera_buffer buffer;
  memset(&buffer, 0, sizeof(buffer));

#if defined(_WIN32) || defined(_WIN64)
  camera_windows_devices(&buffer);
#elif defined(__linux__)
  camera_linux_devices(&buffer);
#elif defined(__APPLE__) && defined(__MACH__)
  camera_macos_devices(&buffer);
#endif

  return camera_buffer_to_bytes(&buffer);
}
