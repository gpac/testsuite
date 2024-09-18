#include "/src/gpac/include/gpac/mpegts.h"
#include <stdio.h>
#include <unistd.h>
#include <string.h>

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  char filename[256];
  sprintf(filename, "/tmp/libfuzzer.%d", getpid());

  FILE *fp = fopen(filename, "wb");
  if (!fp)
    return 0;
  fwrite(data, size, 1, fp);
  fclose(fp);

  gf_m2ts_probe_file(filename);

  unlink(filename);
  return 0;
}