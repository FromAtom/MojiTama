import processing.core.*; 
import processing.xml.*; 

import SimpleOpenNI.*; 
import fullscreen.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class MojiTama extends PApplet {

/*
\u5f53\u9762\u306e\u4e88\u5b9a
---------------------------------------------------
\u30fb\u5404\u7a2e\u30e2\u30b8\u30e5\u30fc\u30eb\u306e\u95a2\u6570\u5316\uff08\u6bd4\u8f03\u7cfb\u304c\u3067\u304b\u3059\u304e\u3066\u90aa\u9b54\uff09
\u30fb\u3061\u304f\u308a\u3093\u304c\u4f5c\u3063\u3066\u304f\u308c\u305fHTML\u5bfe\u5fdc\u30d5\u30a1\u30a4\u30eb\u51e6\u7406\u3078\u306e\u5bfe\u5fdc
\u30fb\u5165\u529b\u30df\u30b9\u304c\u591a\u3044\u306e\u3067\u3001UI\u3092\u5feb\u9069\u306b\u3059\u308b\u3002\u30ac\u30a4\u30c9\u8868\u793a\uff1f
\u30fb\u753b\u50cf\u62e1\u5927\u306e\u30b9\u30e0\u30fc\u30b8\u30f3\u30b0\u51e6\u7406
\u30fb\u6587\u5b57\u8868\u793a\u90e8\u306e\u62e1\u5927\u51e6\u7406
\u30fb\u4ed6\u306e\u30e1\u30cb\u30e5\u30fc\u6a5f\u80fd\u5b9f\u88c5
\u30fb
*/




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
float iconRotate = 0.0f;
int iconSize = 70;
int menuSize = 300;

/*flags*/
boolean makeCharFlag = false;
boolean menuFlag = false;
boolean demoFlag = false;
boolean jumpFlag = false;

//foots
boolean komojiFlag = false;
boolean dakutenFlag = false;
boolean handakuFlag = false;


/*Fonts*/
PFont myFont;

/*for FullScreen*/
FullScreen fs;


/*defines*/
final int lenMenuTrigger = 370; //for compare torso and hands
final int lenMakeTrigger = 70;  //for compare hands
final int lenFootTrigger = 150;  //for change character table


/*for use File IO*/
useFile outputFile;

/*char table*/
final char[][] kanaTable= {
    {'\u3042','\u3044','\u3046','\u3048','\u304a'},
    {'\u304b','\u304d','\u304f','\u3051','\u3053'},
    {'\u3055','\u3057','\u3059','\u305b','\u305d'},
    {'\u305f','\u3061','\u3064','\u3066','\u3068'},
    {'\u306a','\u306b','\u306c','\u306d','\u306e'},
    {'\u306f','\u3072','\u3075','\u3078','\u307b'},
    {'\u307e','\u307f','\u3080','\u3081','\u3082'},
    {'\u3084','\u3084','\u3086','\u3088','\u3088'},
    {'\u3089','\u308a','\u308b','\u308c','\u308d'},
    {'\u308f','\u3092','\u3093','\u3001','\u3002'}
};

final char[][] komojiTable= {
    {'\u3041','\u3043','\u3045','\u3047','\u3049'},
    {'\u304b','\u304d','\u304f','\u3051','\u3053'},
    {'\u3055','\u3057','\u3059','\u305b','\u305d'},
    {'\u305f','\u3061','\u3063','\u3066','\u3068'},
    {'\u306a','\u306b','\u306c','\u306d','\u306e'},
    {'\u306f','\u3072','\u3075','\u3078','\u307b'},
    {'\u307e','\u307f','\u3080','\u3081','\u3082'},
    {'\u3083','\u3083','\u3085','\u3087','\u3087'},
    {'\u3089','\u308a','\u308b','\u308c','\u308d'},
    {'\u308f','\u3092','\u3093','\u3001','\u3002'}
};

final char[][] dakutenTable= {
    {'\u3042','\u3044','\u3046','\u3048','\u304a'},
    {'\u304c','\u304e','\u3050','\u3052','\u3054'},
    {'\u3056','\u3058','\u305a','\u305c','\u305e'},
    {'\u3060','\u3062','\u3065','\u3067','\u3069'},
    {'\u306a','\u306b','\u306c','\u306d','\u306e'},
    {'\u3070','\u3073','\u3076','\u3079','\u307c'},
    {'\u307e','\u307f','\u3080','\u3081','\u3082'},
    {'\u3084','\u3084','\u3086','\u3088','\u3088'},
    {'\u3089','\u308a','\u308b','\u308c','\u308d'},
    {'\u308f','\u3092','\u3093','\u3001','\u3002'}
};


final char[][] handakuTable= {
    {'\u3042','\u3044','\u3046','\u3048','\u304a'},
    {'\u304b','\u304d','\u304f','\u3051','\u3053'},
    {'\u3055','\u3057','\u3059','\u305b','\u305d'},
    {'\u305f','\u3061','\u3064','\u3066','\u3068'},
    {'\u306a','\u306b','\u306c','\u306d','\u306e'},
    {'\u3071','\u3074','\u3077','\u307a','\u307d'},
    {'\u307e','\u307f','\u3080','\u3081','\u3082'},
    {'\u3084','\u3084','\u3086','\u3088','\u3088'},
    {'\u3089','\u308a','\u308b','\u308c','\u308d'},
    {'\u308f','\u3092','\u3093','\u3001','\u3002'}
};


/*char table*/
int rowCharTable = 0;
int columnCharTable = 0;

/*input String buffer*/
String inputBuffer = "";


public void setup()
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
    if(context.enableRGB(1280,1024,15) == false){
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

    //for use file
    outputFile = new useFile("demo.txt");

    background(0);
    smooth();
    frameRate(30);
    size(context.rgbWidth(), context.rgbHeight());
    fs.setResolution(width, height);

    //fs.enter();
}


public void draw()
{
    background(0);

    // update the cam
    context.update();

    noStroke();

    /*
    PImage  rgbImage = context.rgbImage();
    int d = 10; //\u5186\u306e\u76f4\u5f84\u3092\u5b9a\u7fa9
    
    // \u30e9\u30a4\u30d6\u30ab\u30e1\u30e9\u306e\u6620\u50cf\u304b\u3089\u3001\u5186\u306e\u76f4\u5f84\u306e\u9593\u9694\u3054\u3068\u306b\u3001\u8272\u60c5\u5831\u3092\u53d6\u5f97\u3057\u3001\u305d\u306e\u8272\u3067\u5186\u3092\u63cf\u304f
    for(int y = d / 2 ; y < context.rgbHeight() ; y += d) {
        for(int x = d / 2 ; x < context.rgbWidth() ; x += d) {
            fill(rgbImage.pixels[y*context.rgbWidth() + x]);
            ellipse(x, y, d, d);
        }
    }
    */

    //RGB image
    image(context.rgbImage(), 0, 0);
    
    //print bubble image
    image(imgBubble, 10, 10,imgBubble.width-20,imgBubble.height-20);
    
    textSize(28);
    fill(0);
    textAlign(LEFT);
    text(inputBuffer,30,42);
    
    //some icon
    if(context.isTrackingSkeleton(1))
        drawSkeleton(1);
}

public void stop()
{
    outputFile.closeFile();
    super.stop();
}


//\u3044\u3044\u52a0\u6e1b\u95a2\u6570\u540d\u3092\u5909\u3048\u308b\u3079\u304d
public void drawSkeleton(int userId)
{
    //get & convert some position
    
    //right hand position
    PVector rightHand = new PVector();
    PVector rightHandPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
    context.convertRealWorldToProjective(rightHand,rightHandPos);
    convertVGAtoSXGA(rightHandPos);

    //left hand position
    PVector leftHand = new PVector();
    PVector leftHandPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
    context.convertRealWorldToProjective(leftHand,leftHandPos);
    convertVGAtoSXGA(leftHandPos);


    //torso position
    PVector torso = new PVector();
    PVector torsoPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,torso);
    context.convertRealWorldToProjective(torso,torsoPos);
    convertVGAtoSXGA(torsoPos);

    //right foot position
    PVector rightFoot = new PVector();
    PVector rightFootPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_FOOT,rightFoot);
    context.convertRealWorldToProjective(rightFoot,rightFootPos);
    convertVGAtoSXGA(rightFootPos);

    //left foot position
    PVector leftFoot = new PVector();
    PVector leftFootPos = new PVector();
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_FOOT,leftFoot);
    context.convertRealWorldToProjective(leftFoot,leftFootPos);
    convertVGAtoSXGA(leftFootPos);


    //add in Buffer
    rightHandPosBuf.add(rightHandPos);
    leftHandPosBuf.add(leftHandPos);

    //calc average
    rightHandPosBuf.mult(0.5f);
    leftHandPosBuf.mult(0.5f);

    if(abs(rightFootPos.z-leftFootPos.z) > lenFootTrigger-20 && rightFootPos.z < leftFootPos.z){
        handakuFlag = true;

        
    }
    else if(abs(rightFootPos.z-torsoPos.z) > lenFootTrigger && rightFootPos.z > leftFootPos.z){
               dakutenFlag = true;
    }
    else{
        dakutenFlag = false;
        handakuFlag = false;
    }

    if(demoFlag){
        if((PVector.dist(rightHandPosBuf,leftHandPosBuf) > lenMakeTrigger) && (abs(rightHandPosBuf.z-torsoPos.z) < lenMenuTrigger)){
                demoFlag = false;
            }
    }
    else if(!makeCharFlag && !menuFlag){
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

        /*
        //print image on left hand
        image(imgLeftHand,
              leftFootPos.x-iconSize/2,
              leftFootPos.y-iconSize/2,
              iconSize,
              iconSize);

   //print image on right hand
        image(imgRightHand,
              rightFootPos.x-iconSize/2,
              rightFootPos.y-iconSize/2,
              iconSize,
              iconSize);
        */

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
        //\u30c7\u30e2\u7528\u306e\u304f\u305a\u51e6\u7406
        if(PVector.dist(rightHandPosBuf,menuPoint) > 320){
            if(menuPoint.y-rightHandPosBuf.y > 0){
                outputFile.writeFile(inputBuffer);
                demoFlag = true;
                menuFlag = false;
            }
            else{

                demoFlag = true;
                menuFlag = false;
                println("Cancel");
            }
        }
        //print image on right hand
        image(imgMenu,
              menuPoint.x-menuSize/2,
              menuPoint.y-menuSize/2,
              menuSize,
              menuSize);
    }
    else if(makeCharFlag){
        //--------------------------
        //\u3053\u306e\u4e2d\u95a2\u6570\u5316\u3057\u306a\u3044\u3068\u6b7b\u306c\u3002
        //--------------------------

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
        textAlign(CENTER);
        fill(255);


        //set character

        if(komojiFlag){
            text(komojiTable[rowCharTable][columnCharTable],makeCharPoint.x,makeCharPoint.y+textDescent());
            
            //deside Char
            if(abs(rightHandPosBuf.z-torsoPos.z) > lenMenuTrigger){
                inputBuffer = inputBuffer.concat(String.valueOf(komojiTable[rowCharTable][columnCharTable]));
                makeCharFlag = false;
                demoFlag = true;
            }
        }
        else if(dakutenFlag){
            text(dakutenTable[rowCharTable][columnCharTable],makeCharPoint.x,makeCharPoint.y+textDescent());

            //deside Char
            if(abs(rightHandPosBuf.z-torsoPos.z) > lenMenuTrigger){
                inputBuffer = inputBuffer.concat(String.valueOf(dakutenTable[rowCharTable][columnCharTable]));
                makeCharFlag = false;
                demoFlag = true;
            }
        }
        else if(handakuFlag){
            text(handakuTable[rowCharTable][columnCharTable],makeCharPoint.x,makeCharPoint.y+textDescent());

            //deside Char
            if(abs(rightHandPosBuf.z-torsoPos.z) > lenMenuTrigger){
                inputBuffer = inputBuffer.concat(String.valueOf(handakuTable[rowCharTable][columnCharTable]));
                makeCharFlag = false;
                demoFlag = true;
            }
        }
        else{
            text(kanaTable[rowCharTable][columnCharTable],makeCharPoint.x,makeCharPoint.y+textDescent());
            
            //deside Char
            if(abs(rightHandPosBuf.z-torsoPos.z) > lenMenuTrigger){
                inputBuffer = inputBuffer.concat(String.valueOf(kanaTable[rowCharTable][columnCharTable]));
                makeCharFlag = false;
                demoFlag = true;
            }
        }
    }
}

//convert 640x480 to 1280x1024
public void convertVGAtoSXGA(PVector v){
    v.x = (v.x/640.0f)*1280;
    v.y = (v.y/480.0f)*1024;
}


//------------------------------------------------------------------
// Key Event

public void keyPressed() {
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
            inputBuffer = "";
            println("reset!!");
        }
    }
}



// -----------------------------------------------------------------
// SimpleOpenNI events

public void onNewUser(int userId)
{
    println("onNewUser - userId: " + userId);
    println("  start pose detection");
    
    
    if(autoCalib)
        context.requestCalibrationSkeleton(userId,true);
    else    
        context.startPoseDetection("Psi",userId);
}

public void onLostUser(int userId)
{
    println("onLostUser - userId: " + userId);
}

public void onStartCalibration(int userId)
{
    println("onStartCalibration - userId: " + userId);
}

public void onEndCalibration(int userId, boolean successfull)
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

public void onStartPose(String pose,int userId)
{
    println("onStartPose - userId: " + userId + ", pose: " + pose);
    println(" stop pose detection");
  
    context.stopPoseDetection(userId); 
    context.requestCalibrationSkeleton(userId, true);
}

public void onEndPose(String pose,int userId)
{
    println("onEndPose - userId: " + userId + ", pose: " + pose);
}





/*\u306a\u306b\u304b\u306b\u3064\u304b\u3046\u304b\u3082\u3057\u308c\u306a\u3044\u30b4\u30df
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
public class useFile{
    PrintWriter output;
    String filename;
    
    useFile(String init_filename){//\u521d\u671f\u5316\u7528\u30e1\u30bd\u30c3\u30c9
        output = createWriter(init_filename);
        filename = init_filename;
    }
    
    public void writeFile(String outputString){
        output.println(outputString);
        output.flush();
    }//end writeFile()
    
    public void closeFile(){
        output.close();
    }//end closeFile()
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "MojiTama" });
  }
}
