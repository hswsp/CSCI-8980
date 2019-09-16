import queasycam.*; //<>//

ArrayList<Bubblesys> systems;
ArrayList<Ballonsys> Balloonsystems;
float starttime;
int scenario; // control the start interface
int tick;
QueasyCam cam;
/********************image********************************/
PImage bg;
PImage gamebg;
PImage overbg;
PImage points;
PImage combo;
PImage play_again;
PImage over;

/*************Buttons size********************/
int rectX, rectY;      // Position of square button
int rectW = 270;     // width of rect
int rectH = 120;     // height of rect
int W = 500, H = 384;
int PW = 406, PH = 68;
int CW = 272, CH = 68;
int startX, startY ;
int paW = 500;
int paH = 250;
int paX, paY ;
boolean rectOver = false;
boolean circleOver = false;
boolean IsPoping = false;

/*****************game logic*************************/
int score;
int curscore;
int comboscore;
String lastCor;
int TotalTime;


void renew()
{
  tick = 0;
  score = 0;
  curscore = 1;
  comboscore = 0;
  lastCor = " ";
}
void setup() {
  size(796, 1119, P3D);
  Init_max = width/(4*bubblewid);
  Init_pertumation();
  systems = new ArrayList<Bubblesys>();
  systems.add(new Bubblesys(20));
  hint(DISABLE_DEPTH_MASK);
  scenario=0;
  tick = 0;
  TotalTime = 10;
  /**********************game image***********************************/
  OImg = loadImage("popping_balloons.png");
  Skeleton = loadImage("skeleton.png");
  Skeleton.resize(120,120);
  bg = loadImage("dreamnight.jpg");
  gamebg = loadImage("tumblr.jpg");
  bg.resize(796, 1119);
  gamebg.resize(796, 1119);
  ClockImg =loadImage("clock.png");
  ClockImg.resize(120,120);
  Timeleft = loadImage("timeleft.png");
  Timeleft.resize(120,120);
  rectX = width/2-rectW/2;
  rectY = height/2-rectH/2-300;
  startX = (width-W)/2;
  startY = 75;
  paX = startX + 30 ;
  paY = width-50;
  //set cam
  cam = new QueasyCam(this);
  cam.speed = 3;              // default is 3
  cam.sensitivity = 0.5;      // default is 2
  cam.controllable = false;
  cam.position = new PVector(width/2, height/2, 400);
  cam.pan = -PI/2;
  perspective(PI/3, (float)width/height, 0.01, 10000);
  /*********************game over image***********************************/
  overbg = loadImage("typeform.jpg");
  overbg.resize(796, 1119);
  over = loadImage("gameover.png");
  points = loadImage("points.png");
  combo = loadImage("combo.png");
  play_again  =loadImage("play-again.png");
  over.resize(W, H);
  points.resize(PW, PH); 
  combo.resize(CW, CH);
  play_again.resize(paW, paH);
  /**********************game logic*************************************/
  renew();
}

void draw() {
  switch(scenario)
  {
  case 0:
    background(bg);
    for (ParticleSystem ps : systems) {
      if (tick==0)
        ps.addParticle();
      ps.run();
    }
    Bar();
    tick = (tick+1)%10;
    break;
  case 1:
    int curtime = millis();
    float sconds = (curtime - starttime)/1000;
    if (sconds>=TotalTime)
    {
      scenario = 2;
      tick = 0;
    } else
    {
      background(gamebg);
      textquad(Timeleft,width/2, 50, Timeleft.width, Timeleft.height);
      String s = String.valueOf(TotalTime - sconds);
      words(s, width/2+2*Timeleft.width,120, Timeleft.height/2);
      for (ParticleSystem ps : Balloonsystems) {
        if (tick==0)
          ps.addParticle();
        ps.run();
      }
      tick = (tick+1)%60;
    }
    break;
  case 2:
    tint(255, 126);
    background(overbg);
    tint(255, 255);
    Gameover();
    break;
  }
}

void mouseClicked() {
  switch(scenario)
  {
  case 0:
    break;
  case 1:    
    break;
  }
}

void mousePressed() 
{

  switch(scenario)
  {
  case 0:
    //start interface
    if (overRect(rectX, rectY, rectW, rectH))
    {
      rectOver = !rectOver;
      scenario = 1;
      tick = 0;
      starttime = millis();

      Balloonsystems = new ArrayList<Ballonsys>();
      Balloonsystems.add(new Ballonsys(0));
    }
    break;
  case 1:
    for (Ballonsys ps : Balloonsystems) {
      click_balloons(ps);
    }
    break;
  case 2:
    if (overRect(paX, paY, paW, paH))
    {
      scenario = 0;
      systems = new ArrayList<Bubblesys>();
      systems.add(new Bubblesys(20));      
      renew();
    }
    break;
  }
}
void mouseReleased() {
  switch(scenario)
  {
  case 0:
    //start interface
    if (overRect(rectX, rectY, rectW, rectH))
    {
      rectOver = !rectOver;
    }
    break;
  case 1:
    break;
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
  } else {
    rectOver = false;
  }
}

void Bar()
{
  update(mouseX, mouseY);
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

void Gameover()
{
  String Score = String.valueOf(score);
  String ComboScore = String.valueOf(comboscore);

  textquad(over, startX, startY, W, H);
  textquad(points, startX + 30, startY + H + 30, PW, PH);
  textquad(play_again, paX, paY, paW, paH);
  words(Score, startX + 30 + PW + 65, startY + H + PH + 30, PH);
  textquad(combo, startX + 30, startY + H +PH + 60, CW, CH);
  words(ComboScore, startX + 30 + CW + 65, startY + H +PH + 60 + CH, CH);
  
  
}
void textquad(PImage I, int startX, int startY, int W, int H)
{
  noStroke(); 
  beginShape();
  texture(I);
  vertex(startX, startY, 0, 0);
  vertex(startX+W, startY, W, 0);
  vertex(startX+W, startY+H, W, H);
  vertex(startX, startY+H, 0, H);
  endShape();
}
void words(String s, int startX, int startY, int size)
{
  fill(204, 102, 0);
  textSize(size);
  textAlign(CENTER);
  text(s, startX, startY);
}
void click_balloons(Ballonsys sys)
{
  int minzindex = 0;
  for (int i = 0; i< sys.particles.size(); ++i)
  {
    Particle p  = sys.particles.get(i);
    if (overRect(int(p.position.x-p.size.x/2), int(p.position.y - p.size.y/2), int(p.size.x), int(p.size.y)))
    {
      if (p.position.z<sys.particles.get(minzindex).position.z)
        minzindex = i;
    }
  }
  Ballon b = (Ballon)sys.particles.get(minzindex);
  b.pop = true;
  //b.step = (b.step + 1)%8;
}
