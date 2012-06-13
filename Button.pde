class Button
{
    int x, y;
    int size;
    color basecolor, highlightcolor;
    color currentcolor;
    boolean over = false;
    boolean pressed = false;

    int onTimeStep = 13;
    int onTime = 0;
    
    boolean update()
    {
        if(over()) {
            onTime += onTimeStep;
            
            if(onTime >= 360){
                onTime = 360;
                basecolor = color(255);
                return true;
            }

            currentcolor = highlightcolor;
        }
        else {
            onTime = 0;
            basecolor = color(204);
            currentcolor = basecolor;
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
        float disX = x - rightHandPosBuf.x;
        float disY = y - rightHandPosBuf.y;

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

    void display()
    {
        stroke(255);
        fill(currentcolor);
        ellipse(x, y, size, size);
        fill(#4188D2);
        arc(x, y, size, size, 0, radians(onTime));
        noStroke();
        fill(currentcolor);
        ellipse(x, y, size-30, size-30);
    }
}
