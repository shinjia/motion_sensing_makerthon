/* Shinjia Chen */

import processing.serial.*;
Serial myPort;

String COMPORT = "COM13";
int BAUDRATE = 38400; 
int sensorCount = 3;
char DELIM = ',';

int MAX_AROUND = 6000;
int THIS_AROUND = 3000;

int xmin = -350;
int xmax = 350;
int ymin = -235;
int ymax = 460;
int zmin = -1000;
int zmax = 1000;
int adjPGX = -25;
int adjPGY = -24;
float avgX=0.0, avgY=0.0;
float sumX=0.0, sumY=0.0;
float meanX=0.0, meanY=0.0; 
float stdX=0.0, stdY=0.0;
float[] X = new float[MAX_AROUND+1];
float[] Y = new float[MAX_AROUND+1];

int[] sensorValues = new int[sensorCount];  // array to hold the incoming values

float gx, gy, gz;
float accx, accy, accz;
int pos = 0;

float ratio = 1.0;

int[] area = {0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0};
int[] around = {0, 0, 0, 0, 0};  // 250, 500, 750, 1000, others
int around_total = 0;
float percent1, percent2, percent3, percent4;
int[] tc = {0, 0, 0, 0, 0}; // time_continue
int[] tc_max = {0, 0, 0, 0, 0}; // time_continue max
int tc_last = 5;
int tc_now;

PGraphics pg1, pg2, pg3;
int WH=800;
int ball_size = 10;

Table table;


void setup()
{
  size(1600, 1000);
  background(0);
    
  pg1 = createGraphics(WH, WH);
  pg2 = createGraphics(550, 800);
  pg3 = createGraphics(1400, 100);

  table = new Table();

  table.addColumn("id");
  table.addColumn("a0");
  table.addColumn("a1");
  table.addColumn("a2");
  table.addColumn("a3");
  table.addColumn("a4");
  table.addColumn("p1");
  table.addColumn("p2");
  table.addColumn("p3");
  table.addColumn("p4");
  table.addColumn("tc0");
  table.addColumn("tc1");
  table.addColumn("tc2");
  table.addColumn("tc3");
  table.addColumn("tc4");

  println(Serial.list());
  //myPort = new Serial(this, Serial.list()[6], BAUDRATE);
  myPort = new Serial(this, COMPORT, BAUDRATE);
  myPort.clear();   // clear the serial buffer:
}



void draw()
{
  float x, y, s;
  
  gx = (float)sensorValues[0];
  gy = (float)sensorValues[1];
  gz = (float)sensorValues[2];  //
 
  accx = ratio * gx + (1.0-ratio) * accx;
  accy = ratio * gy + (1.0-ratio) * accy;
  accz = ratio * gz + (1.0-ratio) * accz;
  
  
  x = map(accx, xmin, xmax, -1000, 1000);
  y = map(accy, ymin, ymax, -1000, 1000);
  s = ball_size;
  //s = map(accz, zmin, zmax, 1, 100);

  // around
  around_total++;
  if(around_total>=THIS_AROUND)
  {
    save_data();
    noLoop();
  }
  
  // check distance
  float d_around = dist(x, y, 0, 0);
  if(d_around<=250)
  {
    around[0]++;
    tc_now = 0;
    if(tc_now<=tc_last)
    {
      tc[0]++;
      tc[1]++;
      tc[2]++;
      tc[3]++;
      tc[4]++;
    }
    //tc[0] = 0;
    //tc[1] = 0;
    //tc[2] = 0;
    //tc[3] = 0;
    //tc[4] = 0;
  }
  else if(d_around<=500)
  {
    around[1]++;
    tc_now = 1;
    if(tc_now<=tc_last)
    {
      //tc[0]++;
      tc[1]++;
      tc[2]++;
      tc[3]++;
      tc[4]++;
    }
    tc[0] = 0;
    //tc[1] = 0;
    //tc[2] = 0;
    //tc[3] = 0;
    //tc[4] = 0;
  }
  else if(d_around<=750)
  {
    around[2]++;
    tc_now = 2;
    if(tc_now<=tc_last)
    {
      //tc[0]++;
      //tc[1]++;
      tc[2]++;
      tc[3]++;
      tc[4]++;
    }
    tc[0] = 0;
    tc[1] = 0;
    //tc[2] = 0;
    //tc[3] = 0;
    //tc[4] = 0;
  }
  else if(d_around<=1000)
  {
      //tc[0]++;
      //tc[1]++;
      //tc[2]++;
      tc[3]++;
      tc[4]++;
    tc_now = 3;
    if(tc_now<=tc_last)
    {
      tc[tc_now]++;
    }
    tc[0] = 0;
    tc[1] = 0;
    tc[2] = 0;
    //tc[3] = 0;
    //tc[4] = 0;
  }
  else
  {
    around[4]++;
    tc_now = 4;
    if(tc_now<=tc_last)
    {
      //tc[0]++;
      //tc[1]++;
      //tc[2]++;
      //tc[3]++;
      tc[4]++;
    }
    tc[0] = 0;
    tc[1] = 0;
    tc[2] = 0;
    tc[3] = 0;
    //tc[4] = 0;
  }
  if(tc[0]>tc_max[0]) tc_max[0] = tc[0];
  if(tc[1]>tc_max[1]) tc_max[1] = tc[1];
  if(tc[2]>tc_max[2]) tc_max[2] = tc[2];
  if(tc[3]>tc_max[3]) tc_max[3] = tc[3];
  if(tc[4]>tc_max[4]) tc_max[4] = tc[4];
  tc_last = tc_now;
  
  
  // area
  if(x>=0 && y>=0)
  {
    if(d_around<=250) { area[0]++; }
    else if(d_around<=500) { area[1]++; }
    else if(d_around<=750) { area[2]++; }
    else if(d_around<=1000) { area[3]++; }
    else { area[4]++; }
  }
  else if(x<0 && y>=0)
  {
    if(d_around<=250) { area[5]++; }
    else if(d_around<=500) { area[6]++; }
    else if(d_around<=750) { area[7]++; }
    else if(d_around<=1000) { area[8]++; }
    else { area[9]++; }
  }
  else if(x<0 && y<0)
  {
    if(d_around<=250) { area[10]++; }
    else if(d_around<=500) { area[11]++; }
    else if(d_around<=750) { area[12]++; }
    else if(d_around<=1000) { area[13]++; }
    else { area[14]++; }
  }
  else if(x>=0 && y<0)
  {
    if(d_around<=250) { area[15]++; }
    else if(d_around<=500) { area[16]++; }
    else if(d_around<=750) { area[17]++; }
    else if(d_around<=1000) { area[18]++; }
    else { area[19]++; }
  }
  
  
  float pg_x = map(x, -1000, 1000, 0, WH) + adjPGX;
  float pg_y = map(y, -1000, 1000, 0, WH) + adjPGY;

  X[around_total] = pg_x;
  Y[around_total] = pg_y;
  sumX += pg_x;
  sumY += pg_y;
  avgX = sumX / around_total;
  avgY = sumY / around_total;
  meanX = 0.0;
  meanY = 0.0;
  for(int i=0; i<around_total; i++)
  {
    meanX += sqrt((X[i]-avgX)*(X[i]-avgX));
    meanY += sqrt((Y[i]-avgY)*(Y[i]-avgY));
  }
  stdX = meanX / around_total;
  stdY = meanY / around_total;
  //avgX = (avgX * (around_total-1) + pg_x) / around_total;
  //avgY = (avgY * (around_total-1) + pg_y) / around_total;
  
  /****** begin of pg1 ******/
  pg1.beginDraw();

  pg1.noStroke();
  pg1.fill(0, 10);
  pg1.rect(0, 0, WH, WH);
  
  pg1.strokeWeight(0.1);
  pg1.stroke(255, 0, 0);
  pg1.fill(255,255, 0);
  pg1.ellipse(pg_x, pg_y, s, s);
  
  // draw backgrond

  // draw average
  pg1.fill(255, 100, 0, 20);
  pg1.stroke(255, 100, 0, 20);
  pg1.ellipse(avgX, avgY, stdX, stdY);
  
  
  float seg = WH /4;
  pg1.noFill();
  pg1.stroke(0, 200, 0);
  pg1.strokeWeight(1);
  pg1.ellipse(WH/2, WH/2, 1*seg, 1*seg);
  pg1.ellipse(WH/2, WH/2, 2*seg, 2*seg);
  pg1.ellipse(WH/2, WH/2, 3*seg, 3*seg);
  //pg1.ellipse(WH/2, WH/2, 4*seg, 4*seg);
  pg1.line(WH/2, 0, WH/2, WH);
  pg1.line(0, WH/2, WH, WH/2);

  pg1.endDraw();
  /****** end of pg1 ******/

  
  /****** begin of pg2 ******/
  pg2.beginDraw();
  
  pg2.background(0);
  pg2.textAlign(RIGHT);
  pg2.textSize(32); 
  pg2.fill(0, 102, 153);
  
  pg2.text(around[0], 150,  50);
  pg2.text(around[1], 150, 100);
  pg2.text(around[2], 150, 150);
  pg2.text(around[3], 150, 200);
  pg2.text(around[4], 150, 250);

  int bar_max = max(around);
  float bar0 = map(around[0], 0, bar_max, 0, 300);  // length 200 pixel
  float bar1 = map(around[1], 0, bar_max, 0, 300);  // length 200 pixel
  float bar2 = map(around[2], 0, bar_max, 0, 300);  // length 200 pixel
  float bar3 = map(around[3], 0, bar_max, 0, 300);  // length 200 pixel
  float bar4 = map(around[4], 0, bar_max, 0, 300);  // length 200 pixel
  
  pg2.fill(100, 102, 153);
  pg2.rect(150+20,  50-30, bar0, 30);
  pg2.rect(150+20, 100-30, bar1, 30);
  pg2.rect(150+20, 150-30, bar2, 30);
  pg2.rect(150+20, 200-30, bar3, 30);
  pg2.rect(150+20, 250-30, bar4, 30);

  // 
  pg2.textAlign(RIGHT);
  pg2.textSize(20); 
  pg2.fill(200, 102, 53);
  
  pg2.text(area[15], 350, 300);
  pg2.text(area[16], 350, 320);
  pg2.text(area[17], 350, 340);
  pg2.text(area[18], 350, 360);
  pg2.text(area[19], 350, 380);
  
  pg2.text(area[10], 150, 300);
  pg2.text(area[11], 150, 320);
  pg2.text(area[12], 150, 340);
  pg2.text(area[13], 150, 360);
  pg2.text(area[14], 150, 380);
  
  pg2.text(area[5], 150, 400+50);
  pg2.text(area[6], 150, 420+50);
  pg2.text(area[7], 150, 440+50);
  pg2.text(area[8], 150, 460+50);
  pg2.text(area[9], 150, 480+50);
  
  pg2.text(area[0], 350, 400+50);
  pg2.text(area[1], 350, 420+50);
  pg2.text(area[2], 350, 440+50);
  pg2.text(area[3], 350, 460+50);
  pg2.text(area[4], 350, 480+50);
  
  percent1 = 100.0*float(area[15]+area[16]+area[17]+area[18]+area[19]) / around_total;
  percent2 = 100.0*float(area[10]+area[11]+area[12]+area[13]+area[14]) / around_total;
  percent3 = 100.0*float(area[ 5]+area[ 6]+area[ 7]+area[ 8]+area[ 9]) / around_total;
  percent4 = 100.0*float(area[ 0]+area[ 1]+area[ 2]+area[ 3]+area[ 4]) / around_total;
  
  pg2.stroke(150, 100, 0);
  pg2.line(80, 400, 500, 400);
  pg2.line(300, 260, 300, 550);
  pg2.noStroke();
  
  pg2.textSize(30); 
  pg2.fill(200, 202, 53);
  pg2.text(percent1, 350+120, 380);
  pg2.text(percent2, 150+120, 380);
  pg2.text(percent3, 150+120, 530);
  pg2.text(percent4, 350+120, 530);
  
  // show tc
  // 
  pg2.textAlign(RIGHT);
  pg2.textSize(30); 
  pg2.fill(80, 252, 150);
  
  pg2.text(tc[0], 150, 600);
  pg2.text(tc[1], 150, 640);
  pg2.text(tc[2], 150, 680);
  pg2.text(tc[3], 150, 720);
  pg2.text(tc[4], 150, 760);
  
  pg2.text(tc_max[0], 150+110, 600);
  pg2.text(tc_max[1], 150+110, 640);
  pg2.text(tc_max[2], 150+110, 680);
  pg2.text(tc_max[3], 150+110, 720);
  pg2.text(tc_max[4], 150+110, 760);
  
  pg2.textAlign(RIGHT);
  pg2.textSize(30); 
  pg2.fill(280, 252, 250);
  pg2.text("iteration", 450, 680);
  pg2.text(THIS_AROUND, 450, 720);
  pg2.text(around_total, 450, 760);
  
  pg2.endDraw();
  /****** end of pg2 ******/

  /****** begin of pg3 ******/
  pg3.beginDraw();

  pg3.background(0);
  pg3.textAlign(LEFT);
  pg3.textSize(32); 
  pg3.fill(220);

  pg3.text("Balance Board Usage Statistics. --- by Shinjia Chen Ver 0.3", 100, 40);
  pg3.text("[B]Begin   [P]Pause   [R]Resume   [S]Save  [V]View path    [1-6]iteration setup", 100, 72);
    
  pg3.endDraw();
  /****** end of pg3 ******/

  
  background(100);
  image(pg1, 100, 30);
  image(pg2, 950, 30);
  image(pg3, 100, 860);

}


void show_path()
{
  /****** begin of pg1 ******/
  pg1.beginDraw();

  pg1.noStroke();
  pg1.fill(0);
  pg1.rect(0, 0, WH, WH);
  
  for(int i=0; i<THIS_AROUND; i++)
  {
    pg1.strokeWeight(0.1);
    pg1.stroke(255, 0, 0);
    pg1.fill(255,255, 0);
    pg1.ellipse(X[i], Y[i], ball_size, ball_size);
  }
  
  // draw backgrond

  // draw average
  pg1.fill(255, 100, 0, 20);
  pg1.stroke(255, 100, 0, 20);
  pg1.ellipse(avgX, avgY, stdX, stdY);
  
  
  float seg = WH /4;
  pg1.noFill();
  pg1.stroke(0, 200, 0);
  pg1.strokeWeight(1);
  pg1.ellipse(WH/2, WH/2, 1*seg, 1*seg);
  pg1.ellipse(WH/2, WH/2, 2*seg, 2*seg);
  pg1.ellipse(WH/2, WH/2, 3*seg, 3*seg);
  //pg1.ellipse(WH/2, WH/2, 4*seg, 4*seg);
  pg1.line(WH/2, 0, WH/2, WH);
  pg1.line(0, WH/2, WH, WH/2);

  pg1.endDraw();
  /****** end of pg1 ******/

  //background(100);
  image(pg1, 100, 30);
  noLoop();

}


void save_data()
{
  TableRow newRow = table.addRow();
  newRow.setInt("id", table.getRowCount() - 1);
  newRow.setInt("a0", around[0]);
  newRow.setInt("a1", around[1]);
  newRow.setInt("a2", around[2]);
  newRow.setInt("a3", around[3]);
  newRow.setInt("a4", around[4]);
  newRow.setFloat("p1", percent1);
  newRow.setFloat("p2", percent2);
  newRow.setFloat("p3", percent3);
  newRow.setFloat("p4", percent4);
  newRow.setInt("tc0", tc_max[0]);
  newRow.setInt("tc1", tc_max[1]);
  newRow.setInt("tc2", tc_max[2]);
  newRow.setInt("tc3", tc_max[3]);
  newRow.setInt("tc4", tc_max[4]);
  
  String filename = "data/new_" + year() + month() + day() + '-';
  if(hour()<10) filename += '0';
  filename += hour();
  
  if(minute()<10) filename += '0';
  filename += minute();
  
  if(second()<10) filename += '0';
  filename += second();
  filename += ".csv";
  saveTable(table, filename);
}

void reset_all()
{
    around_total = 0;    
    avgX=0.0; avgY=0.0;
    sumX=0.0; sumY=0.0;
    meanX=0.0; meanY=0.0; 
    stdX=0.0; stdY=0.0;
    for(int i=0; i<20; i++) area[i]=0;
    for(int i=0; i<5; i++)
    {
      around[i]=0;
      tc[i] = 0;
      tc_max[i] = 0;
    }
}


void keyPressed()
{
  
  if (key=='b' || key=='B')
  {
    reset_all();
    loop();
  }

  if (key=='1') { reset_all(); THIS_AROUND = 1000; }
  if (key=='2') { reset_all(); THIS_AROUND = 2000; }
  if (key=='3') { reset_all(); THIS_AROUND = 3000; }
  if (key=='4') { reset_all(); THIS_AROUND = 4000; }
  if (key=='5') { reset_all(); THIS_AROUND = 5000; }
  if (key=='6') { reset_all(); THIS_AROUND = 6000; }
  
 

  if (key=='v' || key=='V')
  {
    show_path();
    loop();
  }
 
  if (key=='p' || key=='P')
  {
    noLoop();
  }
  
  if (key=='r' || key=='R')
  {
    loop();
  }
  
  if (key=='s' || key=='S')
  {
    save_data();
  }
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
