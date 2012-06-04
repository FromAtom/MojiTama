public class useFile{
    PrintWriter output;
    String filename;
    
    useFile(String init_filename){//初期化用メソッド
        output = createWriter(init_filename);
        filename = init_filename;
    }
    
    void writeFile(String outputString){
        output.println(outputString);
        output.flush();
    }//end writeFile()
    
    void closeFile(){
        output.close();
    }//end closeFile()
}
