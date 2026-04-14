#if defined(__APPLE__) && defined(__MACH__)

#include <dlfcn.h>
#include <stdint.h>
#include <string.h>

#include "camera_native.h"

typedef void *camera_id;
typedef void *camera_sel;
typedef camera_id (*camera_objc_get_class)(const char *);
typedef camera_sel (*camera_sel_register_name)(const char *);
typedef void *(*camera_objc_autorelease_pool_push)(void);
typedef void (*camera_objc_autorelease_pool_pop)(void *);

void camera_macos_devices(struct camera_buffer *buffer) {
  void *objc = dlopen("/usr/lib/libobjc.A.dylib", RTLD_LAZY | RTLD_LOCAL);
  void *av = dlopen(
    "/System/Library/Frameworks/AVFoundation.framework/AVFoundation",
    RTLD_LAZY | RTLD_LOCAL
  );
  if (objc == NULL || av == NULL) {
    if (objc != NULL) {
      dlclose(objc);
    }
    if (av != NULL) {
      dlclose(av);
    }
    return;
  }

  camera_objc_get_class objc_get_class =
    (camera_objc_get_class)dlsym(objc, "objc_getClass");
  camera_sel_register_name sel_register_name =
    (camera_sel_register_name)dlsym(objc, "sel_registerName");
  void *objc_msg_send = dlsym(objc, "objc_msgSend");
  camera_objc_autorelease_pool_push pool_push =
    (camera_objc_autorelease_pool_push)dlsym(objc, "objc_autoreleasePoolPush");
  camera_objc_autorelease_pool_pop pool_pop =
    (camera_objc_autorelease_pool_pop)dlsym(objc, "objc_autoreleasePoolPop");
  camera_id *media_type_video = (camera_id *)dlsym(av, "AVMediaTypeVideo");

  if (objc_get_class == NULL || sel_register_name == NULL ||
      objc_msg_send == NULL || media_type_video == NULL) {
    dlclose(av);
    dlclose(objc);
    return;
  }

  void *pool = pool_push == NULL ? NULL : pool_push();
  camera_id capture_device = objc_get_class("AVCaptureDevice");
  camera_sel devices_with_media_type = sel_register_name("devicesWithMediaType:");
  camera_sel count_sel = sel_register_name("count");
  camera_sel object_at_index = sel_register_name("objectAtIndex:");
  camera_sel localized_name = sel_register_name("localizedName");
  camera_sel utf8_string = sel_register_name("UTF8String");

  camera_id (*send_id_id)(camera_id, camera_sel, camera_id) =
    (camera_id(*)(camera_id, camera_sel, camera_id))objc_msg_send;
  uintptr_t (*send_uint)(camera_id, camera_sel) =
    (uintptr_t(*)(camera_id, camera_sel))objc_msg_send;
  camera_id (*send_id_uint)(camera_id, camera_sel, uintptr_t) =
    (camera_id(*)(camera_id, camera_sel, uintptr_t))objc_msg_send;
  camera_id (*send_id)(camera_id, camera_sel) =
    (camera_id(*)(camera_id, camera_sel))objc_msg_send;
  const char *(*send_cstr)(camera_id, camera_sel) =
    (const char *(*)(camera_id, camera_sel))objc_msg_send;

  camera_id devices =
    send_id_id(capture_device, devices_with_media_type, *media_type_video);
  uintptr_t count = devices == NULL ? 0 : send_uint(devices, count_sel);
  for (uintptr_t index = 0; index < count; index++) {
    camera_id device = send_id_uint(devices, object_at_index, index);
    camera_id name = device == NULL ? NULL : send_id(device, localized_name);
    const char *utf8 = name == NULL ? NULL : send_cstr(name, utf8_string);
    if (utf8 != NULL) {
      camera_append_line(buffer, utf8, strlen(utf8));
    }
  }

  if (pool_pop != NULL && pool != NULL) {
    pool_pop(pool);
  }
  dlclose(av);
  dlclose(objc);
}

#endif
