#include "/src/gpac/include/gpac/internal/isomedia_dev.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  if (size == 0)
    return 0;

  // Use a fixed size buffer to prevent potential buffer overflows.
  char sPath[256] = {0};
  size_t pathLen = size < sizeof(sPath) - 1 ? size : sizeof(sPath) - 1;
  memcpy(sPath, data, pathLen);

  GF_DataMap *map = gf_isom_fdm_new_temp(sPath);
  if (map) {
    gf_isom_datamap_del(map);
  }
  return 0;
}