ArrayList<ParticleSystem> systems;

int scenario; // control the start interface
PImage bg;
PImage gamebg;
/*************Buttons size********************/
int rectX, rectY;      // Position of square button
int rectW = 270;     // width of rect
int rectH = 120;     // height of rect
boolean rectOver = false;
boolean circleOver = false;



void setup() {
  size(796, 1119, P3D);
  Init_max = width/(4*bubblewid);
  Init_pertumation();
  systems = new ArrayList<ParticleSystem>();
  systems.add(new ParticleSystem(0));
  scenario=0;
  
  
  bg = loadImage("dreamnight.jpg");
  gamebg = loadImage("tumblr.jpg");
  bg.resize(796, 1119);
  gamebg.resize(796, 1119);
  rectX = width/2-rectW/2;
  rectY = height/2-rectH/2-300;
}

void draw() {
  switch(scenario)
  {
  case 0:
    background(bg);
    Bar();
    for (ParticleSystem ps : systems) {
      ps.addParticle();
      ps.run();      
    }
    break;
  case 1:

    background(gamebg);
    for (ParticleSystem ps : systems) {
      ps.addParticle();
      ps.run();      
    }
    //if (systems.isEmpty()) {
    //  fill(255);
    //  textAlign(CENTER);
    //  text("click mouse to add particle systems", width/2, height/2);
    //}

    break;
  }
}

void mouseClicked() {
}

void mousePressed() 
{
  if (overRect(rectX, rectY, rectW, rectH))
  {
    rectOver = !rectOver;
    scenario = 1;
  }
}
void mouseReleased() {
  if (overRect(rectX, rectY, rectW, rectH))
  {
    rectOver = !rectOver;
  }
}
//judge the position of the click point
boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

boolean overCircle(int x, int y, int diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}
void update(int x, int y) {
  if ( overRect(rectX, rectY, rectW, rectH) ) 
  {
    rectOver = true;
  } 
  else {
    rectOver = false;
  }
}
void Bar()
{
  update(mouseX,mouseY);
  noStroke();
  PImage start_no_click = loadImage("start_not_click.png");
  start_no_click.resize(rectW, rectH);
  PImage start_with_click = loadImage("start_after_click.png");
  start_with_click.resize(rectW, rectH);
  beginShape();
  if (!rectOver)
    texture(start_no_click);
  else
    texture(start_with_click);

  vertex(rectX, rectY, 0, 0);
  vertex(rectX+rectW, rectY, rectW, 0);
  vertex(rectX+rectW, rectY+rectH, rectW, rectH);
  vertex(rectX, rectY+rectH, 0, rectH);
  endShape();
}
