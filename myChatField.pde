class myChatField{
  String message;
  int messageColor;
  int messageFont;
  boolean messageBFlag;
  int displayCount;
  
  final int windowUnderLimit = 1024;
  final int countLimit = 100;
  final int appearTime = 15;
  final int speed = 10;
  
  PImage imgField;
  myChatField(){
    displayCount = countLimit;
    imgField = loadImage("hukidashi.png");
  }
  void setMessage(String receivedString){
    message = receivedString;
    displayCount = 0;
  }
  void reflesh(){
    int posY;
    if(displayCount<appearTime){
      posY = windowUnderLimit - displayCount * speed;
    }else if(displayCount< countLimit - appearTime){
      posY = windowUnderLimit - appearTime * speed;
    }else{
      posY = windowUnderLimit - (countLimit - displayCount) * speed;
    }
    
    if(displayCount<countLimit){
      image(imgField, 20, posY,imgBubble.width-20,imgBubble.height-20);
      text(message, 70, posY + 90);
      displayCount++;
    }
    println(displayCount);
  }
}
