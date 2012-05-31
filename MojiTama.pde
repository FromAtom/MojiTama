import SimpleOpenNI.*;
import fullscreen.*;

SimpleOpenNI context;
boolean autoCalib = true;

/*Vector data*/
PVector rightHandPosBuf = new PVector();
PVector leftHandPosBuf = new PVector();
PVector torsoPosBuf = new PVector();

PVector makeCharPoint = new PVector();
PVector menuPoint = new PVector();


/*Images*/
PImage imgRightHand;
PImage imgLeftHand;
PImage imgBubble;
PImage imgMenu;
float iconRotate = 0.0;
int iconSize = 70;
int menuSize = 300;

/*flags*/
boolean makeCharFlag = false;
boolean menuFlag = false;
boolean demoFlag = false;
boolean jumpFlag = false;


/*Fonts*/
PFont myFont;

/*for FullScreen*/
FullScreen fs;


/*defines*/
final int lenMenuTrigger = 350; //for compare torso and hands
final int lenMakeTrigger = 70;  //for compare hands

/*for use File IO*/
useFile outputFile;

/*char table*/
final char[][] kanaTable= {
    {'あ','い','う','え','お'},
    {'か','き','く','け','こ'},
    {'さ','し','す','せ','そ'},
    {'た','ち','つ','て','と'},
    {'な','に','ぬ','ね','の'},
    {'は','ひ','ふ','へ','ほ'},
    {'ま','み','む','め','も'},
    {'や','や','ゆ','よ','よ'},
    {'ら','り','る','れ','ろ'},
    {'わ','を','ん','、','。'}
};

/*char table  */
int rowCharTable = 0;
int columnCharTable = 0;

void setup()
{
    context = new SimpleOpenNI(this);
    fs = new FullScreen(this);

    // enable Depth Map generation
    if(context.enableDepth() == false){
        println("Can't open the depthMap, maybe the camera is not connected!");
        exit();
        return;
    }

    // enable RGB Map generation
    if(context.enableRGB() == false){
        println("Can't open the RGB Map, maybe the camera is not connected!");
        exit();
        return;
    }

    //Load images
    imgRightHand = loadImage("arrow.png");
    imgLeftHand = loadImage("star.png");
    imgBubble = loadImage("hukidashi.png");
    imgMenu = loadImage("menu.png");

    
    // enable skeleton generation for all joints
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

    //mirror enable
    context.setMirror(true);

    //Load & Set Fonts
    myFont = loadFont("Migu-1P-Regular-48.vlw");
    textFont(myFont);
    textAlign(CENTER);

    background(0);
    smooth();
    frameRate(30);

    size(context.rgbWidth(), context.rgbHeight());
    fs.setResolution(width, height);

    //fs.enter();
}


void draw()
{
    background(0);

    // update the cam
    context.update();

    noStroke();

    /*
    PImage  rgbImage = context.rgbImage();
    int d = 10; //円の直径を定義
    
    // ライブカメラの映像から、円の直径の間隔ごとに、色情報を取得し、その色で円を描く
    for(int y = d / 2 ; y < context.rgbHeight() ; y += d) {
        for(int x = d / 2 ; x < context.rgbWidth() ; x += d) {
            fill(rgbImage.pixels[y*context.rgbWidth() + x]);
            ellipse(x, y, d, d);
        }
    }
    */

    image(context.rgbImage(), 0, 0);
    
    //image(imgBubble, 10, 10,imgBubble.width-20,imgBubble.height-20);

    
    if(context.isTrackingSkeleton(1))
        drawSkeleton(1);
    /*
    textSize(30);
    text(kanaTable[rowCharTable][columnCharTable],width/2,height/2);
    */
}

void stop()
{
    super.stop();
}

/*
  void draw()
  {
  // update the cam
  context.update();
  
  // draw depthImageMap
  image(context.rgbImage(), 0, 0);
    
    
  // draw the skeleton if it's available
  if(context.isTrackingSkeleton(1))
  drawSkeleton(1);
  }
*/


// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
    // to get the 3d joint data
    //right hand position
    PVector rightHand = new PVector();
    PVector rightHandPos = new PVector();
    

    //left hand position
    PVector leftHand = new PVector();
    PVector leftHandPos = new PVector();
    
    //torso position
    PVector torso = new PVector();
    PVector torsoPos = new PVector();

    String c = "あ";

    //get & convert hand position
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
    context.convertRealWorldToProjective(rightHand,rightHandPos);
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
    context.convertRealWorldToProjective(leftHand,leftHandPos);
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,torso);
    context.convertRealWorldToProjective(torso,torsoPos);
    
    //add in Buffer
    rightHandPosBuf.add(rightHandPos);
    leftHandPosBuf.add(leftHandPos);

    //calc average
    rightHandPosBuf.mult(0.5);
    leftHandPosBuf.mult(0.5);
    
    if(!makeCharFlag && !menuFlag){
        //print image on right hand
        image(imgRightHand,
              rightHandPosBuf.x-iconSize/2,
              rightHandPosBuf.y-iconSize/2,
              iconSize,
              iconSize);
        
        //print image on left hand
        image(imgLeftHand,
              leftHandPosBuf.x-iconSize/2,
              leftHandPosBuf.y-iconSize/2,
              iconSize,
              iconSize);

        //check MenuMode and MakeCharMode
        if(PVector.dist(rightHandPosBuf,leftHandPosBuf) < lenMakeTrigger){
            makeCharFlag = true;

            makeCharPoint.set(rightHandPosBuf);

            
        }
        else if(abs(rightHandPosBuf.z-torsoPos.z) > lenMenuTrigger){
            menuFlag = true;
            menuPoint.set(rightHandPosBuf);
        }
    }
    else if(menuFlag){

        if(abs(rightHandPosBuf.z-torsoPos.z) < lenMenuTrigger)
            menuFlag = false;

        //print image on right hand
        image(imgMenu,
              menuPoint.x-menuSize/2,
              menuPoint.y-menuSize/2,
              menuSize,
              menuSize);
    }
    else if(makeCharFlag){
        int iconExpandSize = (int)PVector.dist(rightHandPosBuf,leftHandPosBuf)-iconSize;
        float rotateAngle = degrees(abs(atan2(leftHandPosBuf.x-rightHandPosBuf.x,leftHandPosBuf.y-rightHandPosBuf.y)));
        
        if(iconExpandSize < 70)
            iconExpandSize = iconSize;

        if(50 >= rotateAngle){
            columnCharTable = 0;
            iconRotate = -150;
        }
        else if(80 >= rotateAngle){
            columnCharTable = 1;
            iconRotate = -75;
        }
        else if(100 >= rotateAngle){
            columnCharTable = 2;
            iconRotate = 0;
        }
        else if(120 >= rotateAngle){
            columnCharTable = 3;
            iconRotate = 75;
        }
        else {
            columnCharTable = 4;
            iconRotate = 150;
        }

        if(iconExpandSize < 110){
            rowCharTable = 0;
        }
        else if(iconExpandSize < 150){
            rowCharTable = 1;
        }
        else if(iconExpandSize < 180){
            rowCharTable = 2;
        }
        else if(iconExpandSize < 210){
            rowCharTable = 3;
        }
        else if(iconExpandSize < 240){
            rowCharTable = 4;
        }
        else if(iconExpandSize < 270){
            rowCharTable = 5;
        }
        else if(iconExpandSize < 300){
            rowCharTable = 6;
        }
        else if(iconExpandSize < 330){
            rowCharTable = 7;
        }
        else if(iconExpandSize < 360){
            rowCharTable = 8;
        }
        else{
            rowCharTable = 9;
        }

        //print star image
        image(imgLeftHand,
              makeCharPoint.x-iconExpandSize/2,
              makeCharPoint.y-iconExpandSize/2,
              iconExpandSize,
              iconExpandSize);


        //print arrow image
        pushMatrix();
        translate(makeCharPoint.x, makeCharPoint.y);
        rotate(radians(iconRotate));
        translate(-(makeCharPoint.x), -(makeCharPoint.y));
        image(imgRightHand,
              makeCharPoint.x-iconExpandSize/2,
              makeCharPoint.y-iconExpandSize/2,
              iconExpandSize,
              iconExpandSize);
        popMatrix();

        //text output
        textSize(iconExpandSize-60);
        String AAA = Integer.toString(iconExpandSize);
        float fontHeight = textDescent()-textAscent();

        text(kanaTable[rowCharTable][columnCharTable],makeCharPoint.x,makeCharPoint.y+textDescent());

        //deside Char
        if(abs(rightHandPosBuf.z-torsoPos.z) > lenMenuTrigger)
            makeCharFlag = false;
    }
}

//------------------------------------------------------------------
// Key Event

void keyPressed() {
    if (key == CODED) {
        switch (keyCode) {
        case UP :
            {
                if(--columnCharTable < 0)
                    columnCharTable = 0;
                break;
            }
        case DOWN :
            {
                if(++columnCharTable > 4)
                    columnCharTable = 4;
                break;
            }
        case RIGHT :
            {
                if(++rowCharTable > 9)
                    rowCharTable = 9;
                break;
            }
        case LEFT :
            {
                if(--rowCharTable < 0)
                    rowCharTable = 0;
                break;
            }
        }
    }
    else{
        if (key == 'r'){
            makeCharFlag = false;
            menuFlag = false;
            demoFlag = false;
            jumpFlag = false;
            println("reset!!");
        }
    }
}



// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
    

    println("onNewUser - userId: " + userId);
    println("  start pose detection");
    
    
    if(autoCalib)
        context.requestCalibrationSkeleton(userId,true);
    else    
        context.startPoseDetection("Psi",userId);
}

void onLostUser(int userId)
{
    println("onLostUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
    println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
    println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
    if (successfull)
        {
            println("  User calibrated !!!");
            context.startTrackingSkeleton(userId);
        }
    else 
        {
            println("  Failed to calibrate user !!!");
            println("  Start pose detection");
            context.startPoseDetection("Psi",userId);
        }
}

void onStartPose(String pose,int userId)
{
    println("onStartPose - userId: " + userId + ", pose: " + pose);
    println(" stop pose detection");
  
    context.stopPoseDetection(userId); 
    context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose,int userId)
{
    println("onEndPose - userId: " + userId + ", pose: " + pose);
}





/*なにかにつかうかもしれないゴミ
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
    */