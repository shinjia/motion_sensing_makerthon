/* Shinjia Chen */

import processing.serial.*;
Serial myPort;

int BAUDRATE = 38400; 
int sensorCount = 3;
char DELIM = ',';

int[] sensorValues = new int[sensorCount];  // array to hold the incoming values

float gx, gy, gz;
float accx, accy, accz;
int pos = 0;

  float vx, vy, vz;
  float px=100, py=300, pz=500;
  
float ratio = 1.0;


void setup()
{
  size(600,600);
  smooth();
  background(0);
  
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[6], BAUDRATE);
  myPort.clear();   // clear the serial buffer:
}


void draw()
{
  float x, y;

/*
  accx = sensorValues[0];  // 1100, -1100
  accy = sensorValues[1];  // 1100, -1100
  accz = sensorValues[2];  // 
*/

  gx = sensorValues[0];  // 1100, -1100
  gy = sensorValues[1];  // 1100, -1100
  gz = sensorValues[2];  //
  
  accx = ratio * gx + (1.0-ratio) * accx;
  accy = ratio * gy + (1.0-ratio) * accy;
  accz = ratio * gz + (1.0-ratio) * accz;

  pos++;
  if(pos>=width)
  {
    pos = 1;
    background(0);
  }
  
  vx = map(accx, -1000, 1000, 0, 200);
  vy = map(accy, -1000, 1000, 200, 400);
  vz = map(accz, -1000, 1000, 400, 600);
  
  noFill();
  stroke(255, 0, 0);
  line(pos-1, px, pos, vx);
  
  stroke(0, 255, 0);
  line(pos-1, py, pos, vy);
  
  stroke(0, 0, 255);
  line(pos-1, pz, pos, vz);
  
  px = vx;
  py = vy;
  pz = vz;
}


void serialEvent(Serial myPort)
{
  String serialString = myPort.readStringUntil('\n');
    
  if (serialString != null)
  {
    String[] numbers = split(serialString, DELIM);
    if (numbers.length == sensorCount)
    {
      for (int i = 0; i < numbers.length; i++)
      {
        if (i <= sensorCount)
        {
          numbers[i] = trim(numbers[i]);
          sensorValues[i] =  int(numbers[i]);
        }
      }
    }
  }
}