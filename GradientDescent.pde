import peasy.*; //from a libary called PeasyCam so that we can move the camera
PeasyCam p;
boolean mapGrad = true;
boolean drawD = true;
ArrayList<PVector> descent;
float actualWidthHeight;
float lBoundX;
float lBoundY;
float vertScale;
float gradScaleConstant;
int fieldDensity;
int W;
int timeStep = 1;

void setup() {
  colorMode(HSB);
  size(800, 800, P3D);
  W = 800;
  descent = new ArrayList<PVector>();
  fieldDensity = 5;
  
  //lBoundX = -2.0;
  //lBoundY = -.5;
  //actualWidthHeight = 4;
  //lBoundX = -5;
  //lBoundY = -5;
  //actualWidthHeight = 10;
  lBoundX = -10.01;
  lBoundY = -10.01;
  actualWidthHeight = 20;
  
  //vertScale = 1;
  //vertScale = .4;
  vertScale = 400;
  
  //gradScaleConstant = .00070;
  //gradScaleConstant = .0070;
  gradScaleConstant= .007;
  
  p = new PeasyCam(this,400,400,400,400);
  strokeWeight(1);
  initialize();
}
  
void draw() {
  background(0);
  drawSurface1();
  if (mapGrad) {drawGradfield1();};
  if (drawD) {drawDescent();}
  timeStep++;
  if (timeStep > 250 && timeStep % 50 == 0) {
    addNew();
  }
  rotateX(PI/100);
}


//DEFINE THE MULTIVARIABLE FUNCTION HERE
//bounds : xlb = -2, ylb = -.5, 4 total
//float f(float x, float y) {return sq(1-x)+100*sq(y-x*x);}
//float fx(float x, float y) {return 2-2*x-400*(y*x-x*x*x);}
//float fy(float x, float y) {return 200*(y-x*x);}
//bounds xlb = -5, ylb = -5, total = 10
//float f(float x, float y) {return sq(x*x+y-11) + sq(x+y*y-7);}
//float fx(float x, float y) {return 4*x*(x*x+y-11)+2*(x+y*y-7);}
//float fy(float x, float y) {return 2*(x*x+y-11)+4*y*(x+y*y-7);}
//bounds xlb = -5, ylb = -5, total = 10
float f(float x, float y) {return sin(sqrt(x*x+y*y))/sqrt(x*x+y*y);}
float fx(float x, float y) {
  float r = sqrt(x*x+y*y);
  return (x*cos(r)*r-x*sin(r))/pow(r,3);}
float fy(float x, float y) {
  float r = sqrt(x*x+y*y);
  return (y*cos(r)*r-y*sin(r))/pow(r,3);}



void initialize() {
  float rx = random(W);
  float ry = random(W);
  descent.add(new PVector(rx,ry,vertScale*f(map(rx,0,800,lBoundX,lBoundX+actualWidthHeight),map(ry,0,800,lBoundY,lBoundY+actualWidthHeight))));
}
void addNew() {
  if (timeStep > 20) {
    PVector o = descent.get(descent.size()-1);
    float mx = map(o.x,0,800,lBoundX,lBoundX+actualWidthHeight);
    float my = map(o.y,0,800,lBoundY,lBoundY+actualWidthHeight);
    float gx = -fx(mx,my); //actual units, not pixels
    float gy = -fy(mx,my);
    float nz = vertScale*f(mx+gx*gradScale(),my+gy*gradScale());
    PVector out = new PVector(map(mx+gx*gradScale(),lBoundX,lBoundX+actualWidthHeight,0,800),map(my+gy*gradScale(),lBoundY,lBoundY+actualWidthHeight,0,800),nz);
    descent.add(out);
  }
}
  
void drawDescent() {
  pushMatrix();
    translate(0,0,400);
    for (int i = 0; i < descent.size()-1; i++) {
      drawMiniArrow(6, descent.get(i).x, descent.get(i).y, descent.get(i).z, PVector.sub(descent.get(i+1),descent.get(i)), int((PVector.sub(descent.get(i+1),descent.get(i))).mag()));}
  popMatrix();  
}

float gradScale(){return gradScaleConstant;}
    
void drawSurface1() {
  strokeWeight(1);
  pushMatrix();
  translate(0,0,400);
  for (float x =0; x < width-fieldDensity; x+= fieldDensity) {
    for (float y = 0; y < height-fieldDensity; y+= fieldDensity) {
      float h1 = vertScale*f(map(x,0,800,lBoundX,lBoundX+actualWidthHeight),map(y,0,800,lBoundY,lBoundY+actualWidthHeight));
      float h2 = vertScale*f(map(x+fieldDensity,0,800,lBoundX,lBoundX+actualWidthHeight),map(y,0,800,lBoundY,lBoundY+actualWidthHeight));
      float h3 = vertScale*f(map(x+fieldDensity,0,800,lBoundX,lBoundX+actualWidthHeight),map(y+fieldDensity,0,800,lBoundY,lBoundY+actualWidthHeight));
      float h4 =vertScale*f(map(x,0,800,lBoundX,lBoundX+actualWidthHeight),map(y+fieldDensity,0,800,lBoundY,lBoundY+actualWidthHeight));
      //fill(map(log(h1),0,6.0,0,255),255,255);
      beginShape();
      
        stroke(map(log(h1),0,6.0,0,255),255,255);
        vertex(x,y,h1);
        vertex(x+fieldDensity,y,h2);
        vertex(x+fieldDensity,y+fieldDensity,h3);
        vertex(x,y,h1);
        vertex(x,y+fieldDensity,h4);
        vertex(x+fieldDensity,y+fieldDensity,h3);
      endShape();
    noFill();}}
  popMatrix();}
  
void drawGradfield1() {
  strokeWeight(1);
  pushMatrix();
  translate(0,0,400);
  for (float x =0; x < width-fieldDensity; x+= fieldDensity) {
    for (float y = 0; y < height-fieldDensity; y+= fieldDensity) {
      float z;
      if (mapGrad) {
        z = vertScale*f(map(x,0,800,lBoundX,lBoundX+actualWidthHeight),map(y,0,800,lBoundY,lBoundY+actualWidthHeight));}
      else {z = 0;}
      drawMiniArrow(1,x,y,z,new PVector(fx(map(x,0,800,lBoundX,lBoundX+actualWidthHeight),map(y,0,800,lBoundY,lBoundY+actualWidthHeight)),
                                        fy(map(x,0,800,lBoundX,lBoundX+actualWidthHeight),map(y,0,800,lBoundY,lBoundY+actualWidthHeight))),
                                        fieldDensity);}}
  popMatrix();}
 
void axes() {
  pushMatrix();
    translate(0,0,400);
    stroke(160,255,255);
    line(0,height/2,width,height/2);
    stroke(255,255,255);
    line(width/2,0,width/2,height);
    translate(width/2,height/2);
    rotateY(PI/2);
    stroke(255,0,255);
    line(0,0,-60,0);
  popMatrix();}
  
void drawMiniArrow(int thickness, float x, float y, float z,PVector h, int fD) {
    if (h.mag() < .000001) {return;}
    strokeWeight(thickness);
    stroke(map(h.mag(),0,100,100,255),255,255);
    pushMatrix();
      translate(x,y,z);
      float phi = atan2(h.z,sqrt(sq(h.x)+sq(h.y)));
      float theta =atan2(h.y,h.x);
      rotateZ(PI/2+theta);
      rotateX(PI-phi);
      line(0,fD*.5,0,0);
      noFill();
      triangle(0,fD,fD*.05,fD*.5,-fD*.05,fD*.5);
    popMatrix();}
  
void keyPressed() {
  if (key == '1') {
    mapGrad = !mapGrad;
  }
  else if (key == '2') {
    drawD = !drawD;
  }
}
