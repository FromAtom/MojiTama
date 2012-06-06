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

final char[][] komojiTable= {
    {'ぁ','ぃ','ぅ','ぇ','ぉ'},
    {'か','き','く','け','こ'},
    {'さ','し','す','せ','そ'},
    {'た','ち','っ','て','と'},
    {'な','に','ぬ','ね','の'},
    {'は','ひ','ふ','へ','ほ'},
    {'ま','み','む','め','も'},
    {'ゃ','ゃ','ゅ','ょ','ょ'},
    {'ら','り','る','れ','ろ'},
    {'わ','を','ん','、','。'}
};

final char[][] dakutenTable= {
    {'あ','い','う','え','お'},
    {'が','ぎ','ぐ','げ','ご'},
    {'ざ','じ','ず','ぜ','ぞ'},
    {'だ','ぢ','づ','で','ど'},
    {'な','に','ぬ','ね','の'},
    {'ば','び','ぶ','べ','ぼ'},
    {'ま','み','む','め','も'},
    {'や','や','ゆ','よ','よ'},
    {'ら','り','る','れ','ろ'},
    {'わ','を','ん','、','。'}
};


final char[][] handakuTable= {
    {'あ','い','う','え','お'},
    {'か','き','く','け','こ'},
    {'さ','し','す','せ','そ'},
    {'た','ち','つ','て','と'},
    {'な','に','ぬ','ね','の'},
    {'ぱ','ぴ','ぷ','ぺ','ぽ'},
    {'ま','み','む','め','も'},
    {'や','や','ゆ','よ','よ'},
    {'ら','り','る','れ','ろ'},
    {'わ','を','ん','、','。'}
};


/*char table*/
int rowCharTable = 0;
int columnCharTable = 0;

/*input String buffer*/
String inputBuffer = "";


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
    
    textSize(28);
    fill(0);
    textAlign(LEFT);
    text(inputBuffer,30,42);
    
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
        //デモ用のくず処理
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
        //この中関数化しないと死ぬ。
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
void convertVGAtoSXGA(PVector v){
    v.x = (v.x/640.0)*1280;
    v.y = (v.y/480.0)*1024;
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
            inputBuffer = "";
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