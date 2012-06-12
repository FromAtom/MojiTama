public class Menu {
    PVector menuMakePoint;
    PImage imgMenu;
    boolean visibleFlag;

    private void initMenu(){
        visibleFlag = false;
        this.imgMenu = loadImage("menu.png");
    }

    Menu(){
        initMenu();
        menuMakePoint = new PVector(0,0,0);
    }

    Menu(PVector v){
        initMenu();
        menuMakePoint = new PVector();
        menuMakePoint.set(v);
    }

    void visible(boolean flag){
        visibleFlag = flag;
    }

    void reflesh(){
    }

    void paint(){
        if(visibleFlag){
            image(this.imgMenu,
                  menuMakePoint.x-menuSize/2,
                  menuMakePoint.y-menuSize/2,
                  menuSize,
                  menuSize);
        }
    }
}