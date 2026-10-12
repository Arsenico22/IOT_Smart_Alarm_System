#include "Msp430Adc12.h"

generic module AdcConfigC(uint8_t channel) {
    provides interface AdcConfigure<const msp430adc12_channel_config_t*>;
}

implementation {
    const msp430adc12_channel_config_t adcConfig = {
        inch: channel,
        sref: REFERENCE_AVcc_AVss,
        ref2_5v: REFVOLT_LEVEL_NONE,
        adc12ssel: SHT_SOURCE_SMCLK,
        adc12div: SHT_CLOCK_DIV_1,
        sht: SAMPLE_HOLD_16_CYCLES,
        sampcon_ssel: SAMPCON_SOURCE_SMCLK,
        sampcon_id: SAMPCON_CLOCK_DIV_1
    };

    async command const msp430adc12_channel_config_t* AdcConfigure.getConfiguration() {
        return &adcConfig;
    }
}

