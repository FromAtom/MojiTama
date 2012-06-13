/*
当面の予定
---------------------------------------------------
・各種モジュールの関数化（比較系がでかすぎて邪魔）
・ちくりんが作ってくれたHTML対応ファイル処理への対応
・入力ミスが多いので、UIを快適にする。ガイド表示？
・画像拡大のスムージング処理
・文字表示部の拡大処理
・他のメニュー機能実装
・
*/

import SimpleOpenNI.*;
import fullscreen.*;

//--------------------------------------------------------------
/*defines*/
final int lenMenuTrigger = 370; //for compare torso and hands
final int lenMakeTrigger = 70;  //for compare hands
final int lenFootTrigger = 150;  //for change character table


/*for fonts*/

//colors
final int COLOR_BLACK = 0;
final int COLOR_RED = 1;
final int COLOR_BLUE = 2;
final int COLOR_GREEN = 3;
final int COLOR_YELLOW = 4;
final int COLOR_NUM = 5;   //COLOR数
final String COLOR_NAME[] = {
    "#000000", "#ff0000", "#0000ff", "#00ff00", "#ffff00"
};

//types
final int FONT_MINCHO = 0;
final int FONT_GOTHIC = 1;
final int FONT_NUM = 2;   //FONT数
final String FONT_NAME[] = {
    "ＭＳ 明朝", "ＭＳ ゴシック"
};

//size
final int FONT_SIZE_BIG = 7;
final int FONT_SIZE_NORMAL = 3;
final int FONT_SIZE_SMALL = 1;

//--------------------------------------------------------------


/*Size of images*/
final int iconSize = 100;
final int menuSize = 300;

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



//---------------------------------
/*flags*/
boolean makeCharFlag = false;
boolean menuFlag = false;
boolean demoFlag = false;
boolean jumpFlag = false;

//foots
boolean komojiFlag = false;
boolean dakutenFlag = false;
boolean handakuFlag = false;

//fonts
boolean boldFlag = false;
int fontColor = COLOR_BLACK;
int fontType = FONT_GOTHIC;
int fontSize = FONT_SIZE_NORMAL;

//---------------------------------


/*Fonts*/
PFont myFont;

/*for FullScreen*/
FullScreen fs;


/*for use File IO*/
useFile outputFile;



/*char table*/

int columnCharTable = 0;

/*input String buffer*/
String inputBuffer = "ああああ";


Menu menu;
boolean locked = false;
color buttoncolor = color(204);
color highlight = color(153);
   
color currentcolor;


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

    println("hi!!");
    
    

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
    //imgMenu = loadImage("menu.png");

    
    // enable skeleton generation for all joints
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

    //mirror enable
    context.setMirror(true);

    //Load & Set Fonts
    myFont = loadFont("Migu-1P-Regular-48.vlw");
    textFont(myFont);

    //for use file
    outputFile = new useFile("demo.txt");

    colorMode(RGB);
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

    //RGB image
    image(context.rgbImage(), 0, 0);
    
    //print bubble image
    image(imgBubble, 10, 10,imgBubble.width-20,imgBubble.height-20);
    

    if(fontSize == FONT_SIZE_NORMAL){
        textSize(28);
    }
    else if(fontSize > FONT_SIZE_NORMAL){
        textSize(36);
    }
    else{
        textSize(18);
    }

    String c = "FF" + COLOR_NAME[fontColor].substring(1);
    fill(unhex(c));
    textAlign(LEFT);
    text(inputBuffer,30,42);
    
    if(menuFlag)
        menu.reflesh();

    //some icon
    if(context.isTrackingSkeleton(1))
        drawSkeleton(1);
}

void stop()
{
    outputFile.closeFile();
    super.stop();
}


//いい加減関数名を変えるべき
void drawSkeleton(int userId)
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
    rightHandPosBuf.mult(0.5);
    leftHandPosBuf.mult(0.5);

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

        //check MenuMode and MakeCharMode
        if(PVector.dist(rightHandPosBuf,leftHandPosBuf) < lenMakeTrigger){
            makeCharFlag = true;

            makeCharPoint.set(rightHandPosBuf);
        }
        else if(abs(rightHandPosBuf.z-torsoPos.z) > lenMenuTrigger){
            menuFlag = true;
            menuPoint.set(rightHandPosBuf);
            menu = new Menu(menuPoint);
            menu.visible(true);
        }
    }
    else if(menuFlag){
        if(PVector.dist(rightHandPosBuf,menuPoint) > lenMenuTrigger){
            menu.visible(false);

            if(menu.openFlag == false)
                menuFlag = false;
        }
    }
    else if(makeCharFlag){
        int iconExpandSize = (int)PVector.dist(rightHandPosBuf,leftHandPosBuf)-iconSize;
        float rotateAngle = degrees(abs(atan2(leftHandPosBuf.x-rightHandPosBuf.x,leftHandPosBuf.y-rightHandPosBuf.y)));
        
        if(iconExpandSize < 70)
            iconExpandSize = iconSize;

        //print star image
        image(imgLeftHand,
              makeCharPoint.x-iconExpandSize/2,
              makeCharPoint.y-iconExpandSize/2,
              iconExpandSize,
              iconExpandSize);

        int rowCharTable = convertRangeToRowNum(iconExpandSize);
        int columnCharTable = convertAngleToColumnNum(rotateAngle);
        float iconRotate = convertAngleToIconAngle(rotateAngle);

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


//convert Angle made by two hands to icons rotate angle
float convertAngleToIconAngle(float rotateAngle){
    float iconRotate;

    if(50 >= rotateAngle){
        iconRotate = -150;
    }
    else if(80 >= rotateAngle){
        iconRotate = -75;
    }
    else if(100 >= rotateAngle){
        iconRotate = 0;
    }
    else if(120 >= rotateAngle){
        iconRotate = 75;
    }
    else {
        iconRotate = 150;
    }

    return iconRotate;
}


//convert Angle made by two hands to column number
int convertAngleToColumnNum(float rotateAngle){
    int columnNum;

    if(50 >= rotateAngle){
        columnNum = 0;
    }
    else if(80 >= rotateAngle){
        columnNum = 1;
    }
    else if(100 >= rotateAngle){
        columnNum = 2;
    }
    else if(120 >= rotateAngle){
        columnNum = 3;
    }
    else {
        columnNum = 4;
    }

    return columnNum;
}


//convert Range of between two hands to row number
int convertRangeToRowNum(int range){
    int rowNum;

    if(range < 110){
        rowNum = 0;
    }
    else if(range < 150){
        rowNum = 1;
    }
    else if(range < 180){
        rowNum = 2;
    }
    else if(range < 210){
        rowNum = 3;
    }
    else if(range < 240){
        rowNum = 4;
    }
    else if(range < 270){
        rowNum = 5;
    }
    else if(range < 300){
        rowNum = 6;
    }
    else if(range < 330){
        rowNum = 7;
    }
    else if(range < 360){
        rowNum = 8;
    }
    else{
        rowNum = 9;
    }

    return rowNum;
}



//convert 640x480 to 1280x1024
void convertVGAtoSXGA(PVector v){
    v.x = (v.x/640.0)*1280.0;
    v.y = (v.y/480.0)*1024.0;
}


//------------------------------------------------------------------
// Key Event

void keyPressed() {
    if (key == CODED) {
        switch (keyCode) {
        case UP :
            {
                if(++fontSize >= FONT_SIZE_BIG){
                    fontSize = FONT_SIZE_BIG;
                }
                break;
            }
        case DOWN :
            {
                if(--fontSize <= FONT_SIZE_SMALL){
                    fontSize = FONT_SIZE_SMALL;
                }
                break;
            }
        case RIGHT :
            {
                if(++fontColor >= COLOR_NUM){
                    fontColor = COLOR_NUM-1;
                }
                break;
            }
        case LEFT :
            {
                if(--fontColor < 0){
                    fontColor = 0;
                }
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
        else if (key == 't'){
            if(fontType == FONT_GOTHIC)
                fontType = FONT_MINCHO;
            else
                fontType = FONT_GOTHIC;

            println(fontType);
            //font type
        }
        else if (key == 'b'){
            boldFlag = !boldFlag;
            println(boldFlag);
        }
        else if(key == 'a'){
            menu.visible(true);
        }
        else if(key == 's'){
            menu.visible(false);
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

