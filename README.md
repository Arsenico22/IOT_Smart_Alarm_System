🛡️ Smart Alarm System & WSN Intruder Detection

📌 Project Overview:

Modern security infrastructures require flexible, low-power, and wire-free sensor networks capable of continuous environmental monitoring. This project implements a Wireless Sensor Network (WSN) using TelosB mote platforms running TinyOS, featuring multi-sensor data acquisition, IEEE 802.15.4 radio communication, precision analog signal conditioning, and real-time TCP telemetry streaming.   

🚀 System Architecture & Workflow:

The network architecture is distributed across three discrete nodes communicating via TinyOS Active Messages (AM) over an IEEE 802.15.4 radio link:   Sensor Node (CombinedSensorAppC): Periodically samples ambient temperature, relative humidity, visible/infrared light, and monitors motion via an external PIR sensor. Raw readings are bundled into a structured packet payload (CombinedSensorMsg) and broadcasted wirelessly.   Base Station (BaseStationAppC): Acts as the network gateway. It receives raw radio payloads, converts digital ADC counts into physical measurement units using datasheet polynomial models, evaluates global alarm thresholds, dispatches action directives, and pipes telemetry over USB UART.   Actuator Node (ActuatorAppC): Listens for alarm directives from the network. Upon triggering, it drives a piezoelectric buzzer via direct MSP430 GPIO manipulation (P2.3) and toggles dedicated visual LED indicators.   

🔌 Hardware Interfacing & Signal Conditioning:

PIR Sensor Level Adaptation: The HC-SR501 PIR motion sensor outputs 5V logic, while the TelosB analog input 	PIR Sensor Level Adaptation: The HC-SR501 PIR motion sensor outputs 5V logic, while the TelosB analog input (ADC0) operates up to 3.3 V}. A passive resistive voltage divider (R_1 = 2 kΩ, R_2 = 5.1 kΩ) scales the voltage safely down to ≈ 3.59 V: 
V_ADC0 = V_PIR × R2/((R1+R2))  ≈ 3.59 V
	Onboard Sensor Drivers: Integrates Sensirion SHT11 (temperature/humidity) and Hamamatsu S1087-01 (light photodiode) drivers alongside precision MSP430 12-bit ADC configurations (AdcConfigC). 
	Actuator GPIO Control: Directly maps ActuatorC.OutputPin to HplMsp430GeneralIOC.Port23 for real-time hardware state switching. 
📊 Data Processing & Physical Conversions
The Base Station computes physical quantities from raw sensor ADC counts: 
	Temperature (°C): Linear conversion from SHT11 raw data: 
Temp = -39 + 0.01 × SO_Temp
	Relative Humidity (RH%): Polynomial compensation model: 
RH_linear = c_1 + c_2 × SO_RH + c_3 × SO_RH^2  	(c_1=-4.0,c_2=0.0405,c_3=-2.8× 10^(-6) )
	Illuminance (Lux): Derived from 12-bit photodiode conversion (1.5 V reference, 100 kΩ resistor): 
Lux = Raw_Light × 2.8161

🖥️ Real-Time Telemetry & Gateway:

Leverages TinyOS PrintfC over USB UART, bridged via Serial Forwarder to stream live system diagnostics and telemetry packets directly to TCP port 9002 for remote monitoring.   
