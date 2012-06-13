public class Menu {
    int coreSize = 200;
    int menuSize = int(coreSize/1.618);
    PVector menuMakePoint;
    PImage imgMenu;
    boolean visibleFlag;
    boolean openFlag;
    CircleButton upMenu, downMenu, rightMenu, leftMenu, coreMenu;
    int stepCount = 0;
    int stepSize = 15;

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
        
        openFlag = false;
        visibleFlag = false;
        this.imgMenu = loadImage("menu.png");
    }

    Menu(){
        menuMakePoint = new PVector(300,300,0);
        initMenu();
    }

    Menu(PVector v){
        menuMakePoint = new PVector();
        menuMakePoint.set(v);
        initMenu();
    }

    void visible(boolean flag){
        visibleFlag = flag;
    }

    void update()
    {
        if(visibleFlag){
            if(locked == false) {
                if(upMenu.update())
                    println("OK!");
                
                downMenu.update();
                rightMenu.update();
                leftMenu.update();
                coreMenu.update();
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
            if(stepCount != diff){
                stepCount += stepSize;
            
                if(stepCount > diff){
                    stepCount = diff;
                    openFlag = true;
                }
            }
        }
        else{
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
            upMenu.display();
            downMenu.display();
            rightMenu.display();
            leftMenu.display();
        }
         
        if(openFlag || visibleFlag){
            coreMenu.display();
        } 
    }
}