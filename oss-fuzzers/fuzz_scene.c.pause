#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>
#include <gpac/setup.h>
#include <gpac/scenegraph.h>
#include <gpac/bifs.h>
#include <gpac/laser.h>
#include <gpac/constants.h>

int LLVMFuzzerInitialize(int *argc, char ***argv) {
    gf_log_set_tool_level(GF_LOG_ALL, GF_LOG_QUIET);
    return 0;
}

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size < 10) return 0;

    GF_SceneGraph *sg = gf_sg_new();
    if (!sg) return 0;

    uint8_t type = data[0] % 2;
    uint16_t es_id = (data[1] << 8) | data[2];
    uint32_t config_size = data[3] % 16;
    if (config_size + 5 > size) config_size = 0;

    const uint8_t *config = config_size ? &data[4] : NULL;
    const uint8_t *payload = &data[4 + config_size];
    size_t payload_size = size - (4 + config_size);

    if (type == 0) {
#ifndef GPAC_DISABLE_BIFS
        GF_BifsDecoder *dec = gf_bifs_decoder_new(sg, GF_FALSE);
        if (dec) {
            if (config_size) {
                gf_bifs_decoder_configure_stream(dec, es_id, (uint8_t *)config, config_size, GF_CODECID_BIFS);
            }
            gf_bifs_decode_au(dec, es_id, payload, payload_size, 0);
            gf_bifs_decoder_del(dec);
        }
#endif
    } else {
#ifndef GPAC_DISABLE_LASER
        GF_LASeRCodec *dec = gf_laser_decoder_new(sg);
        if (dec) {
            if (config_size) {
                gf_laser_decoder_configure_stream(dec, es_id, (uint8_t *)config, config_size);
            }
            gf_laser_decode_au(dec, es_id, payload, payload_size);
            gf_laser_decoder_del(dec);
        }
#endif
    }

    gf_sg_del(sg);

    return 0;
}
