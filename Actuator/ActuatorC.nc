#include "msp430.h"
#include "pkt.h"

module ActuatorC @safe() {
    uses interface Boot;
    uses interface Leds;
    uses interface Receive as AMReceive;
    uses interface SplitControl as RadioControl;
}

implementation {
    event void Boot.booted() {
        call RadioControl.start();
        call Leds.led0Off();
        call Leds.led1Off();
        call Leds.led2Off();
    }

    event void RadioControl.startDone(error_t err) {
        if (err == SUCCESS) {
            call Leds.led1On();
        } else {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t err) {
        call Leds.led1Off();
        call Leds.led0Off();
        call Leds.led2Off();
    }

    event message_t* AMReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
        call Leds.led0On();
        call Leds.led0Off();

        if (len == sizeof(CombinedSensorMsg)) {
            CombinedSensorMsg* msg = (CombinedSensorMsg*)payload;

            if (msg->motionAlarmActive == ALARM_ON) {
                call Leds.led2On();
            } else {
                call Leds.led2Off();
            }

            if (msg->lightAlarmActive == ALARM_ON) {
                call Leds.led0On();
            } else {
                call Leds.led0Off();
            }

            call Leds.led1Off();
        }
        return bufPtr;
    }
}

