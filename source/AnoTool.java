import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.io.File; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class AnoTool extends PApplet {

PImage img;
PImage prevImg;
BufferedReader reader;
PrintWriter output;
PrintWriter temp;



int label = 0;
int crossHairSize = 200;

BoundingBox[] BBs; //Array of bounding boxes
int BBi = 0; //Bounding box index, used for 'BBs'
int imgI = 0; //Image index, shown in the top left corner

ArrayList<String> images = new ArrayList<String>();

boolean backLegal = false; //is it okay to go back
boolean backUsed = false;

boolean intro = true;

public void resetBoundingBoxes(){
  for (int i = 0; i<20; i++){
    BBs[i] = new BoundingBox(new Vector(0,0));
    BBs[i].setActive(false);
  }
  BBi = 0;
}

public void deleteImage(){
  
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

public void printArray(){
  for (int i = 0; i < images.size()-1; i++){
     print(images.get(i) + "   ");
  }
  println("");
}

public void loadDataFile(){
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

public void  readAndLoadIntroImage(){
  background(color(0,0,255));
  fill(255,255,0);
  
  textSize(72);
  text("AnoTool", 30, 100);
  
  textSize(36);
  text("Mouse button: Draw bounding box", displayWidth * 0.1f, displayHeight * 0.3f);
  text("Scroll wheel: Select object class", displayWidth * 0.1f, displayHeight * 0.3f + 50);
  
  text("Space: Next image", displayWidth * 0.6f, displayHeight * 0.3f);
  text("Backspace: Previous image", displayWidth * 0.6f, displayHeight * 0.3f + 50);
  text("D: Delete image", displayWidth * 0.6f, displayHeight * 0.3f + 100);
  text("Arrow keys: Select bounding box", displayWidth * 0.6f, displayHeight * 0.3f + 150);
  text("C: Remove all bounding boxes", displayWidth * 0.6f, displayHeight * 0.3f + 200);
  text("+: Increase crosshair", displayWidth * 0.6f, displayHeight * 0.3f + 250);
  text("-: Decrease crosshair", displayWidth * 0.6f, displayHeight * 0.3f + 300);
  text("S: Save progress", displayWidth * 0.6f, displayHeight * 0.3f + 350);
  text("Esc/Q: Exit", displayWidth * 0.6f, displayHeight * 0.3f + 400);
  text("Press any key to continue..", displayWidth * 0.6f, displayHeight * 0.3f + 500);
  
}

public void readAndLoadImage(int i){
  if ((i < 0) || (i >= images.size()-1)){
    println("Can't open image " + i);
    exit();
  } else {
    img = loadImage("data/images/" + images.get(i) + ".jpg");
    imgI = ++i;

    img.resize(displayWidth,displayHeight);
  }
}


public void saveBoundingBoxes(int j){
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

public void setup(){
  
  
  loadDataFile();
  
  readAndLoadIntroImage();
  
  noCursor();
  
  BBs = new BoundingBox[20]; //Array of bounding boxes
  resetBoundingBoxes();
  
  noFill();
  stroke(255);
  textSize(28);
}

public void draw(){
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


public void mousePressed(){
  BBs[BBi].setPos(new Vector(mouseX, mouseY));
  BBs[BBi].setType(label);
  BBs[(BBi+19)%20].setActive(false);
  BBs[BBi].setActive(true);
}

public void mouseDragged(){
  Vector size = new Vector (mouseX - BBs[BBi].getPos().x, mouseY - BBs[BBi].getPos().y);
  BBs[BBi].setSize(size);
}

public void mouseReleased(){
  Vector size = new Vector (mouseX - BBs[BBi].getPos().x, mouseY - BBs[BBi].getPos().y);
  BBs[BBi].setSize(size);
  
  BBi = (BBi + 1) % 20;
}

public void mouseWheel(MouseEvent event) {
  label += event.getCount();
  label = label % 100;
  if (label < 0) label = label + 100;
  if (BBs[(BBi+19)%20].active){
  BBs[(BBi+19)%20].setType(label);
  }
}

public void keyPressed(){
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

public void save(){
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


public void stop(){

    exit();
}
class BoundingBox{
  
  BoundingBox(Vector _pos){ 
    pos = _pos;
    size = new Vector(0, 0);
    c = color(255,255,255);
    active = true;
    type = -1;
  }

  public void draw(){
    if (active){
      strokeWeight(2);
    } else {
      strokeWeight(1);
    }
    noFill();
    stroke(c);
    rect(pos.x, pos.y, size.x, size.y);
    
    

      if (size.x < 0) {
        if (size.y < 0) {
          text(type, pos.x + size.x, pos.y + size.y);       
        } else {
          text(type, pos.x + size.x, pos.y);        
        }
      } else {        
        if (size.y < 0) {
          text(type, pos.x, pos.y + size.y);       
        } else {
          text(type, pos.x, pos.y);        
        }
      }
    
    
  }
  
  public void setSize(Vector _size){
    size = _size;
  }
  
  public void setType(int _type){
    type = _type;
  }
  
  public void setColor(int _c){
    c = _c; 
  }
  
  public void setActive(boolean state){
    active = state;
  }
  
  public void setPos(Vector _pos){
    pos = _pos;
  }
  
  public Vector getPos(){
    return pos;
  }
  

  Vector pos;
  Vector size;
  int type;
  int c;
  boolean active;  //Draw the box or not
};
class Vector{
  
  public
    
    Vector(){
      x = 0;
      y = 0;
    }
    
    Vector(float _x, float _y){
      x = _x;
      y = _y;
    }
    
    Vector(Vector vect){
      x = vect.x;
      y = vect.y;
    }
    
    public void setValues(float _x, float _y){
      x = _x;
      y = _y;
    }
    
    public float getLength(){
      return sqrt(pow(x, 2) + pow(y, 2));
    }
    
    public void rotate(float v){
      Vector temp = new Vector(x, y);
      x = temp.x * cos(v) - temp.y * sin(v);
      y = temp.x * sin(v) + temp.y * cos(v);
    }
    
    public float getAngle(){
      Vector vect = new Vector(1, 0);
      return acos(this.getScalar(vect) / (this.getLength() * vect.getLength()));
    }
    
    public float getAngle(Vector vect){
      return acos(this.getScalar(vect) / (this.getLength() * vect.getLength()));
    }
    
    public float getScalar(Vector vect){
      return x * vect.x + y * vect.y;
    }
    
    public float toRadians(float v){
      return v / 180 * PI;
    }
    
    public float toDegree(float v){
      return v / PI * 180;
    }
    
    public Vector add(Vector vect){
      return new Vector(x + vect.x, y + vect.y);
    }
    
    public Vector sub(Vector vect){
      return new Vector(x - vect.x, y - vect.y);
    }
    
    public Vector mul(float scale){
      return new Vector(x * scale, y * scale);
    }
    
    public Vector div(float scale){
      return new Vector(x / scale, y / scale);
    }
    
    float x;
    float y;
};
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "AnoTool" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
