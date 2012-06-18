void clear_ibuffer(){
  if(inputBuffer.length() == 0)
  return;
  if(inputBuffer.length() == 1){
  inputBuffer = "";
  return;
  }
  inputBuffer = inputBuffer.substring(0,inputBuffer.length()-1);
}
void clearAll_ibuffer(){
  inputBuffer = "";
}
