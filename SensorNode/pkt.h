#ifndef PKT_H
#define PKT_H

enum {
    AM_COMBINED_SENSOR_MSG = 77
};

typedef nx_struct CombinedSensorMsg {
    nx_uint16_t nodeid;
    nx_uint8_t motionDetected;
    nx_uint16_t temperatureRaw;
    nx_uint16_t humidityRaw;
    nx_uint16_t lightRaw;
    nx_uint8_t alarmStatus;
    nx_uint8_t motionAlarmActive;
    nx_uint8_t lightAlarmActive;
    nx_uint8_t tempAlarmActive;
    nx_uint8_t humAlarmActive;
    nx_uint8_t baseStationError;
} CombinedSensorMsg;

enum {
    MOTION = 1,
    NO_MOTION = 0
};

enum {
    ALARM_OFF = 0,
    ALARM_ON = 1
};

#endif

