public class mySubMenu {
    int coreSize = 200;
    int menuSize = int(coreSize/1.618);
    int subMenuSize = menuSize;
    PVector menuMakePoint;
    


    boolean visibleFlag;
    boolean openFlag;

    CircleButton leftMenu, coreMenu, sizeMenu, typeMenu, boldMenu;

    int sizeStep = 0;
    int typeStep = 0;
    int boldStep = 0;
    int stepSize = 25;


    int mx;
    int my;
    int diff = (coreSize/2+menuSize/2)+10;
    

    private void initMenu(){
        mx = int(menuMakePoint.x);
        my = int(menuMakePoint.y);

        coreMenu = new CircleButton(mx, my, coreSize, buttoncolor, highlight);
        leftMenu = new CircleButton(mx-diff, my, menuSize, buttoncolor, highlight);
        sizeMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        typeMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
        boldMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);

        openFlag = false;
        visibleFlag = false;
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
        if(visibleFlag&&openFlag){
            if(locked == false) {
                if(sizeMenu.update()){
                    visibleFlag = false;
                    
                }

                if(typeMenu.update()){
                    visibleFlag = false;
                    
                }

                if(boldMenu.update()){
                    visibleFlag = false;
                    //leftFlag = true;
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
                    openFlag = true;
                }
            }
        }
        else{
            if(sizeStep != 0){
                sizeStep -= stepSize;
                if(sizeStep <= 0){
                    sizeStep = 0;
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
        
        sizeMenu.setPosition(int(mx-diff*cos(radians(sizeStep))),int(my-diff*sin(radians(sizeStep))));
        typeMenu.setPosition(int(mx-diff*cos(radians(typeStep))),int(my-diff*sin(radians(typeStep))));
        boldMenu.setPosition(int(mx-diff*cos(radians(boldStep))),int(my-diff*sin(radians(boldStep))));

        update();
        display();
    }

    void display(){
        
        if(visibleFlag || openFlag){
            /*
            if(boldStep != 0){
                pushMatrix();
                translate(mx, my);
                rotate(radians(boldStep));
                translate(-(mx), -(my));
                boldMenu.display(imgBold);
                popMatrix();
            }

            if(colorStep != 0){
                pushMatrix();
                translate(mx, my);
                rotate(radians(colorStep));
                translate(-(mx), -(my));
                colorMenu.display(imgColor);
                popMatrix();
            }

            if(typeStep != 0){
                pushMatrix();
                translate(mx, my);
                rotate(radians(typeStep));
                translate(-(mx), -(my));
                typeMenu.display(imgType);
                popMatrix();
            }
            
            if(sizeStep != 0){
                pushMatrix();
                translate(mx, my);
                rotate(radians(sizeStep));
                translate(-(mx), -(my));
                sizeMenu.display(imgSize);
                popMatrix();
            }

        */
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
