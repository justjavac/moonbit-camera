#ifndef MOONBIT_CAMERA_NATIVE_H_INCLUDED
#define MOONBIT_CAMERA_NATIVE_H_INCLUDED

#include <stddef.h>

#include "moonbit.h"

struct camera_buffer {
  char *data;
  size_t length;
  size_t capacity;
};

void camera_append_line(
  struct camera_buffer *buffer,
  const char *line,
  size_t line_len
);

moonbit_bytes_t camera_buffer_to_bytes(struct camera_buffer *buffer);

#if defined(_WIN32) || defined(_WIN64)
void camera_windows_devices(struct camera_buffer *buffer);
#elif defined(__linux__)
void camera_linux_devices(struct camera_buffer *buffer);
#elif defined(__APPLE__) && defined(__MACH__)
void camera_macos_devices(struct camera_buffer *buffer);
#endif

#endif
