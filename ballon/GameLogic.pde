import java.util.Map;
/*****************game logic*************************/
int starttime;
int score;
int curscore;
int comboscore;
String lastCor;
int TotalTime;
String Showtime;

int DiffLv;
int TargetBallon;
//Map<Integer,String> Target = new HashMap<Integer, String>();
/****************
0 - blue;
1 - red;
2 - green;
3 - yellow;
4 - pink;
******************/

int SwitchInterval = 2000;//in millisecond
int oldswitchT;
int newswithcT;
void ShowTarget(PImage  OImg)
{
  int cellW = 35;
  int cellH = 70;
  PImage  balImg = OImg.get(10, 790, cellW, cellH);
  switch(TargetBallon)
    {
    case 0:
      balImg = OImg.get(27, 48, cellW, cellH);
      break;
    case 1:
      balImg = OImg.get(27, 240, cellW, cellH);
      break;
    case 2:
      balImg = OImg.get(27, 435, cellW, cellH);
      break;
    case 3:
      balImg = OImg.get(27, 630, cellW, cellH);
      break;
    case 4:
      balImg = OImg.get(27, 825, cellW, cellH);
      break;
    }
    balImg.resize(80, 160);
    words("Target: ", 95, 45, 50);
    textquad(balImg, 50, 30, balImg.width, balImg.height);
}
void renewTar()
{
  TargetBallon =int(random(0, 5));
}

void ComputeScore(ParticleSystem ps)
{
  for (Particle P : ps.particles) {
     Ballon p = (Ballon)P;
     if(p.pop&&p.step==6)
     {
       if (p.Isclock)
      {
        TotalTime += 2;
      } else if (p.COLOR.equals(lastCor))
      {
        comboscore = comboscore+1;       
        curscore = 2*curscore;
      } else
      {
        curscore = 1;
      }
      lastCor = lastCor.copyValueOf(p.COLOR.toCharArray());
      switch(DiffLv)
      {
        case 0:
        break;
        case 1:
        if(p.COLOR==Color[TargetBallon])
        {
          curscore = 2*curscore;
        }
        break;
        case 2:
        if(p.COLOR==Color[TargetBallon])
        {
          curscore = 2*curscore;
        }
        break;
      }
      
      score = score + curscore;
     }
  }
}
