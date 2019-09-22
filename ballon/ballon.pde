import queasycam.*; //<>//
import java.text.DecimalFormat;

ArrayList<Bubblesys> systems;
ArrayList<Ballonsys> Balloonsystems;

int scenario; // control the start interface
int tick;
QueasyCam cam;
String [] lines;
/********************image********************************/
PImage Rulebg;
PImage Facebg;
PImage gamebg;
PImage overbg;
PImage points; 
PImage combo;
PImage play_again;
PImage over;
PImage RuleImg;
PImage ReturnImg;
PImage DiffLeveImg;

PImage Tapping;
PImage your;
PImage balloon;
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
int LevelX, LevelY;
int LvButtonW = 652;
int LvButtonH = 116;

boolean rectOver = false;
boolean circleOver = false;
boolean IsPoping = false;

//process bar
int startTime; 
int counter; 
int maxTime; 
boolean done;
boolean bgsound;
void setup() {
  size(796, 1119, P3D);
  thread("Init");
  //set cam
  cam = new QueasyCam(this);
  cam.speed = 3;              // default is 3
  cam.sensitivity = 0.5;      // default is 2
  cam.controllable = false;
  cam.position = new PVector(width/2, height/2, 400);
  cam.pan = -PI/2;
  perspective(PI/3, (float)width/height, 0.01, 10000);
  /********************loading image*********************************/
  Facebg = loadImage("sparkle.jpg");
  Facebg.resize(796, 1119);
  Tapping = loadImage("tapping.png");
  your = loadImage("your.png");
  balloon = loadImage("balloons.png");
  
  hint(DISABLE_DEPTH_MASK);
  bgsound =false;
  //progress bar
  counter = 0; 
  startTime= millis(); 
  maxTime= 24000; 
  done=false;

  scenario = -1;
}
void renew()
{
  tick = 0;
  score = 0;
  curscore = 1;
  comboscore = 0;
  lastCor = " ";
}
void Init()
{

  /***************init bubbles************************/
  Init_max = width/(4*bubblewid);
  Init_pertumation();//init the random list
  systems = new ArrayList<Bubblesys>();
  systems.add(new Bubblesys(20));
  /*******************sound effect*************************************/
  PrepbgSound= new SoundFile(this, "Back_And_Forth_Game_-_David_Fesliyan.mp3");
  PrepbgAd = new Audio(PrepbgSound);
  bgsound = true;
  popsound = new SoundFile(this, "BalloonPopping.mp3");
  OVersound = new SoundFile(this, "gameOver.mp3");
  clockSound = new SoundFile(this, "clock.mp3");
  GamebgSound = new SoundFile(this, "Seriously_-_David_Fesliyan.mp3");
  GamebgAd = new Audio(GamebgSound);
  BasicbgSound = new SoundFile(this, "Sneaky_Rascal_-_David_Fesliyan.mp3");
  BasicbgAd = new Audio(BasicbgSound);

  /******************start image******************************/
  ReturnImg = loadImage("return.png");
  ReturnImg.resize(150, 150);
  DiffLeveImg = loadImage("Level.png");
  /**********************game image***********************************/
  OImg = loadImage("popping_balloons.png");
  Skeleton = loadImage("skeleton.png");
  Skeleton.resize(120, 120);

  Rulebg = loadImage("dreamnight.jpg");
  Rulebg.resize(796, 1119);
  gamebg = loadImage("tumblr.jpg");
  gamebg.resize(796, 1119);

  ClockImg =loadImage("clock.png");
  ClockImg.resize(120, 120);
  Timeleft = loadImage("timeleft.png");
  Timeleft.resize(120, 120);

  RuleImg = loadImage("rules.jpg");
  RuleImg.resize(rectW, rectH);

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
  /************************button image parameter**************************************************/
  rectX = width/2-rectW/2;
  rectY = height/2-rectH/2-300;
  LevelX = width/2 -DiffLeveImg.width/2;
  LevelY = height/2 - DiffLeveImg.height/2;
  startX = (width-W)/2;
  startY = 75;
  paX = startX + 30 ;
  paY = width-50;
  Showtime = String.valueOf(TotalTime);
  /**********************game logic*************************************/
  TotalTime = 10;
  renew();
  renewTar();
  oldswitchT = newswithcT =0;

  //finish start to play
  scenario = 0;
  
}
void drawbubbles()
{
  for (ParticleSystem ps : systems) {
    if (tick==0)
      ps.addParticle();
    ps.run();
  }
}
void draw() {
  tint(255, 180);
  switch(scenario)
  {
  case -1:
      background(Facebg);
      textquad(Tapping, 200, 20, Tapping.width, Tapping.height);
      textquad(your, 250, 200, your.width, your.height);
      textquad(balloon, 200, 400, balloon.width, balloon.height);
    if (bgsound)
    {
      PrepbgAd.Loopsound(0.5);
    }

    drawbubbles();
    String process = "0.0";
    if (counter-startTime < maxTime) 
    {
      counter=millis();
      double percentage = (counter-startTime)/float(maxTime) *100.0;
      DecimalFormat df=new DecimalFormat("#.0");
      process = df.format(percentage);
    } else 
    {
      process = "100.0";
      done=true;
    }
    int BarW = 500;
    int BarH = 50;
    fill(153, 51, 255);
    noStroke();
    rect(width/2 - BarW/2, 2*height/3, map(counter-startTime, 0, maxTime, 0, BarW), BarH );
    words("Loading......"+" "+ process+"%", width/2, 2*height/3 + 2*BarH, 50);
    //text(counter- startTime+" " + int(maxTime) +  " " + int ( map(counter-startTime, 0, maxTime, 0, 200)), 20, 160);
    noFill();
    stroke(0);
    rect(width/2 - 250, 2*height/3, BarW, BarH);

    tick = (tick+1)%10;
    break;
  case 0:
    background(Facebg);
    PrepbgAd.Stopsound();
    BasicbgAd.Loopsound(0.5);
    drawbubbles();
    Bar();
    tick = (tick+1)%10;
    break;
  case 1:
    background(gamebg);
    GamebgAd.Loopsound(0.5);
    //ambientLight(255, 255, 255);
    //directionalLight(204, 229, 205, 1, 1, 0);
    //pointLight(51, 102, 126, 35, 40, 36);
    int curtime = millis();
    float sconds = (curtime - starttime)/1000.0;
    if (tick==0)  // show time left
    {
      double time = TotalTime - sconds;
      DecimalFormat df=new DecimalFormat("#.00");
      Showtime = df.format(time);
    }
    if (sconds>=TotalTime)
    {
      scenario = 2;
      tick = 0;
    } else
    {      
      textquad(Timeleft, width/2, 50, Timeleft.width, Timeleft.height);
      words(Showtime, width/2+2*Timeleft.width, 120, Timeleft.height/2);
      for (ParticleSystem ps : Balloonsystems) {
        ps = (Ballonsys)ps;
        if (tick==0)
        {
          if(DiffLv==2)
          {
            ps.addParticle(new PVector(0, -5, 0));
          }
          else
          {
            ps.addParticle();
          }
        }
          
        ps.run();
        ComputeScore(ps);
      }

      switch(DiffLv)
      {
      case 0:
        break;
      case 1:
        newswithcT = millis();
        if ((newswithcT - oldswitchT)% SwitchInterval <5)
        {
          renewTar();
          oldswitchT = newswithcT;
        }
        ShowTarget(OImg);
        break;
        case 2:
        newswithcT = millis();
        if ((newswithcT - oldswitchT)% SwitchInterval <5)
        {
          renewTar();
          oldswitchT = newswithcT;
        }
        ShowTarget(OImg);
        break;
      }

      tick = (tick+1)%60;
    }
    break;
  case 2://game over
    tint(255, 126);
    background(overbg);
    GamebgAd.Stopsound();
    PrepbgAd.Loopsound(0.9);
    tint(255, 255);
    Gameover();
    break;
  case 3://rules
    BasicbgAd.Loopsound(0.5);
    background(Rulebg);
    ShowText(lines);
    //return button
    textquad(ReturnImg, width - ReturnImg.width-20, 20, ReturnImg.width, ReturnImg.height);
    break;
  case 4://choose level
    BasicbgAd.Loopsound(0.5);
    background(Facebg);//clean the screen 
    drawbubbles();

    textquad(DiffLeveImg, LevelX, LevelY, DiffLeveImg.width, DiffLeveImg.height);
    //return button
    textquad(ReturnImg, width - ReturnImg.width-20, 20, ReturnImg.width, ReturnImg.height);
    tick = (tick+1)%10;
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
      scenario = 4;
      BasicbgAd.Stopsound();
      tick = 0;
      systems = new ArrayList<Bubblesys>();
      systems.add(new Bubblesys(20));
    } else if (overRect(rectX, rectY+2*rectH, RuleImg.width, RuleImg.height))
    {
      scenario = 3;
      BasicbgAd.Stopsound();
      tick = 0;
      lines = readFile("Rules.txt");
    }
    break;
  case 1:
    for (Ballonsys ps : Balloonsystems) {
      click_balloons(ps);
    }
    break;
  case 2: //game over
    if (overRect(paX, paY, paW, paH))
    {
      scenario = 0;
      BasicbgAd.Stopsound();
      systems = new ArrayList<Bubblesys>();
      systems.add(new Bubblesys(20));      
      renew();
    }
    break;
  case 3:  //rules
    if (overRect( width - ReturnImg.width-20, 20, ReturnImg.width, ReturnImg.height))
    {
      scenario = 0;
      BasicbgAd.Stopsound();
      systems = new ArrayList<Bubblesys>();
      systems.add(new Bubblesys(20));      
      renew();
    }
    break;
  case 4:
    if (overRect(LevelX, LevelY+18, LvButtonW, LvButtonH))
    {
      InitGame();
      DiffLv = 0;
    } else if (overRect(LevelX, LevelY+176, LvButtonW, LvButtonH))
    {
      InitGame();
      oldswitchT =millis();
      DiffLv = 1;
    } else if (overRect(LevelX, LevelY+332, LvButtonW, LvButtonH))
    {
      DiffLv = 2;
      InitGame();
      oldswitchT =millis();
      
    } else if (overRect( width - ReturnImg.width-20, 20, ReturnImg.width, ReturnImg.height))
    {
      scenario = 0;
      BasicbgAd.Stopsound();
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
  // rule button
  textquad(RuleImg, rectX, rectY+2*rectH, RuleImg.width, RuleImg.height);
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
  //stroke(204, 102, 0);
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
  int maxzindex = -1;
  for (int i = 0; i< sys.particles.size(); ++i)
  {
    Particle p  = sys.particles.get(i);
    if (overRect(int(p.position.x-p.size.x/2), int(p.position.y - p.size.y/2), int(p.size.x), int(p.size.y)))
    {
      if (maxzindex==-1)
        maxzindex=i;
      else if (p.position.z>sys.particles.get(maxzindex).position.z)
        maxzindex = i;
    }
  }
  if (maxzindex>=0)
  {
    Ballon b = (Ballon)sys.particles.get(maxzindex);
    b.pop = true;
  }
}

void InitGame()
{
  scenario = 1;
  BasicbgAd.Stopsound();
  tick = 0;
  starttime = millis();
  Balloonsystems = new ArrayList<Ballonsys>();
  if(DiffLv==2)
  {
    Balloonsystems.add(new Ballonsys(0,new PVector(0, -5, 0)));//new PVector(random(-1, 1), random(-50, -30), 0)
  }
  else
  {
    Balloonsystems.add(new Ballonsys(0));
  }
  
}
