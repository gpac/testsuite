#include <stdio.h>
#include <unistd.h>
#include <gpac/isomedia.h>
#include <gpac/internal/isomedia_dev.h>
#include <gpac/media_tools.h>
#include <gpac/constants.h>
#include <gpac/setup.h>

int LLVMFuzzerInitialize(int *argc, char ***argv) {
    gf_log_set_tool_level(GF_LOG_ALL, GF_LOG_QUIET);
    return 0;
}

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size < 8 || size > 65536) return 0;

    char filename[256];
    sprintf(filename, "/tmp/libfuzzer.%d", getpid());
    FILE *fp = fopen(filename, "wb");
    if (!fp) {
        return 0;
    }
    fwrite(data, size, 1, fp);
    fclose(fp);

    GF_ISOFile *movie = NULL;
    movie = gf_isom_open_file(filename, GF_ISOM_OPEN_READ_DUMP, NULL);
    if (movie != NULL) {
        u32 i, count = gf_isom_get_track_count(movie);
        for (i = 1; i <= count && i <= 16; i++) {
            gf_isom_get_media_type(movie, i);
            gf_isom_get_media_subtype(movie, i, 1);
            gf_isom_get_sample_count(movie, i);
            gf_isom_get_media_timescale(movie, i);

            u32 w, h;
            gf_isom_get_visual_info(movie, i, 1, &w, &h);

            u32 sr, nb_ch, bps;
            gf_isom_get_audio_info(movie, i, 1, &sr, &nb_ch, &bps);

            GF_DecoderConfig *dcfg = gf_isom_get_decoder_config(movie, i, 1);
            if (dcfg) gf_odf_desc_del((GF_Descriptor *)dcfg);
        }
        gf_isom_close(movie);
    }
    unlink(filename);
    return 0;
}
