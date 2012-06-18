public class mySubMenu {
    int coreSize = 200;
    int menuSize = int(coreSize/1.618);
    int subMenuSize = menuSize;
    PVector menuMakePoint;
    
    boolean visibleFlag;
    boolean openFlag;
    boolean unfoldFlag;

    CircleButton leftMenu, coreMenu, sizeMenu, typeMenu, boldMenu;
    CircleButton gothicMenu,minchoMenu,thickMenu,fineMenu,bigMenu,middleMenu,smallMenu;

    boolean sizeFlag, typeFlag, boldFlag;

    int mx;
    int my;
    int diff = (coreSize/2+menuSize/2)+10;
    int diff_1 = ((coreSize/2)*2+menuSize/2)+10;
    int diff_2 = ((coreSize/2)*3+menuSize/2)+10;
    int diff_3 = ((coreSize/2)*4+menuSize/2)+10;


    int sizeStep = 0;
    int typeStep = 0;
    int boldStep = 0;
    int stepSize = 25;


    int bigRadius = 0;
    int smallRadius = 0;
    int middleRadius = 0;
    
    int typeRadius = 0;
    int boldRadius = 0;
    int radiusSize = 50;

    private void initMenu(){
        mx = int(menuMakePoint.x);
        my = int(menuMakePoint.y);

        coreMenu = new CircleButton(mx, my, coreSize, buttoncolor, highlight);
        leftMenu = new CircleButton(mx-diff, my, menuSize, buttoncolor, highlight);
        sizeMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        typeMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        boldMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        gothicMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        minchoMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        thickMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        fineMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        bigMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        middleMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        smallMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);

        bigRadius = diff;
        middleRadius = diff;
        smallRadius = diff;

        unfoldFlag = false;
        openFlag = false;
        visibleFlag = false;

        sizeFlag = false;
        typeFlag = false;
        boldFlag = false;
    }

    mySubMenu(PVector v){
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
                if(sizeMenu.update()){
                    visibleFlag = false;
                    
                }

                if(typeMenu.update()){
                    visibleFlag = false;
                    
                }

                if(boldMenu.update()){
                    visibleFlag = false;
                }

                if(leftMenu.update()){
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
            if(sizeStep != 135){
                sizeStep += stepSize;
                
                if(sizeStep > 135)
                    sizeStep = 135;
            }
            if(typeStep != 90){
                if(sizeStep >= 45)
                    typeStep += stepSize;
                
                if(typeStep > 90)
                    typeStep = 90;
            }
            if(boldStep != 90){
                if(typeStep >= 45)
                    boldStep += stepSize;
                
                if(boldStep > 45){
                    boldStep = 45;
                    unfoldFlag = true;
                    openFlag = true;
                }
            }

            if(unfoldFlag){
                if(bigRadius != diff_3){
                    bigRadius += radiusSize;
                    
                    if(bigRadius > diff_3)
                        bigRadius = diff_3;
                }
                if(middleRadius != diff_2){
                    if(bigRadius >= diff_1)
                        middleRadius += radiusSize;
                    
                    if(middleRadius > diff_2)
                        middleRadius = diff_2;
                }
                if(smallRadius != diff_1){
                    if(middleRadius >= diff_1)
                        smallRadius += radiusSize;

                    if(smallRadius > diff_1)
                        smallRadius = diff_1;
                }
            }

        }
        else{
            if(sizeStep != 0){
                sizeStep -= stepSize;
                if(sizeStep <= 0){
                    sizeStep = 0;
                    unfoldFlag = false;
                    openFlag = false;
                }
            }
            if(typeStep != 0){
                typeStep -= stepSize;
                if(typeStep <= 0)
                    typeStep = 0;
            }
            if(boldStep != 0){
                boldStep -= stepSize;
                if(boldStep <= 0)
                    boldStep = 0;
            }
        }
        
        sizeMenu.setPosition(int(mx-diff*cos(radians(sizeStep))),
                             int(my-diff*sin(radians(sizeStep))));
        typeMenu.setPosition(int(mx-diff*cos(radians(typeStep))),
                             int(my-diff*sin(radians(typeStep))));
        boldMenu.setPosition(int(mx-diff*cos(radians(boldStep))),
                             int(my-diff*sin(radians(boldStep))));
        bigMenu.setPosition(int(mx-bigRadius*cos(radians(sizeStep))),
                              int(my-bigRadius*sin(radians(sizeStep))));
        middleMenu.setPosition(int(mx-middleRadius*cos(radians(sizeStep))),
                            int(my-middleRadius*sin(radians(sizeStep))));
        smallMenu.setPosition(int(mx-smallRadius*cos(radians(sizeStep))),
                            int(my-smallRadius*sin(radians(sizeStep))));


        update();
        display();
    }

    void display(){
        if(visibleFlag || openFlag){
            bigMenu.display(imgSize);
            middleMenu.display(imgSize);
            smallMenu.display(imgSize);

            sizeMenu.display(imgSize);
            typeMenu.display(imgType);
            boldMenu.display(imgBold);
            leftMenu.display(imgLeft);
            
        }

        if(openFlag || visibleFlag){
            coreMenu.display(imgCore);
        }
    }
}
