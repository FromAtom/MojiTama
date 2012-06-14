public class myMenu {
    int coreSize = 200;
    int menuSize = int(coreSize/1.618);
    PVector menuMakePoint;

    boolean visibleFlag;
    boolean openFlag;

    CircleButton upMenu, downMenu, rightMenu, leftMenu, coreMenu;
    boolean upFlag,downFlag,rightFlag,leftFlag;

    int stepCount = 0;
    int stepSize = 45;
    int rotateCount = -180;
    int rotateDeg = 50;

    int mx;
    int my;
    int diff = (coreSize/2+menuSize/2)+10;


    private void initMenu(){
        mx = int(menuMakePoint.x);
        my = int(menuMakePoint.y);

        coreMenu = new CircleButton(mx, my, coreSize, buttoncolor, highlight);
        upMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);
        downMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);
        rightMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);
        leftMenu = new CircleButton(mx, my, menuSize, buttoncolor, highlight);

        upFlag = false;
        downFlag = false;
        rightFlag = false;
        leftFlag = false;

        openFlag = false;
        visibleFlag = false;

    }

    myMenu(){
        menuMakePoint = new PVector(300,300,0);
        initMenu();
    }

    myMenu(PVector v){
        menuMakePoint = new PVector();
        menuMakePoint.set(v);
        initMenu();
    }

    void visible(boolean flag){
        visibleFlag = flag;
    }

    void update()
    {
        if(visibleFlag&&openFlag){
            if(locked == false) {
                if(upMenu.update()){
                    visibleFlag = false;
                    upFlag = true;
                }

                if(downMenu.update()){
                    visibleFlag = false;
                    downFlag = true;
                }

                if(rightMenu.update()){
                    visibleFlag = false;
                    rightFlag = true;
                }

                if(leftMenu.update()){
                    visibleFlag = false;
                    leftFlag = true;
                }

                //coreMenu.update();
            }
            else {
                locked = false;
            }
        }


        if(mousePressed) {
            if(upMenu.pressed()) {
                currentcolor = upMenu.basecolor;
            }
            if(downMenu.pressed()) {
                currentcolor = downMenu.basecolor;
            }
            if(rightMenu.pressed()) {
                currentcolor = rightMenu.basecolor;
            }
            if(leftMenu.pressed()) {
                currentcolor = leftMenu.basecolor;
            }
            if(coreMenu.pressed()) {
                currentcolor = coreMenu.basecolor;
            }
            
        }
    }


    void reflesh(){
        if(visibleFlag){
            if(rotateCount != 0){
                rotateCount += rotateDeg;
                if(rotateCount > 0)
                    rotateCount = 0;
            }

            if(stepCount != diff){
                stepCount += stepSize;
                
                if(stepCount > diff){
                    stepCount = diff;
                    openFlag = true;
                }
            }
        }
        else{
            if(rotateCount != -90){
                rotateCount -= rotateDeg;
                if(rotateCount <= -90)
                    rotateCount = -90;
            }

            if(stepCount != 0){
                stepCount -= stepSize;
                if(stepCount <= 0){
                    stepCount = 0;
                    openFlag = false;
                }
            }
        }
        
        upMenu.setPosition(mx,my-stepCount);
        downMenu.setPosition(mx,my+stepCount);
        rightMenu.setPosition(mx+stepCount,my);
        leftMenu.setPosition(mx-stepCount,my);

        update();
        display();
    }

    void display(){
        if(openFlag || visibleFlag){

            pushMatrix();
            translate(mx, my);
            rotate(radians(rotateCount));
            translate(-(mx), -(my));
            upMenu.display(imgUp);
            downMenu.display(imgDown);
            rightMenu.display(imgRight);
            leftMenu.display(imgLeft);
            popMatrix();

           
        }
         
        if(openFlag || visibleFlag){
            coreMenu.display(imgCore);
        }
    }
}