#include <stdlib.h>
#include <string.h>

#include "camera_native.h"

static int camera_buffer_reserve(struct camera_buffer *buffer, size_t extra) {
  size_t required = buffer->length + extra;
  if (required <= buffer->capacity) {
    return 1;
  }

  size_t next_capacity = buffer->capacity == 0 ? 256 : buffer->capacity * 2;
  while (next_capacity < required) {
    next_capacity *= 2;
  }

  char *next = (char *)realloc(buffer->data, next_capacity);
  if (next == NULL) {
    return 0;
  }
  buffer->data = next;
  buffer->capacity = next_capacity;
  return 1;
}

static int camera_buffer_contains_line(
  const struct camera_buffer *buffer,
  const char *line,
  size_t line_len
) {
  size_t start = 0;
  while (start < buffer->length) {
    size_t end = start;
    while (end < buffer->length && buffer->data[end] != '\n') {
      end++;
    }
    if (end - start == line_len &&
        memcmp(buffer->data + start, line, line_len) == 0) {
      return 1;
    }
    start = end + 1;
  }
  return 0;
}

void camera_append_line(
  struct camera_buffer *buffer,
  const char *line,
  size_t line_len
) {
  while (line_len > 0 &&
         (line[0] == ' ' || line[0] == '\t' || line[0] == '\r' ||
          line[0] == '\n')) {
    line++;
    line_len--;
  }
  while (line_len > 0 &&
         (line[line_len - 1] == ' ' || line[line_len - 1] == '\t' ||
          line[line_len - 1] == '\r' || line[line_len - 1] == '\n')) {
    line_len--;
  }
  if (line_len == 0 || camera_buffer_contains_line(buffer, line, line_len)) {
    return;
  }
  if (!camera_buffer_reserve(buffer, line_len + 1)) {
    return;
  }
  memcpy(buffer->data + buffer->length, line, line_len);
  buffer->length += line_len;
  buffer->data[buffer->length++] = '\n';
}

moonbit_bytes_t camera_buffer_to_bytes(struct camera_buffer *buffer) {
  moonbit_bytes_t bytes = moonbit_make_bytes_raw((int32_t)buffer->length + 1);
  if (buffer->length > 0) {
    memcpy(bytes, buffer->data, buffer->length);
  }
  bytes[buffer->length] = '\0';
  free(buffer->data);
  return bytes;
}
