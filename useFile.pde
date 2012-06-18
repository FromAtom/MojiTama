class useFile {
    PrintWriter outputText;
    PrintWriter outputHTML;
    String filename;

    useFile(String init_filename) {//初期化用メソッド
        outputText = createWriter(init_filename + ".txt");
        outputHTML = createWriter(init_filename + ".html");
        filename = init_filename;
    
        initHTML();
    }

    //メソッド ファイルに一行書き込む
    void writeFile(String outputString) {
        outputText.println(outputString);
        outputText.flush();
        outputHTML.println("<font color = \"#FFFFFF\">");
        outputHTML.println(outputString + "<br>");
        outputHTML.println("</font>");
        outputHTML.flush();
    }//end writeFile()

    //メソッド オプション付き書き込み
    void writeFile(String outputString, int fColor, int fType, int fSize, boolean boldFlag) {
        //txtファイルへ
        outputText.println(outputString);
        outputText.flush();
    
        //HTMLファイルへ
        if(boldFlag){
            outputHTML.println("<b>");
        }
        if(fType<FONT_NUM){//フォント指定
            outputHTML.println("<font face=\""+ FONT_NAME[fType] +"\">");
        }
        if(1 <= fSize && fSize <= 7){//サイズ指定
            outputHTML.println("<font size=\"" + Integer.toString(fSize) + "\">");
        }
        if(0 <= fColor && fColor <= COLOR_NUM){
            outputHTML.println("<font color=\"" + COLOR_NAME[fColor] + "\">");
        }
        outputHTML.println(outputString + "<br>");
        if(fType < FONT_NUM){//フォント、サイズ指定解除
            outputHTML.println("</font>");
        }
        if(1 <= fSize && fSize <= 7){//フォント、サイズ指定解除
            outputHTML.println("</font>");
        }
        if(0 <= fColor && fColor <= COLOR_NUM){//フォント、サイズ指定解除
            outputHTML.println("</font>");
        }
        if(boldFlag){
            outputHTML.println("</b>");
        }
        outputHTML.flush();
    }//end writeFile

    //メソッド ファイルを閉じる
    void closeFile() {
        outputText.close();
    
        outputHTML.println("</body>");
        outputHTML.println("</html>");
        outputHTML.close();
    }//end closeFile()
  
    void initHTML(){
        outputHTML.println("<html>");
        outputHTML.println("<head>");
        outputHTML.println("<title>");
        outputHTML.println("もじたま");
        outputHTML.println("</title>");
        outputHTML.println("</head>");
        outputHTML.println("<body bgcolor=\"000000\">");
        outputHTML.println("<center>");
    
        outputHTML.flush();
    }
}

