/*
Image is reversed:  LEFT -> RIGHT
                    RIGHT -> LEFT

 data[0]  ->  LEFT KNEE     Y
 data[1]  ->  LEFT HAND     X
 data[2]  ->  LEFT HAND     Y
 data[3]  ->  RIGHT HAND    X
 data[4]  ->  RIGHT HAND    Y

 123 -> { -> start
 125 -> } -> stop

         NAME            OFFSET          MIN          MAX            HALF
         ________________________________________________________________
         LHAND             10          080           150              115
         LWRIST            17          073           163              118
         LSHOULDER         21          000           159              080

         RHAND             10          150           080              115
         RWRIST            10          163           070              118
         RSHOULDER         17          159           000              080

         LKNEE             00          000           150              075
         LFOOT             --          020           060              040
         LTHIGH            00          053           000              026

         RKNEE             00          150           000              075
         RFOOT             --          080           040              060
         RTHIGH            --          100           150              125
*/
#include <Servo.h>

Servo LHAND, LWRIST, LSHOULDER, RHAND, RWRIST, RSHOULDER;
//Servo LKNEE, RKNEE, LFOOT, RFOOT, LTHIGH, RTHIGH;

String inputString = "";
boolean stringComplete = false;
boolean sendData = false;

void setup() {
  Serial.begin(115200);

  //  LKNEE.attach(A6);          LKNEE.write(120);
  //  RKNEE.attach(A7);          RKNEE.write(30);
  //
  //  LFOOT.attach(4);           LFOOT.write(20);
  //  RFOOT.attach(5);           RFOOT.write(80);
  //
  //  LTHIGH.attach(2);          LTHIGH.write(53);
  //  RTHIGH.attach(3);          RTHIGH.write(100);

  LHAND.attach(A0);          LHAND.write(80);
  LWRIST.attach(A1);         LWRIST.write(73);
  LSHOULDER.attach(A2);      LSHOULDER.write(80);

  RHAND.attach(A3);          RHAND.write(80);
  RWRIST.attach(A4);         RWRIST.write(73);
  RSHOULDER.attach(A5);      RSHOULDER.write(90);
}

void loop()
{
  if (stringComplete) {
    //put data into data array
    int stringLength = inputString.length() / 3;
    String data[ stringLength ];

    for (int i = 0; i < stringLength; i++) {
      data[i] = inputString.substring( i * 3, (i * 3) + 3 );
      Serial.print(data[i]);
      Serial.print("    ");
    }
    Serial.println();

    //        LEFT ARM        //
    if ( data[1].toInt() < 30 ) {
      LWRIST.write(163);
      LHAND.write( map(data[1].toInt(), 5, 35, 150, 80) );
    }
    else {
      LWRIST.write(73);
      LHAND.write( map(data[1].toInt(), 35, 80, 150, 80) );
    }

    //        RIGHT ARM        //
    if (data[4].toInt() > 220) {
      RWRIST.write(10);
      RHAND.write( map(data[4].toInt(), 220, 245, 80, 0) );
    }
    else {
      RWRIST.write(73);
      RHAND.write( map(data[4].toInt(), 175, 220, 80, 0) );
    }

    //        SHOULDER MOVEMENTS        //
    LSHOULDER.write( map(data[2].toInt(), 10, 80, 159, 0) );
    RSHOULDER.write( map(data[3].toInt(), 10, 80, 0, 159) );


    //          LEG MOVEMENTS          //
    //LTHIGH.write( map(data[0].toInt(), 175, 130, 53, 3) );
    //RTHIGH.write( map(data[0].toInt(), 175, 130, 100, 150) );

    //LFOOT.write( map(data[0].toInt(), 175, 135, 20, 60) );
    //RFOOT.write( map(data[0].toInt(), 175, 135, 80, 40) );

    //LKNEE.write( map(data[0].toInt(), 175, 130, 120, 30) );
    //RKNEE.write( map(data[0].toInt(), 175, 130, 30, 120) );

    //prepare to take in new data
    inputString = "";
    stringComplete = false;
  }
}

void serialEvent() {
  while (Serial.available()) {
    int inChar = Serial.read();

    if (inChar == 125) {
      sendData = false;
      stringComplete = true;
    }
    if (sendData)
      inputString += inChar;
    if (inChar == 123)
      sendData = true;
  }
}

