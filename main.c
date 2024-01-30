#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"

#include <stdio.h>
float max = 0;

void data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)
{
   float* buff = (float*)pInput;
   for (unsigned long i = 0; i < frameCount * 2; i += 2) {
    float check = buff[i];
    printf("%f\n", check);
   }
}

int main(int argc, char** argv)
{
    ma_result result;
    ma_device_config deviceConfig;
    ma_device device;

    deviceConfig = ma_device_config_init(ma_device_type_capture);
    deviceConfig.capture.format     = ma_format_s16;
    deviceConfig.capture.channels   = 2;
    deviceConfig.dataCallback       = data_callback;
    result = ma_device_init(NULL, &deviceConfig, &device);
    if (result != MA_SUCCESS) {
        return result;
    }

    ma_device_start(&device);

    printf("Press Enter to quit...\n");
    getchar();

    ma_device_uninit(&device);

    (void)argc;
    (void)argv;
    return 0;
}