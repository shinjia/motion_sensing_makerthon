#include <SoftwareSerial.h>
SoftwareSerial BTSerial(8,7); // RX, TX

void setup()
{
  Serial.begin(38400);
  BTSerial.begin(38400);
}

void loop() 
{
  if(BTSerial.available())
    Serial.write(BTSerial.read()); 
  else if(Serial.available())
    BTSerial.write(Serial.read());    
}