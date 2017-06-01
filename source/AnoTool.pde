PImage img;
PImage prevImg;
BufferedReader reader;
PrintWriter output;
PrintWriter temp;

import java.io.File;

int label = 0;
int crossHairSize = 200;

BoundingBox[] BBs; //Array of bounding boxes
int BBi = 0; //Bounding box index, used for 'BBs'
int imgI = 0; //Image index, shown in the top left corner

ArrayList<String> images = new ArrayList<String>();

boolean backLegal = false; //is it okay to go back
boolean backUsed = false;

boolean intro = true;

void resetBoundingBoxes(){
  for (int i = 0; i<20; i++){
    BBs[i] = new BoundingBox(new Vector(0,0));
    BBs[i].setActive(false);
  }
  BBi = 0;
}

void deleteImage(){
  
  //Delete image
  
  String fileName = dataPath("images/" + images.get(imgI-1) + ".jpg");
  File f = new File(fileName);
  f.delete();
  resetBoundingBoxes();
  
  //Remove index from array
  
  images.remove(imgI-1);
  
  //Remove line from data.txt
  
  temp = createWriter("data/temp.txt");
  for (int i = 0; i < images.size() - 1; i++){
    temp.println(images.get(i));
  }
  temp.flush();
  temp.close();
  String fileName1 = dataPath("data.txt");
  String fileName2 = dataPath("temp.txt");
  
  File file1 = new File(fileName1);
    try{
      if(file1.delete()){
      }else{
        System.out.println("Delete operation is failed.");
      }
    } catch (Exception e){
      e.printStackTrace();
    }
  File file2 = new File(fileName2);
    try{
      if(file2.renameTo(file1)){
      } else { println("Couldn't rename temp file to data.txt"); }
    } catch (Exception e){
      e.printStackTrace();
    }

  //Load next image

  imgI--;
  readAndLoadImage(imgI);
}

void printArray(){
  for (int i = 0; i < images.size()-1; i++){
     print(images.get(i) + "   ");
  }
  println("");
}

void loadDataFile(){
  // Read data file, store in array
  reader = createReader("data/data.txt");
  String line = "foo";
  while (line != null){
    try {
      line = reader.readLine();
      images.add(line);
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
  try {
  reader.close();
  }catch(Exception e){

    e.printStackTrace();

  }
}

void  readAndLoadIntroImage(){
  background(color(0,0,255));
  fill(255,255,0);
  
  textSize(72);
  text("AnoTool", 30, 100);
  
  textSize(36);
  text("Mouse button: Draw bounding box", displayWidth * 0.1, displayHeight * 0.3);
  text("Scroll wheel: Select object class", displayWidth * 0.1, displayHeight * 0.3 + 50);
  
  text("Space: Next image", displayWidth * 0.6, displayHeight * 0.3);
  text("Backspace: Previous image", displayWidth * 0.6, displayHeight * 0.3 + 50);
  text("D: Delete image", displayWidth * 0.6, displayHeight * 0.3 + 100);
  text("Arrow keys: Select bounding box", displayWidth * 0.6, displayHeight * 0.3 + 150);
  text("C: Remove all bounding boxes", displayWidth * 0.6, displayHeight * 0.3 + 200);
  text("+: Increase crosshair", displayWidth * 0.6, displayHeight * 0.3 + 250);
  text("-: Decrease crosshair", displayWidth * 0.6, displayHeight * 0.3 + 300);
  text("S: Save progress", displayWidth * 0.6, displayHeight * 0.3 + 350);
  text("Esc/Q: Exit", displayWidth * 0.6, displayHeight * 0.3 + 400);
  text("Press any key to continue..", displayWidth * 0.6, displayHeight * 0.3 + 500);
  
}

void readAndLoadImage(int i){
  if ((i < 0) || (i >= images.size()-1)){
    println("Can't open image " + i);
    exit();
  } else {
    img = loadImage("data/images/" + images.get(i) + ".jpg");
    imgI = ++i;

    img.resize(displayWidth,displayHeight);
  }
}


void saveBoundingBoxes(int j){
  output = createWriter("data/labels/" + images.get(j) + ".txt");
  
  for (int i = 0; i < 20; i++){
    //println("Checking box nr: " + i + " It is: " + BBs[i].active);
    if (BBs[i].type != -1){
      output.println(BBs[i].type + " " + (BBs[i].pos.x+BBs[i].size.x/2)/displayWidth + " " + (BBs[i].pos.y+BBs[i].size.y/2)/displayHeight + " " + abs(BBs[i].size.x)/displayWidth + " " + abs(BBs[i].size.y)/displayHeight);
    }
  }
  
  output.flush();
  output.close();
}

void setup(){
  fullScreen();
  
  loadDataFile();
  
  readAndLoadIntroImage();
  
  noCursor();
  
  BBs = new BoundingBox[20]; //Array of bounding boxes
  resetBoundingBoxes();
  
  noFill();
  stroke(255);
  textSize(28);
}

void draw(){
  //image(img,0,0,displayWidth,displayHeight);
  if (!intro)
  {
    fill(255,255,255);
    image(img,0,0);
    strokeWeight(1);
    line(mouseX - crossHairSize, mouseY, mouseX + crossHairSize, mouseY);
    line(mouseX, mouseY - crossHairSize, mouseX, mouseY + crossHairSize);
    text(frameRate, 0, 30);
    text(imgI, 10, 58);
  
    for (int i = 0; i < 20; i++)
    {
      BBs[i].draw();
    }
  }
}


void mousePressed(){
  BBs[BBi].setPos(new Vector(mouseX, mouseY));
  BBs[BBi].setType(label);
  BBs[(BBi+19)%20].setActive(false);
  BBs[BBi].setActive(true);
}

void mouseDragged(){
  Vector size = new Vector (mouseX - BBs[BBi].getPos().x, mouseY - BBs[BBi].getPos().y);
  BBs[BBi].setSize(size);
}

void mouseReleased(){
  Vector size = new Vector (mouseX - BBs[BBi].getPos().x, mouseY - BBs[BBi].getPos().y);
  BBs[BBi].setSize(size);
  
  BBi = (BBi + 1) % 20;
}

void mouseWheel(MouseEvent event) {
  label += event.getCount();
  label = label % 100;
  if (label < 0) label = label + 100;
  if (BBs[(BBi+19)%20].active){
  BBs[(BBi+19)%20].setType(label);
  }
}

void keyPressed(){
  if (key == ESC) key = 'q';
  if (intro) {
    intro = false;
    resetBoundingBoxes();
    readAndLoadImage(imgI);
  } else {
    if (key == CODED){
      if (keyCode == LEFT){
        BBs[(BBi+19)%20].setActive(false);
        BBi = (BBi+19)%20;
        BBs[(BBi+19)%20].setActive(true);
      } else if (keyCode == RIGHT){
        BBs[(BBi+19)%20].setActive(false);
        BBi = (BBi+1)%20;
        BBs[(BBi+19)%20].setActive(true);
      }
    } else {
      if (key == ' '){
        
        saveBoundingBoxes(imgI-1);
        resetBoundingBoxes();
        readAndLoadImage(imgI);
  
      } else if(key == 'c'){
        resetBoundingBoxes();
      }else if(key =='q'){
        stop();
      } else if(key == 's'){
        save();
      } else if(key == '+'){
        crossHairSize += 5;
      } else if(key == '-'){
        crossHairSize -= 5;
      } else if(key == '\b'){
       println("Backspace");
       resetBoundingBoxes();
       imgI -=2;
       readAndLoadImage(imgI);
      } else if (key == 'd'){
        deleteImage();
      } else if (key == 'm'){
        printArray();
      }
    }
  }
}

void save(){
  // Save array to file 
  temp = createWriter("data/temp.txt");
  for (int i = imgI - 1; i < images.size() - 1; i++){
    temp.println(images.get(i));
  }
  temp.flush();
  temp.close();
  String fileName1 = dataPath("data.txt");
  String fileName2 = dataPath("temp.txt");
  
  File file1 = new File(fileName1);
    try{
      if(file1.delete()){
      }else{
        System.out.println("Delete operation is failed.");
      }
    } catch (Exception e){
      e.printStackTrace();
    }
  File file2 = new File(fileName2);
    try{
      if(file2.renameTo(file1)){
      } else { println("Couldn't rename temp file to data.txt"); }
    } catch (Exception e){
      e.printStackTrace();
    }  
}


void stop(){

    exit();
}