class myChat {
    int mode; //client or server
    Server myServer;
    Client myClient;
    
    String userName;
  
    String receivedString;
    int fontColor;
    int fontType;
    int fontSize;
    boolean boldFlag;
    String speakerName;

    myChat(PApplet p, String ip, int port) {
        myClient = new Client(p, ip, port);
        if (myClient.active()) {
            mode = MODE_CLIENT;
        }
        else {
            mode = MODE_SERVER;
            myServer = new Server(p, port);
            println("ServerMode");
        }
    }

    myChat(PApplet p){
        String ip;
        int port;
        try{
            BufferedReader reader = createReader("config.txt");
            reader.readLine();
            ip = reader.readLine();
            port = Integer.valueOf(reader.readLine());
            userName = reader.readLine();
            //println(ip + port + userName);
        }catch(IOException e){
            ip = "192.168.0.1";
            port = 5204;
            userName = "noName";
        }
        myClient = new Client(p, ip, port);
        if (myClient.active()) {
            mode = MODE_CLIENT;
        }
        else {
            mode = MODE_SERVER;
            myServer = new Server(p, port);
            println("ServerMode");
        }
    }

    int getMode() {
        return(mode);
    }

    boolean check() {
        if (mode == MODE_CLIENT) {
            if (myClient.available() > 0) {
                return(true);
            }
            else {
                return(false);
            }
        }
        else {
            myClient = myServer.available();
            if (myClient != null) {
                return(true);
            }
            else {
                return(false);
            }
        }
    }

    char readChar() {
        return(myClient.readChar());
    }
    String readString() {
        return(myClient.readString());
    }
    String readExString() {
        String received = myClient.readString();
        String[] splitString = received.split(",",0);
        fontColor = Integer.valueOf(splitString[0]);
        fontType = Integer.valueOf(splitString[1]);
        fontSize = Integer.valueOf(splitString[2]);
        boldFlag = Boolean.valueOf(splitString[3]);
        speakerName = splitString[4];
        receivedString = splitString[5];
        return(splitString[5]);
    }

    void write(char data) {
        if (mode == MODE_CLIENT) {
            myClient.write(data);
        }
        else {
            myServer.write(data);
        }
    }
    void write(String data) {
        if (mode == MODE_CLIENT) {
            myClient.write(data);
        }
        else {
            myServer.write(data);
        }
    }
    void writeExString(String data, int fColor, int fType, int fSize, boolean bFlag) {
        if (mode == MODE_CLIENT) {
            myClient.write(fColor + "," + fType + "," + fSize + "," + bFlag + "," + userName + "," + data);
        }
        else {
            myServer.write(fColor + "," + fType + "," + fSize + "," + bFlag + "," + userName + "," + data);
        }
    }
  
    void stop(){
        if(mode == MODE_CLIENT){
            myClient.stop();
        }else{
            myServer.stop();
        }
    }
}
