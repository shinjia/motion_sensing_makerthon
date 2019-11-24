#include <SoftwareSerial.h>

SoftwareSerial BTSerial(8,7);  // RX,TX

#include "I2Cdev.h"
#include "MPU6050.h"

#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    #include "Wire.h"
#endif

MPU6050 accelgyro;
//MPU6050 accelgyro(0x69); // <-- use for AD0 high

int16_t ax, ay, az;
int16_t gx, gy, gz;

#define OUTPUT_GRAPH

#define LED_PIN 13
bool blinkState = false;


float gForceX, gForceY, gForceZ;
float sX, sY, sZ;
int sendX, sendY, sendZ;
float adjX = -0.04;
float adjY = 0.13;
float adjZ = 1.09;
float scaleX = 1000.0;
float scaleY = 1000.0;
float scaleZ = -1000.0;
float smooth_factor = 0.2;


long gyroX, gyroY, gyroZ;
float rotX, rotY, rotZ;

void setup()
{
    #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
        Wire.begin();
    #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
        Fastwire::setup(400, true);
    #endif

    Serial.begin(38400);
    BTSerial.begin(38400);

    // initialize device
    Serial.println("Initializing I2C devices...");
    accelgyro.initialize();

    // verify connection
    Serial.println("Testing device connections...");
    Serial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");

    pinMode(LED_PIN, OUTPUT);
}

void loop()
{
    // read raw accel/gyro measurements from device
    accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

    // normalize
    sX = (ax / 16384.0 + adjX) * scaleX;
    sY = (ay / 16384.0 + adjY) * scaleY;
    sZ = (az / 16384.0 + adjZ) * scaleZ;
    
    gForceX = smooth_factor * sX + (1.0-smooth_factor)*gForceX;
    gForceY = smooth_factor * sY + (1.0-smooth_factor)*gForceY;
    gForceZ = smooth_factor * sZ + (1.0-smooth_factor)*gForceZ;

    sendX = int(gForceX);
    sendY = int(gForceY);
    sendZ = int(gForceZ);
        // display comma accel/gyro x/y/z values
        //Serial.print(gForceX); Serial.print(",");
        //Serial.print(gForceY); Serial.print(",");
        //Serial.print(gForceZ); 
        Serial.print(sendX); Serial.print(",");
        Serial.print(sendY); Serial.print(",");
        Serial.print(sendZ);
        //Serial.print(20000); Serial.print(",");
        //Serial.print(0); Serial.print(",");
        //Serial.println(-20000);
        Serial.println("");
        
        //BTSerial.print("g");
        //BTSerial.print(",");
        BTSerial.print(sendX);
        BTSerial.print(",");
        BTSerial.print(sendY);
        BTSerial.print(",");
        BTSerial.print(sendZ);
        BTSerial.println("");

    // blink LED to indicate activity
    blinkState = !blinkState;
    digitalWrite(LED_PIN, blinkState);
    delay(20);
}