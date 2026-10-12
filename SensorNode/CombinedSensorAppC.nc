#include "pkt.h"

configuration CombinedSensorAppC { }
implementation {
    components MainC, CombinedSensorC, LedsC;
    components new TimerMilliC() as SensorTimerC;
    components ActiveMessageC;
    components new AMSenderC(AM_COMBINED_SENSOR_MSG);

    components new SensirionSht11C() as TemperatureDriver;
    components new SensirionSht11C() as HumidityDriver;
    components new HamamatsuS1087ParC() as LightDriver;

    components new AdcReadClientC() as Adc0ReaderC;
    components new AdcConfigC(INPUT_CHANNEL_A0) as Adc0Config;

    CombinedSensorC.Boot -> MainC.Boot;
    CombinedSensorC.Leds -> LedsC;
    CombinedSensorC.SensorTimer -> SensorTimerC;

    CombinedSensorC.AMSend -> AMSenderC;
    CombinedSensorC.Packet -> AMSenderC;
    CombinedSensorC.RadioControl -> ActiveMessageC;

    CombinedSensorC.Temperature -> TemperatureDriver.Temperature;
    CombinedSensorC.Humidity -> HumidityDriver.Humidity;
    CombinedSensorC.Light -> LightDriver;

    CombinedSensorC.Adc0Sensor -> Adc0ReaderC.Read;
    Adc0ReaderC.AdcConfigure -> Adc0Config;
}

