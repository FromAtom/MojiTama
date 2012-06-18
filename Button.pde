class Button
{
    int x, y;
    int size;
    color basecolor, highlightcolor;
    color currentcolor;
    boolean over = false;
    boolean pressed = false;

    int onTimeStep = 30;
    int onTime = 0;

    boolean update()
    {
        if(over()) {
            if(onTime == 0)
                overSound.play(0);

            onTime += onTimeStep;
            
            if(onTime >= 360){
                onTime = 360;
                return true;
            }
        }
        else {
            onTime = 0;
        }
        return false;
    }

    boolean pressed()
    {
        if(over) {
            locked = true;
            return true;
        }
        else {
            locked = false;
            return false;
        }
    }

    boolean over()
    {
        return true;
    }

    boolean overRect(int x, int y, int width, int height)
    {
        if (mouseX >= x && mouseX <= x+width &&
            mouseY >= y && mouseY <= y+height) {
            return true;
        }
        else {
            return false;
        }
    }

    boolean overCircle(int x, int y, int diameter)
    {
        //float disX = x - rightHandPosBuf.x;
        //float disY = y - rightHandPosBuf.y;

        float disX = x - mouseX;
        float disY = y - mouseY;


        if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
            return true;
        }
        else {
            return false;
        }
    }
}

class CircleButton extends Button
{
    CircleButton(int ix, int iy, int isize, color icolor, color ihighlight)
    {
        x = ix;
        y = iy;
        size = isize;
        basecolor = icolor;
        highlightcolor = ihighlight;
        currentcolor = basecolor;
    }
    
    void setPosition(int ix, int iy)
    {
        x = ix;
        y = iy;
    }

    boolean over()
    {
        if( overCircle(x, y, size) ) {
            over = true;
            return true;
        }
        else {
            over = false;
            return false;
        }
    }

    void display(PImage menuImg)
    {
        image(menuImg, x-menuImg.width/2, y-menuImg.height/2);

        //        fill(currentcolor);
        //noStroke();
        //ellipse(x, y, size, size);

        if(onTime > 0){
            noFill();
            stroke(timecolor);
            strokeWeight(11);
            arc(x, y, size, size, 0, radians(onTime));
        }
    }
}
