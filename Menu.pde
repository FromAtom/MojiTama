public class Menu {
    int coreSize = 140;
    int menuSize = int(coreSize/1.618);
    PVector menuMakePoint;
    PImage imgMenu;
    boolean visibleFlag;
    boolean openFlag;
    CircleButton upMenu, downMenu, rightMenu, leftMenu, coreMenu;
    int stepCount = 0;
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
        if(locked == false) {
            upMenu.update();
            downMenu.update();
            rightMenu.update();
            leftMenu.update();
            coreMenu.update();
        }
        else {
            locked = false;
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
            openFlag = true;
            stepCount += 10;
            if(stepCount > diff){
                stepCount = diff;
            }
        }
        else{
            stepCount -= 10;
            if(stepCount <= 0){
                stepCount = 0;
                openFlag = false;
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
        if(openFlag){
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