public class myColorMenu {
    int coreSize = 200;
    int menuSize = int(coreSize/1.618);
    PVector menuMakePoint;

    boolean visibleFlag;
    boolean openFlag;

    CircleButton blackMenu, redMenu, blueMenu, greenMenu, yellowMenu, whiteMenu, coreMenu;
    //boolean upFlag,downFlag,rightFlag,leftFlag;

    int stepCount = 0;
    int stepSize = 45;
    int rotateCount = -180;
    int rotateDeg = 35;

    int mx;
    int my;
    int diff = (coreSize/2+menuSize/2)+10;

    AudioPlayer menuSound;
    AudioPlayer select;

    private void initMenu(){
        mx = int(menuMakePoint.x);
        my = int(menuMakePoint.y);

        coreMenu = new CircleButton(mx, my, coreSize, buttoncolor, highlight);
        redMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);
        blueMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);
        greenMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);
        yellowMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);
        whiteMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);
        blackMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);

        openFlag = false;
        visibleFlag = false;

        select = minim.loadFile("select.mp3",2048);
        menuSound = minim.loadFile("menu.mp3",2048);
        menuSound.play(0);
    }

    myColorMenu(){
        menuMakePoint = new PVector(300,300,0);
        initMenu();
    }

    myColorMenu(PVector v){
        menuMakePoint = new PVector();
        menuMakePoint.set(v);
        initMenu();
    }

    void visible(boolean flag){
        visibleFlag = flag;
    }

    void update()
    {
        if(visibleFlag && openFlag){
            if(locked == false) {
                if(blackMenu.update()){
                    fontColor = COLOR_BLACK;
                    visibleFlag = false;
                }

                if(redMenu.update()){
                    fontColor = COLOR_RED;
                    visibleFlag = false;
                }

                if(blueMenu.update()){
                    fontColor = COLOR_BLUE;
                    visibleFlag = false;
                }

                if(greenMenu.update()){
                    fontColor = COLOR_GREEN;
                    visibleFlag = false;
                }

                if(yellowMenu.update()){
                    fontColor = COLOR_YELLOW;
                    visibleFlag = false;
                }

                if(whiteMenu.update()){
                    fontColor = COLOR_WHITE;
                    visibleFlag = false;
                }

                //coreMenu.update();
            }
            else {
                locked = false;
            }
        }


    }


    void reflesh(){
        if(visibleFlag){
            if(rotateCount != 0){
                rotateCount += rotateDeg;
                if(rotateCount >= 0)
                    rotateCount = 0;
            }

            if(stepCount != diff){
                stepCount += stepSize;
                
                if(stepCount >= diff){
                    stepCount = diff;
                    openFlag = true;
                }
            }
        }
        else{
            if(rotateCount != -180){
                rotateCount -= rotateDeg;
                if(rotateCount <= -180)
                    rotateCount = -180;
            }

            if(stepCount != 0){
                stepCount -= stepSize;
                if(stepCount <= 0){
                    stepCount = 0;
                    openFlag = false;
                }
            }
        }
        
        blackMenu.setPosition(int(mx-stepCount*cos(radians(rotateCount))),
                            int(my-stepCount*sin(radians(rotateCount))));

        redMenu.setPosition(int(mx-stepCount*cos(radians(rotateCount+60))),
                            int(my-stepCount*sin(radians(rotateCount+60))));

        blueMenu.setPosition(int(mx-stepCount*cos(radians(rotateCount+120))),
                            int(my-stepCount*sin(radians(rotateCount+120))));

        greenMenu.setPosition(int(mx-stepCount*cos(radians(rotateCount+180))),
                              int(my-stepCount*sin(radians(rotateCount+180))));
        
        yellowMenu.setPosition(int(mx-stepCount*cos(radians(rotateCount+240))),
                            int(my-stepCount*sin(radians(rotateCount+240))));

        whiteMenu.setPosition(int(mx-stepCount*cos(radians(rotateCount+300))),
                            int(my-stepCount*sin(radians(rotateCount+300))));


        update();
        display();
    }

    void display(){
        if(openFlag || visibleFlag){
            blackMenu.display(imgBlack);
            redMenu.display(imgRed);
            blueMenu.display(imgBlue);
            greenMenu.display(imgGreen);
            yellowMenu.display(imgYellow);
            whiteMenu.display(imgWhite);
        }
         
        if(openFlag || visibleFlag){
            coreMenu.display(imgCore);
        }
    }
}