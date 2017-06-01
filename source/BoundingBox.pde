class BoundingBox{
  
  BoundingBox(Vector _pos){ 
    pos = _pos;
    size = new Vector(0, 0);
    c = color(0,255,0);
    active = true;
    type = -1;
  }

  void draw(){
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
  
  void setSize(Vector _size){
    size = _size;
  }
  
  void setType(int _type){
    type = _type;
  }
  
  void setColor(color _c){
    c = _c; 
  }
  
  void setActive(boolean state){
    active = state;
  }
  
  void setPos(Vector _pos){
    pos = _pos;
  }
  
  Vector getPos(){
    return pos;
  }
  

  Vector pos;
  Vector size;
  int type;
  color c;
  boolean active;  //Draw the box or not
};