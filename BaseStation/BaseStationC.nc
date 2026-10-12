#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "pkt.h"

module BaseStationC @safe() {
    uses interface Boot;
    uses interface Leds;
    uses interface Receive as AMReceive;
    uses interface Packet;
    uses interface SplitControl as RadioControl;
    uses interface AMSend as AlarmSender;
}

implementation {
    #define TEMP_HIGH_THRESHOLD 40.0
    #define HUMIDITY_HIGH_THRESHOLD 75.0
    #define LUX_HIGH_THRESHOLD 200.0

    message_t alarmPacket;
    bool alarmSendLocked = FALSE;

    event void Boot.booted() {
        call RadioControl.start();
    }

    event void RadioControl.startDone(error_t err) {
        if (err == SUCCESS) {
            call Leds.led2On();
            printf("Base Station avviata. In attesa di dati dai sensori...\n");
        } else {
            call RadioControl.start();
        }
    }

    event void RadioControl.stopDone(error_t err) { }

    event message_t* AMReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {
        CombinedSensorMsg* msg;
        uint16_t dataCelsius;
        float c1, c2, c3, humidityLinear, lux;
        uint16_t humidityPrinted;
        uint16_t luxPrinted;
        float Vref = 1.5;
        float resistor = 10000.0;

        bool isAlarmConditionMet = FALSE;
        bool motionAlarmTriggered = FALSE;
        bool lightAlarmTriggered = FALSE;
        bool tempAlarmTriggered = FALSE;
        bool humAlarmTriggered = FALSE;

        call Leds.led0On();
        call Leds.led0Off();

        if (len != sizeof(CombinedSensorMsg)) {
            printf("Errore: Lunghezza messaggio non valida (%hhu bytes).\n", len);
            return bufPtr;
        }

        msg = (CombinedSensorMsg*)payload;

        printf("\n--- Dati ricevuti da Nodo ID: %u ---\n", msg->nodeid);

        if (msg->motionDetected == MOTION) {
            printf("  Movimento: RILEVATO!\n");
            call Leds.led1On();
            isAlarmConditionMet = TRUE;
            motionAlarmTriggered = TRUE;
        } else {
            printf("  Movimento: Non rilevato\n");
            call Leds.led1Off();
        }

        dataCelsius = -39 + (uint16_t)(0.01 * msg->temperatureRaw);
        printf("  Temperatura: %d C\n", dataCelsius);
        if (dataCelsius > TEMP_HIGH_THRESHOLD) {
            printf("!!! ALLARME: Temperatura Elevata (%d C) !!!\n", dataCelsius);
            isAlarmConditionMet = TRUE;
            tempAlarmTriggered = TRUE;
        }

        c1 = -4.0;
        c2 = 0.0405;
        c3 = -2.8e-6;
        humidityLinear = c1 + c2 * msg->humidityRaw + c3 * msg->humidityRaw * msg->humidityRaw;
        humidityPrinted = (uint16_t)(humidityLinear * 100);
        printf("  Umidita': %u.%02u%%\n", humidityPrinted / 100, humidityPrinted % 100);
        if (humidityLinear > HUMIDITY_HIGH_THRESHOLD) {
            printf("!!! ALLARME: Umidita' Elevata (%u.%02u%%) !!!\n", humidityPrinted / 100, humidityPrinted % 100);
            isAlarmConditionMet = TRUE;
            humAlarmTriggered = TRUE;
        }

        lux = (float)msg->lightRaw * 0.21;
        luxPrinted = (uint16_t)(lux * 100);
        printf("  Luminosita': %u.%02u LUX\n", luxPrinted / 100, luxPrinted % 100);
        if (lux > LUX_HIGH_THRESHOLD) {
            printf("!!! ALLARME: Luminosita' Elevata %u.%02u LUX !!!\n", luxPrinted / 100, luxPrinted % 100);
            isAlarmConditionMet = TRUE;
            lightAlarmTriggered = TRUE;
        }

        if (!alarmSendLocked) {
            CombinedSensorMsg* alarmPayload = (CombinedSensorMsg*)call Packet.getPayload(&alarmPacket, sizeof(CombinedSensorMsg));

            if (alarmPayload != NULL) {
                alarmPayload->nodeid = TOS_NODE_ID;
                alarmPayload->motionDetected = msg->motionDetected;
                alarmPayload->temperatureRaw = msg->temperatureRaw;
                alarmPayload->humidityRaw = msg->humidityRaw;
                alarmPayload->lightRaw = msg->lightRaw;

                alarmPayload->alarmStatus = isAlarmConditionMet ? ALARM_ON : ALARM_OFF;
                
                alarmPayload->motionAlarmActive = motionAlarmTriggered ? ALARM_ON : ALARM_OFF;
                alarmPayload->lightAlarmActive = lightAlarmTriggered ? ALARM_ON : ALARM_OFF;
                alarmPayload->tempAlarmActive = tempAlarmTriggered ? ALARM_ON : ALARM_OFF;
                alarmPayload->humAlarmActive = humAlarmTriggered ? ALARM_ON : ALARM_OFF;

                if (call AlarmSender.send(AM_BROADCAST_ADDR, &alarmPacket, sizeof(CombinedSensorMsg)) == SUCCESS) {
                    alarmSendLocked = TRUE;
                    printf(">>> Invio comando: ALLARME %s (Movimento: %u, Luce: %u) <<<\n",
                           (isAlarmConditionMet ? "ON" : "OFF"),
                           alarmPayload->motionAlarmActive,
                           alarmPayload->lightAlarmActive);
                } else {
                    printf("  Base Station: Errore nell'invio stato allarme.\n");
                }
            } else {
                printf("  Base Station: Impossibile ottenere payload per messaggio allarme.\n");
            }
        }

        printfflush();

        return bufPtr;
    }

    event void AlarmSender.sendDone(message_t* bufPtr, error_t error) {
        if (&alarmPacket == bufPtr) {
            alarmSendLocked = FALSE;
        }
        if (error != SUCCESS) {
            printf("ERRORE: Invio allarme fallito (%d)\n", error);
            printfflush();
        }
    }
}

