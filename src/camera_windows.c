#if defined(_WIN32) || defined(_WIN64)

#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <setupapi.h>

#include "camera_native.h"

typedef HDEVINFO(WINAPI *camera_setup_get_class_devs_w)(
  const GUID *,
  PCWSTR,
  HWND,
  DWORD
);
typedef BOOL(WINAPI *camera_setup_enum_device_info)(
  HDEVINFO,
  DWORD,
  PSP_DEVINFO_DATA
);
typedef BOOL(WINAPI *camera_setup_get_device_registry_property_w)(
  HDEVINFO,
  PSP_DEVINFO_DATA,
  DWORD,
  PDWORD,
  PBYTE,
  DWORD,
  PDWORD
);
typedef BOOL(WINAPI *camera_setup_destroy_device_info_list)(HDEVINFO);

struct camera_setupapi {
  HMODULE library;
  camera_setup_get_class_devs_w get_class_devs_w;
  camera_setup_enum_device_info enum_device_info;
  camera_setup_get_device_registry_property_w get_property_w;
  camera_setup_destroy_device_info_list destroy_device_info_list;
};

static const GUID camera_windows_classes[] = {
  {0xca3e7ab9, 0xb4c3, 0x4ae6, {0x82, 0x51, 0x57, 0x9e, 0xf9, 0x33, 0x89, 0x0f}},
  {0x6bdd1fc6, 0x810f, 0x11d0, {0xbe, 0xc7, 0x08, 0x00, 0x2b, 0xe2, 0x09, 0x2f}},
};

static int camera_load_setupapi(struct camera_setupapi *api) {
  api->library = LoadLibraryA("setupapi.dll");
  if (api->library == NULL) {
    return 0;
  }
  api->get_class_devs_w = (camera_setup_get_class_devs_w)GetProcAddress(
    api->library,
    "SetupDiGetClassDevsW"
  );
  api->enum_device_info = (camera_setup_enum_device_info)GetProcAddress(
    api->library,
    "SetupDiEnumDeviceInfo"
  );
  api->get_property_w = (camera_setup_get_device_registry_property_w)
    GetProcAddress(api->library, "SetupDiGetDeviceRegistryPropertyW");
  api->destroy_device_info_list =
    (camera_setup_destroy_device_info_list)GetProcAddress(
      api->library,
      "SetupDiDestroyDeviceInfoList"
    );
  return api->get_class_devs_w != NULL && api->enum_device_info != NULL &&
         api->get_property_w != NULL && api->destroy_device_info_list != NULL;
}

static void camera_append_windows_name(
  struct camera_buffer *buffer,
  const WCHAR *name
) {
  int length = WideCharToMultiByte(CP_UTF8, 0, name, -1, NULL, 0, NULL, NULL);
  if (length <= 1) {
    return;
  }
  char *utf8 = (char *)malloc((size_t)length);
  if (utf8 == NULL) {
    return;
  }
  WideCharToMultiByte(CP_UTF8, 0, name, -1, utf8, length, NULL, NULL);
  camera_append_line(buffer, utf8, (size_t)length - 1);
  free(utf8);
}

void camera_windows_devices(struct camera_buffer *buffer) {
  struct camera_setupapi api;
  memset(&api, 0, sizeof(api));
  if (!camera_load_setupapi(&api)) {
    if (api.library != NULL) {
      FreeLibrary(api.library);
    }
    return;
  }

  for (size_t class_index = 0;
       class_index <
       sizeof(camera_windows_classes) / sizeof(camera_windows_classes[0]);
       class_index++) {
    HDEVINFO devices = api.get_class_devs_w(
      &camera_windows_classes[class_index],
      NULL,
      NULL,
      DIGCF_PRESENT
    );
    if (devices == INVALID_HANDLE_VALUE) {
      continue;
    }

    for (DWORD index = 0;; index++) {
      SP_DEVINFO_DATA device_info;
      WCHAR name[512];
      DWORD property_type = 0;
      device_info.cbSize = sizeof(device_info);
      if (!api.enum_device_info(devices, index, &device_info)) {
        break;
      }
      if (!api.get_property_w(
            devices,
            &device_info,
            SPDRP_FRIENDLYNAME,
            &property_type,
            (PBYTE)name,
            sizeof(name),
            NULL
          ) &&
          !api.get_property_w(
            devices,
            &device_info,
            SPDRP_DEVICEDESC,
            &property_type,
            (PBYTE)name,
            sizeof(name),
            NULL
          )) {
        continue;
      }
      name[(sizeof(name) / sizeof(name[0])) - 1] = L'\0';
      camera_append_windows_name(buffer, name);
    }
    api.destroy_device_info_list(devices);
  }

  FreeLibrary(api.library);
}

#endif
