#include <libfprint-2/fprint.h>
#include <glib.h>
#include <stdio.h>

int main(void) {
  g_autoptr(GError) error = NULL;
  g_autoptr(FpContext) ctx = fp_context_new();
  GPtrArray *devices = fp_context_get_devices(ctx);

  if (!devices || devices->len == 0) {
    fprintf(stderr, "No fingerprint devices found.\n");
    return 1;
  }

  FpDevice *dev = g_ptr_array_index(devices, 0);
  printf("Device: %s\n", fp_device_get_name(dev));

  if (!fp_device_open_sync(dev, NULL, &error)) {
    fprintf(stderr, "open failed: %s\n", error->message);
    return 1;
  }

  if (!fp_device_has_feature(dev, FP_DEVICE_FEATURE_STORAGE_CLEAR)) {
    fprintf(stderr, "Driver does NOT support clear-storage.\n");
    fp_device_close_sync(dev, NULL, NULL);
    return 2;
  }

  if (!fp_device_clear_storage_sync(dev, NULL, &error)) {
    fprintf(stderr, "clear failed: %s\n", error->message);
    fp_device_close_sync(dev, NULL, NULL);
    return 1;
  }

  printf("Storage cleared OK.\n");
  fp_device_close_sync(dev, NULL, NULL);
  return 0;
}
