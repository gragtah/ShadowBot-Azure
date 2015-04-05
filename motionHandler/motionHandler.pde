/*
Image is reversed:  LEFT -> RIGHT
 RIGHT -> LEFT
 
 123 -> { -> start
 125 -> } -> stop
 */
import processing.serial.*;
import SimpleOpenNI.*;

PrintWriter output;

Serial myPort;
SimpleOpenNI  context;
color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255),
};
PVector com = new PVector();                                   
PVector com2d = new PVector();                                   

//variables for serial transmission
char skelData[] = new char[3];

String fileName;

void setup()
{
  size(640, 480);
  frameRate(200);

  String portName = Serial.list()[5];
  println(Serial.list());
  myPort = new Serial(this, portName, 115200);
  myPort.bufferUntil('\n');

  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }
  context.enableDepth();
  context.enableUser();
  context.setMirror(true);

  background(200, 0, 0);
  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();
}

void draw()
{
  context.update(); 
  image(context.depthImage(), 0, 0);

  //draw lines for human to align with
  strokeWeight(5);
  stroke(0, 255, 255);
  line(320, 0, 320, 480);
  line(0, 140, 640, 140);
  line(85, 0, 85, 480);
  line(555, 0, 555, 480);

  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      getUserData(userList[i]);
    }

    // draw the center of mass
    if (context.getCoM(userList[i], com))
    {
      context.convertRealWorldToProjective(com, com2d);
      stroke(100, 255, 0);
      strokeWeight(1);
      beginShape(LINES);
      vertex(com2d.x, com2d.y - 5);
      vertex(com2d.x, com2d.y + 5);

      vertex(com2d.x - 5, com2d.y);
      vertex(com2d.x + 5, com2d.y);
      endShape();

      fill(0, 255, 100);
      text(Integer.toString(userList[i]), com2d.x, com2d.y);
    }
  }
}

void getUserData(int userId)
{ 
  PVector jointPos = new PVector();

  //trassmit data to arduino
  myPort.write(123);

  //context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,jointPos);
  //println( int(jointPos.y/10) );

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, jointPos);
  //println( int(jointPos.z/10) + "    ");
  myPort.write( int(jointPos.z/10) );

  output.print( int(jointPos.z/10) );
  output.print(" ");

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, jointPos);
  int dataPoint[] = { 
    int(jointPos.x/10), int(jointPos.y/10)
  };

  for (int i = 0; i < 2; i++) {
    if (dataPoint[i] > 10) {
      myPort.write(0);
      myPort.write(dataPoint[i]);

      output.print("0" + dataPoint[i]);
      output.print(" ");
    }
    if (dataPoint[i] < 10 && dataPoint[i] >= 0) {
      myPort.write(0);
      myPort.write(0);
      myPort.write(dataPoint[i]);

      output.print("00" + dataPoint[i]);
      output.print(" ");
    }
  }

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, jointPos);
  //println( (255-abs(int(jointPos.x/10))) + "  " + int(jointPos.y/10) + "  ");
  //println( 255 - abs( int(jointPos.x/10) ) );
  //  Y axis handle
  if ( int(jointPos.y/10) > 10 ) {
    myPort.write(0);
    myPort.write( int(jointPos.y/10) );

    output.print("0" + int(jointPos.y/10));
    output.print(" ");
  }
  if ( int(jointPos.y/10) < 10 && int(jointPos.y/10) >= 0 ) {
    myPort.write(0);
    myPort.write(0);
    myPort.write( int(jointPos.y/10) );

    output.print("00" + int(jointPos.y/10));
    output.print(" ");
  }
  myPort.write( 255 - abs( int(jointPos.x/10) ) );

  output.println( 255 - abs( int(jointPos.x/10) ) );

  myPort.write(125);

  //begin drawing skeleton tracked by openNI
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);

  int s = second();  // Values from 0 - 59
  int m = minute();  // Values from 0 - 59
  int h = hour();    // Values from 0 - 23
  
  fileName = str(h) + str(m) + str(s) + ".txt";
  output = createWriter(fileName);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
  output.flush();
  output.close();
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
