public class mySubMenu {
    int coreSize = 200;
    int menuSize = int(coreSize/1.618);
    int subMenuSize = menuSize;
    PVector menuMakePoint;
    


    boolean visibleFlag;
    boolean openFlag;

    CircleButton leftMenu, coreMenu, sizeMenu, typeMenu, colorMenu, boldMenu;

    int sizeStep = 0;
    int typeStep = 0;
    int colorStep = 0;
    int boldStep = 0;
    int stepSize = 30;

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
        colorMenu = new CircleButton(mx-diff, my, subMenuSize, buttoncolor, highlight);
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

                if(colorMenu.update()){
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
            if(sizeStep != 180){
                sizeStep += stepSize;
                
                if(sizeStep > 180){
                    sizeStep = 180;
                }
            }
            if(typeStep != 135){
                if(sizeStep >= 45)
                    typeStep += stepSize;
                
                if(typeStep > 135)
                    typeStep = 135;
            }
            if(boldStep != 90){
                if(typeStep >= 45)
                    boldStep += stepSize;
                
                if(boldStep > 90)
                    boldStep = 90;
            }
            if(colorStep != 90){
                if(boldStep >= 45)
                    colorStep += stepSize;
                
                if(colorStep > 45){
                    colorStep = 45;
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
            if(colorStep != 0){
                colorStep -= stepSize;
                if(colorStep <= 0)
                    colorStep = 0;
            }
        }
        
        update();
        display();
    }

    void display(){
        if(visibleFlag || openFlag){
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

            leftMenu.display(imgLeft);
        }

        if(openFlag || visibleFlag){
            coreMenu.display(imgCore);
        }
    }
    }
