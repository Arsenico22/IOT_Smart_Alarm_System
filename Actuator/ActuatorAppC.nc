#include "pkt.h"

configuration ActuatorAppC { }
implementation {
    components MainC, ActuatorC, LedsC;
    components ActiveMessageC;

    components new AMReceiverC(AM_COMBINED_SENSOR_MSG);

    ActuatorC.Boot -> MainC;
    ActuatorC.Leds -> LedsC;

    ActuatorC.AMReceive -> AMReceiverC;
    ActuatorC.RadioControl -> ActiveMessageC;
}

