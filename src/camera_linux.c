#if defined(__linux__)

#include <ctype.h>
#include <dirent.h>
#include <fcntl.h>
#include <linux/videodev2.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include "camera_native.h"

static int camera_linux_video_name(const char *name) {
  if (strncmp(name, "video", 5) != 0 || name[5] == '\0') {
    return 0;
  }
  for (size_t index = 5; name[index] != '\0'; index++) {
    if (!isdigit((unsigned char)name[index])) {
      return 0;
    }
  }
  return 1;
}

static int camera_read_first_line(
  const char *path,
  char *buffer,
  size_t buffer_len
) {
  FILE *file = fopen(path, "r");
  if (file == NULL) {
    return 0;
  }
  if (fgets(buffer, (int)buffer_len, file) == NULL) {
    fclose(file);
    return 0;
  }
  fclose(file);
  buffer[buffer_len - 1] = '\0';
  return 1;
}

static size_t camera_strnlen(const char *text, size_t max_len) {
  size_t len = 0;
  while (len < max_len && text[len] != '\0') {
    len++;
  }
  return len;
}

void camera_linux_devices(struct camera_buffer *buffer) {
  DIR *directory = opendir("/dev");
  if (directory == NULL) {
    return;
  }

  struct dirent *entry = NULL;
  while ((entry = readdir(directory)) != NULL) {
    if (!camera_linux_video_name(entry->d_name)) {
      continue;
    }

    char device_path[256];
    snprintf(device_path, sizeof(device_path), "/dev/%s", entry->d_name);
    int fd = open(device_path, O_RDONLY | O_NONBLOCK);
    if (fd < 0) {
      continue;
    }

    struct v4l2_capability capability;
    memset(&capability, 0, sizeof(capability));
    if (ioctl(fd, VIDIOC_QUERYCAP, &capability) == 0) {
      uint32_t caps = capability.capabilities;
#ifdef V4L2_CAP_DEVICE_CAPS
      if ((caps & V4L2_CAP_DEVICE_CAPS) != 0) {
        caps = capability.device_caps;
      }
#endif
      if ((caps & (V4L2_CAP_VIDEO_CAPTURE | V4L2_CAP_VIDEO_CAPTURE_MPLANE)) !=
          0) {
        char sysfs_path[512];
        char name[256];
        snprintf(
          sysfs_path,
          sizeof(sysfs_path),
          "/sys/class/video4linux/%s/name",
          entry->d_name
        );
        if (camera_read_first_line(sysfs_path, name, sizeof(name))) {
          camera_append_line(buffer, name, strlen(name));
        } else {
          camera_append_line(
            buffer,
            (const char *)capability.card,
            camera_strnlen((const char *)capability.card, sizeof(capability.card))
          );
        }
      }
    }
    close(fd);
  }

  closedir(directory);
}

#endif
