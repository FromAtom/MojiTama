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
import processing.net.*;
import ddf.minim.*;

//--------------------------------------------------------------
/*defines*/
final int lenMenuTrigger = 430; //for compare torso and hands
final int lenMakeCharTrigger = 400;
final int lenMakeTrigger = 100;  //for compare hands
final int lenFootTrigger = 150;  //for change character table


/*for fonts*/

//colors
final int COLOR_BLACK = 0;
final int COLOR_RED = 1;
final int COLOR_BLUE = 2;
final int COLOR_GREEN = 3;
final int COLOR_YELLOW = 4;
final int COLOR_WHITE = 5;
final int COLOR_NUM = 6;   //COLOR数
final String COLOR_NAME[] = {
    "#000000", "#ff0000", "#0000ff", "#00ff00", "#ffff00", "#ffffff"
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


/*chat mode (SERVER or CLIENT)*/
final int MODE_SERVER = 0;
final int MODE_CLIENT = 1;

/*Size of images*/
final int iconSize = 200;
final int menuSize = 300;

//--------------------------------------------------------------



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
boolean subMenuFlag = false;
boolean demoFlag = false;
boolean jumpFlag = false;
boolean chatFlag = false;

//foots
boolean komojiFlag = false;
boolean dakutenFlag = false;
boolean handakuFlag = false;

//fonts
boolean boldFlag = false;
int fontColor = COLOR_WHITE;
int fontType = FONT_GOTHIC;
int fontSize = FONT_SIZE_NORMAL;

//---------------------------------chikurin
//del flag
boolean delFlag = false;
boolean delAllFlag = false;
//---------------------------------/chikurin

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
String inputBuffer = "";


/*for menu*/
myMenu menu;
boolean locked = false;
color buttoncolor = color(244);
color highlight = color(153);
color currentcolor;
color timecolor = #FF9200;
PImage imgCore,imgUp,imgDown,imgRight,imgLeft;
PImage imgSize,imgType,imgColor,imgBold;

mySubMenu submenu;

/*for chat*/
myChat chat;


/*for SE*/
Minim minim;
AudioPlayer makeSound;
AudioPlayer openSound_1;
AudioPlayer openSound_2;
AudioPlayer pushSound;
AudioPlayer rotateSound;
AudioPlayer overSound;
AudioPlayer one_delete;
AudioPlayer all_delete;
AudioPlayer footSound;

int rowNumBuf = 0;
int columnNumBuf = 0;

//---------------------------------chikurin
myChatField chatField;
//---------------------------------/chikurin

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

    
    this.imgCore = loadImage("core.png");
    this.imgRight = loadImage("chat.png");
    this.imgLeft = loadImage("setting.png");
    this.imgUp = loadImage("save.png");
    this.imgDown = loadImage("cancel.png");

    this.imgType = loadImage("type.png");
    this.imgColor = loadImage("color.png");
    this.imgSize = loadImage("size.png");
    this.imgBold = loadImage("bold.png");


    minim = new Minim(this);
    makeSound = minim.loadFile("makeSound.mp3", 2048);
    openSound_1 = minim.loadFile("openSound1.mp3", 2048);
    openSound_2 = minim.loadFile("openSound2.mp3", 2048);
    pushSound = minim.loadFile("push.mp3", 2048);
    rotateSound = minim.loadFile("rotate.mp3",2048);
    all_delete = minim.loadFile("all_delete.mp3",2048);
    one_delete = minim.loadFile("one_delete.mp3",2048);
    overSound = minim.loadFile("over.mp3",2048);
    footSound = minim.loadFile("foot.mp3",2048);
    
    
    //chat = new myChat(this);
    //fs.enter();
    
    //---------------------------------chikurin
    chatField = new myChatField();
    //---------------------------------/chikurin
}


void draw()
{
    background(0);
    noStroke();

    // update the cam
    context.update();

    //RGB image
    image(context.rgbImage(), 0, 0);
    
    //print bubble image
    image(imgBubble, 20, 20,imgBubble.width-20,imgBubble.height-20);

    if(fontSize == FONT_SIZE_NORMAL){
        textSize(64);
    }
    else if(fontSize > FONT_SIZE_NORMAL){
        textSize(110);
    }
    else{
        textSize(32);
    }

    String c = "FF" + COLOR_NAME[fontColor].substring(1);
    fill(unhex(c));
    textAlign(LEFT);
    text(inputBuffer,70,110);
    
    if(menuFlag)
        menu.reflesh();

    if(subMenuFlag)
        submenu.reflesh();

    
    //some icon
    if(context.isTrackingSkeleton(1))
        drawSkeleton(1);
        
    //---------------------------------chikurin
    chatField.reflesh();
    //---------------------------------/chikurin
}

void stop()
{
    if(chatFlag)
        chat.myClient.stop();

    outputFile.closeFile();
    super.stop();
}

//いい加減関数名を変えるべき
void drawSkeleton(int userId)
{
    //get & convert some position
    
    /*
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
    */


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
    context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,torso);
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
    rightHandPosBuf.set(rightHandPos);
    leftHandPosBuf.set(leftHandPos);



    //print image on left hand
    image(imgLeftHand,
          torsoPos.x-iconSize/4,
          torsoPos.y-iconSize/4,
          iconSize/2,
          iconSize/2);



    //---------------------------------chikurin
    //println("left:" + leftHandPosBuf.x);
    //println("torso:" + torsoPos.x);
    
    //one character clear from ibuffer
    if(menuFlag == false && makeCharFlag == false){
            if(abs(leftHandPos.x-torsoPos.x) > 270){
                if(delFlag == false){
                    clear_ibuffer();
                    one_delete.play(0);
                }
                delFlag = true;
            }else if(abs(leftHandPos.x-torsoPos.x) <100){
                delFlag = false;
            }
    }else if(makeCharFlag){
        delFlag = true;
    }
    //all character clear from ibuffer
    if(menuFlag == false && makeCharFlag == false){
        if(abs(rightHandPos.x-torsoPos.x) > 270){
            if(delAllFlag == false){
                clearAll_ibuffer();
                all_delete.play(0);
            }
            delAllFlag = true;
        }else if(abs(rightHandPos.x-torsoPos.x) < 100){
            delAllFlag = false;
        }
    }else if(makeCharFlag){
        delAllFlag = true;
    }
    //---------------------------------/chikurin

    if(abs(rightFootPos.z-leftFootPos.z) > lenFootTrigger && rightFootPos.z < leftFootPos.z){
        if(handakuFlag == false)
            footSound.play(0);

        handakuFlag = true;
    }
    else if(abs(rightFootPos.z-leftFootPos.z) > lenFootTrigger && rightFootPos.z > leftFootPos.z){
        if(dakutenFlag == false)
            footSound.play(0);
        dakutenFlag = true;
    }
    else{
        if(dakutenFlag || handakuFlag)
            footSound.play(0);
        dakutenFlag = false;
        handakuFlag = false;
    }

    if(demoFlag){
        if((PVector.dist(rightHandPosBuf,leftHandPosBuf) > lenMakeTrigger) && (abs(rightHandPosBuf.z-torsoPos.z) < lenMakeCharTrigger)){
            demoFlag = false;
        }
    }
    else if(menuFlag){
        if(PVector.dist(rightHandPosBuf,menuPoint) > lenMenuTrigger){
            menu.visible(false);

            if(menu.openFlag == false){
                if(menu.upFlag){
                    outputFile.writeFile(inputBuffer);
                }
                else if(menu.downFlag){
                    println("down!");
                }
                else if(menu.rightFlag){
                    chatFlag = true;
                    println("チャットモードを起動しています！");
                }
                else if(menu.leftFlag){
                    submenu = new mySubMenu(menuPoint);
                    submenu.visible(true);
                    subMenuFlag = true;
                    
                }
                menuFlag = false;
            }
        }

        
        /*
          if(menu.openFlag == false && menu.visibleFlag == false){
            
          }*/
    }
    else if(subMenuFlag){
        println("sub!");
        if(PVector.dist(rightHandPosBuf,menuPoint) > lenMenuTrigger){
            submenu.visible(false);
        }
        if(submenu.openFlag == false && submenu.visibleFlag == false){
            subMenuFlag = false;
        }
    }
    else if(makeCharFlag){
        // makeCharPoint.set(leftHandPosBuf.x+abs(rightHandPosBuf.x-leftHandPosBuf.x)/2,
        // leftHandPosBuf.y+abs(rightHandPosBuf.y-leftHandPosBuf.y)/2,
        //                0);


        int iconExpandSize = (int)PVector.dist(rightHandPosBuf,leftHandPosBuf);
        float rotateAngle = degrees(abs(atan2(leftHandPosBuf.x-rightHandPosBuf.x,leftHandPosBuf.y-rightHandPosBuf.y)));
        
        /*
          if(iconExpandSize < 70)
          iconExpandSize = iconSize;
        */
        //print star image
        image(imgLeftHand,
              makeCharPoint.x-iconExpandSize/2,
              makeCharPoint.y-iconExpandSize/2,
              iconExpandSize,
              iconExpandSize);

        int rowCharTable = convertRangeToRowNum(iconExpandSize);
        int columnCharTable = convertAngleToColumnNum(rotateAngle);
        float iconRotate = convertAngleToIconAngle(rotateAngle);

        if(rowNumBuf < rowCharTable)
            openSound_2.play(0);
        else if(rowNumBuf > rowCharTable)
            openSound_1.play(0);

        if(columnNumBuf != columnCharTable)
            rotateSound.play(0);

        rowNumBuf = rowCharTable;
        columnNumBuf = columnCharTable;

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
            if(abs(rightHandPosBuf.z-torsoPos.z) > lenMakeCharTrigger){
                inputBuffer = inputBuffer.concat(String.valueOf(komojiTable[rowCharTable][columnCharTable]));
                makeCharFlag = false;
                demoFlag = true;
            }
        }
        else if(dakutenFlag){
            text(dakutenTable[rowCharTable][columnCharTable],makeCharPoint.x,makeCharPoint.y+textDescent());

            //deside Char
            if(abs(rightHandPosBuf.z-torsoPos.z) > lenMakeCharTrigger){
                pushSound.play(0);
                inputBuffer = inputBuffer.concat(String.valueOf(dakutenTable[rowCharTable][columnCharTable]));
                makeCharFlag = false;
                demoFlag = true;
            }
        }
        else if(handakuFlag){
            text(handakuTable[rowCharTable][columnCharTable],makeCharPoint.x,makeCharPoint.y+textDescent());

            //deside Char
            if(abs(rightHandPosBuf.z-torsoPos.z) > lenMakeCharTrigger){
                pushSound.play(0);
                inputBuffer = inputBuffer.concat(String.valueOf(handakuTable[rowCharTable][columnCharTable]));
                makeCharFlag = false;
                demoFlag = true;
            }
        }
        else{
            //text(Integer.toString(iconExpandSize),makeCharPoint.x,makeCharPoint.y+textDescent());
            text(kanaTable[rowCharTable][columnCharTable],makeCharPoint.x,makeCharPoint.y+textDescent());
            
            //deside Char
            if(abs(rightHandPosBuf.z-torsoPos.z) > lenMakeCharTrigger){
                pushSound.play(0);
                inputBuffer = inputBuffer.concat(String.valueOf(kanaTable[rowCharTable][columnCharTable]));
                makeCharFlag = false;
                demoFlag = true;
            }
        }
    }
    else{
        //print image on left hand
        image(imgLeftHand,
              leftHandPosBuf.x-iconSize/2,
              leftHandPosBuf.y-iconSize/2,
              iconSize,
              iconSize);
        
        //print image on right hand
        image(imgRightHand,
              rightHandPosBuf.x-iconSize/2,
              rightHandPosBuf.y-iconSize/2,
              iconSize,
              iconSize);
        
        
        
        //check MenuMode and MakeCharMode
        if(PVector.dist(rightHandPosBuf,leftHandPosBuf) < lenMakeTrigger){
            makeCharFlag = true;
            makeSound.play(0);
            makeCharPoint.set(rightHandPosBuf);
        }
        else if(abs(rightHandPosBuf.z-torsoPos.z) > lenMenuTrigger){
            menuPoint.set(rightHandPosBuf);
            /*
              submenu = new mySubMenu(menuPoint);
              submenu.visible(true);
              subMenuFlag = true;
            */
            
            menuFlag = true;
            menu = new myMenu(menuPoint);
            menu.visible(true);
         
            

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

    if(range < 100){
        rowNum = 0;
    }
    else if(range < 160){
        rowNum = 1;
    }
    else if(range < 220){
        rowNum = 2;
    }
    else if(range < 280){
        rowNum = 3;
    }
    else if(range < 340){
        rowNum = 4;
    }
    else if(range < 400){
        rowNum = 5;
    }
    else if(range < 460){
        rowNum = 6;
    }
    else if(range < 520){
        rowNum = 7;
    }
    else if(range < 580){
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
        }
        else if(key == 'a'){
            subMenuFlag = true;

            submenu.visible(true);
        }
        else if(key == 'z'){
            submenu.visible(false);
        }
        else if(key == 's'){
            chat.writeExString(inputBuffer,fontColor,fontType,fontSize,boldFlag);
        }
        //---------------------------------chikurin
        else if(key == 'd'){
            clear_ibuffer();
        }
        else if(key == 'e'){
            clearAll_ibuffer();
        }
        else if(key == 'p'){
            chatField.setMessage("あいうえおあああああああああああああああ");
        }
        
        //---------------------------------/chikurin
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


  else if(!makeCharFlag && !menuFlag && !subMenuFlag){
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
  menu = new myMenu(menuPoint);
  menu.visible(true);
  }
  }
*/

