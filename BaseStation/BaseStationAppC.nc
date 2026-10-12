#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "pkt.h"

configuration BaseStationAppC { }
implementation {
    components MainC, BaseStationC, LedsC;
    components ActiveMessageC;
    components new AMReceiverC(AM_COMBINED_SENSOR_MSG);
    components new AMSenderC(AM_COMBINED_SENSOR_MSG) as AlarmSenderC;

    components PrintfC;
    components SerialStartC;

    BaseStationC.Boot -> MainC;
    BaseStationC.Leds -> LedsC;

    BaseStationC.AMReceive -> AMReceiverC;
    BaseStationC.RadioControl -> ActiveMessageC;

    BaseStationC.AlarmSender -> AlarmSenderC;
    BaseStationC.Packet -> AlarmSenderC;
}

