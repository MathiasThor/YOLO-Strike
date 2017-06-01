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
    
    void setValues(float _x, float _y){
      x = _x;
      y = _y;
    }
    
    float getLength(){
      return sqrt(pow(x, 2) + pow(y, 2));
    }
    
    void rotate(float v){
      Vector temp = new Vector(x, y);
      x = temp.x * cos(v) - temp.y * sin(v);
      y = temp.x * sin(v) + temp.y * cos(v);
    }
    
    float getAngle(){
      Vector vect = new Vector(1, 0);
      return acos(this.getScalar(vect) / (this.getLength() * vect.getLength()));
    }
    
    float getAngle(Vector vect){
      return acos(this.getScalar(vect) / (this.getLength() * vect.getLength()));
    }
    
    float getScalar(Vector vect){
      return x * vect.x + y * vect.y;
    }
    
    float toRadians(float v){
      return v / 180 * PI;
    }
    
    float toDegree(float v){
      return v / PI * 180;
    }
    
    Vector add(Vector vect){
      return new Vector(x + vect.x, y + vect.y);
    }
    
    Vector sub(Vector vect){
      return new Vector(x - vect.x, y - vect.y);
    }
    
    Vector mul(float scale){
      return new Vector(x * scale, y * scale);
    }
    
    Vector div(float scale){
      return new Vector(x / scale, y / scale);
    }
    
    float x;
    float y;
};