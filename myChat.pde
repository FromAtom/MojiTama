class myChat {
  int mode;
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
  myChat(PApplet p) {
    String ip;
    int port;
    try {
      BufferedReader reader = createReader("config.txt");
      reader.readLine();
      ip = reader.readLine();
      port = Integer.valueOf(reader.readLine());
      userName = reader.readLine();
      //println(ip + port + userName);
    }
    catch(IOException e) {
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
    String received = "";
    String received_tmp;
    String[] splitString;
    do {
      received_tmp = myClient.readString();
      if (received_tmp!=null)
        received = received + received_tmp;
      splitString = received.split(",", 0);
      if (splitString[0].equals("c")!=true)
      {
        println("");
        println("");
        println("");
        println("");
        println("破棄："+ received);
        return("");
      }
    }
    while (splitString.length < 7 || splitString[0].equals("c") == false);
    println("受信：" + received);
    println(splitString.length);
    fontColor = Integer.valueOf(splitString[1]);
    fontType = Integer.valueOf(splitString[2]);
    fontSize = Integer.valueOf(splitString[3]);
    boldFlag = Boolean.valueOf(splitString[4]);
    speakerName = splitString[5];
    receivedString = splitString[6];
    return(splitString[6]);
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
      myClient.write("c," + fColor + "," + fType + "," + fSize + "," + bFlag + "," + userName + "," + data);
    }
    else {
      myServer.write("c," + fColor + "," + fType + "," + fSize + "," + bFlag + "," + userName + "," + data);
    }
  }

  void stop() {
    if (mode == MODE_CLIENT) {
      myClient.stop();
    }
    else {
      myServer.stop();
    }
  }
}

