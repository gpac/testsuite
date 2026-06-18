#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include <gpac/setup.h>
#include <gpac/tools.h>
#include <gpac/scenegraph.h>
#include <gpac/scene_manager.h>
#include <gpac/constants.h>

int LLVMFuzzerInitialize(int *argc, char ***argv) {
    gf_sys_init(GF_MemTrackerNone, NULL);
    gf_log_set_tool_level(GF_LOG_ALL, GF_LOG_QUIET);
    return 0;
}

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size < 8 || size > 1 << 20) return 0;

    uint8_t sel = data[0];
    const uint8_t *payload = data + 1;
    size_t payload_size = size - 1;

    GF_SceneManager_LoadType type;
    const char *ext;
    switch (sel % 5) {
    case 0: type = GF_SM_LOAD_BT;   ext = "bt";   break;
    case 1: type = GF_SM_LOAD_VRML; ext = "wrl";  break;
    case 2: type = GF_SM_LOAD_X3DV; ext = "x3dv"; break;
    case 3: type = GF_SM_LOAD_XMTA; ext = "xmt";  break;
    default:type = GF_SM_LOAD_X3D;  ext = "x3d";  break;
    }

    char filename[256];
    snprintf(filename, sizeof(filename), "/tmp/libfuzzer.%d.%s", getpid(), ext);

    FILE *fp = fopen(filename, "wb");
    if (!fp) return 0;
    if (payload_size) fwrite(payload, payload_size, 1, fp);
    fclose(fp);

    GF_SceneGraph *sg = gf_sg_new();
    if (!sg) {
        unlink(filename);
        return 0;
    }
    GF_SceneManager *ctx = gf_sm_new(sg);
    if (!ctx) {
        gf_sg_del(sg);
        unlink(filename);
        return 0;
    }

    GF_SceneLoader load;
    memset(&load, 0, sizeof(GF_SceneLoader));
    load.fileName = filename;
    load.ctx = ctx;
    load.type = type;

    GF_Err e = gf_sm_load_init(&load);
    if (!e) gf_sm_load_run(&load);
    gf_sm_load_done(&load);

    gf_sm_del(ctx);
    gf_sg_del(sg);

    unlink(filename);
    return 0;
}
