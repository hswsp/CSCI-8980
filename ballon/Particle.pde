import java.util.List;
import java.util.Collections;
int bubblewid = 30;
int bubblehig = 30;
int Init_max;

String Color[]={"RED", "GREEN", "BLUE", "YELLOW", "PINK"};
List<Integer> list = new ArrayList<Integer>();
PImage  OImg;

void Init_pertumation()
{
  for (int i=0; i<Init_max; ++i)
  {
    list.add(i);
  }
  Collections.shuffle(list);
}


// A simple Particle class
class Particle {
  PVector position;
  PVector pos_old;
  PVector velocity;
  PVector acceleration;
  PVector size;

  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0, -0.5); // opposite gravity
    velocity = new PVector(random(-1, 1), random(-2, 0));
    position = l.copy();
    pos_old = position.copy();
    maxspeed = 2;
    maxforce = 0.03;
    lifespan = 510;
    float s = random(bubblewid, 3*bubblewid);
    size =new PVector(s, s);
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Particle> boids) {
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Particle other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      float threshold1 = max(size.x, size.y);
      float threshold2 = max(other.size.x, other.size.y);
      float desiredseparation = 1.5*(threshold1+threshold2);
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }
  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Particle> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Particle other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Particle> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Particle other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0);
    }
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Particle> boids) {
    PVector sep = separate(boids);   // Separation
    // Arbitrarily weight these forces
    sep.mult(1.5);
    // Add the force vectors to acceleration
    applyForce(sep);
  }
  // overwrite run()
  void run(ArrayList<Particle> boids) {
    flock(boids);
    update();
    display();
  }

  // Method to update position
  void update() {
    // t==1
    velocity.add(acceleration);
    position.add(velocity).add(acceleration.mult(0.5));//mid point
    // colliosn with the edge
    if (position.x<=size.x)
    {
      position.x = size.x;
      velocity.x = -velocity.x;
    } else if (position.x>=width - size.x)
    {
      position.x = width -size.x;
      velocity.x = -velocity.x;
    }
    lifespan -= 1;
  }

  // Method to display
  void display() {
    stroke(255, lifespan);
    fill(255, 102, 255, lifespan);
    ellipse(position.x, position.y, 8, 8);
  }

  // Is the particle still useful?
  boolean isDead() {
    return (lifespan < 0.0);
  }
}

// A subclass of Particle
class Bubble extends Particle {
  PVector Color;
  // The balloon constructor can call the parent class (super class) constructor
  Bubble(PVector l) {
    // "super" means do everything from the constructor in Particle
    super(l); 
    Color = new PVector(random(255), random(255), random(255));
  }

  // This display() method overrides the parent class display() method
  void display() {
    stroke(255, lifespan);
    fill(Color.x, Color.y, Color.z, lifespan);//255, 102, 255,
    ellipse(position.x, position.y, size.x, size.y);
  }
}

class Ballon extends Particle {
  float theta;
  int cellW;
  int cellH;    
  int baW ;
  int baH;
  boolean pop;
  int step;
  String COLOR;
  PImage balImg;
  void Init()
  {
    theta = 0;
    baW = 120;
    baH = 240;
    cellW = 79;
    cellH = 118;
    size.x = baW;
    size.y = baH;
    step = 0;
    velocity = velocity.mult(3);
    pop = false;
  }
  // The balloon constructor can call the parent class (super class) constructor
  Ballon(PVector l) {
    // "super" means do everything from the constructor in Particle
    super(l); 
    Init();
    PImage  OImg = loadImage("popping_balloons.png");
    balImg = OImg.get(3*cellW, 0, cellW, cellH);
    balImg.resize(baW, baH);
  }
  Ballon(PVector l, String Col) {
    // "super" means do everything from the constructor in Particle
    super(l); 
    Init();
    COLOR = Col;
    int cellW = 79;
    int cellH = 118;    
    switch(Col)
    {
    case "BLUE":
      balImg = OImg.get(237, 10, cellW, cellH);
      break;
    case "RED":
      balImg = OImg.get(237, 202, cellW, cellH);
      break;
    case "GREEN":
      balImg = OImg.get(237, 395, cellW, cellH);
      break;
    case "YELLOW":
      balImg = OImg.get(237, 590, cellW, cellH);
      break;
    case "PINK":
      balImg = OImg.get(237, 790, cellW, cellH);
      break;
    }
    balImg.resize(baW, baH);
  }
  void Find_Pop_by_step(int y)
  {
    switch(step)
    {
    case 1:
      balImg = OImg.get(237 + int(0.9*cellW), y, cellW, cellH);
      break;
    case 2:
      balImg = OImg.get(237 + int(1.8*cellW), y, cellW, cellH);
      break;
    case 3:
      balImg = OImg.get(237 + int(2.7*cellW), y, cellW, cellH);
      break;
    case 4:
      balImg = OImg.get(237 + 4*cellW, y, cellW, cellH);
      break;
    case 5:
      balImg = OImg.get(237 + 5*cellW, y, cellW, cellH);
      break;
    case 6:
      balImg = OImg.get(237 + 6*cellW, y, int(2*cellW), cellH);
      break;
    case 7:
      lifespan = -1;
      break;
    default:
      break;
    }
  }
  void Poping()
  {
    if (pop)
    {
      step++;
      if (step ==8)
      {
        step = 0;
        pop = false;
      }
      switch(COLOR)
      {
      case "BLUE":
        Find_Pop_by_step(10);
        break;
      case "RED":
        Find_Pop_by_step(202);
        break;
      case "GREEN":
        Find_Pop_by_step(395);
        break;
      case "YELLOW":
        Find_Pop_by_step(590);
        break;
      case "PINK":
        Find_Pop_by_step(790);
        break;
      }
      balImg.resize(baW, baH);
    }
  }
  // This update() method overrides the parent class update() method
  void update() {
    super.update();
    // Increment rotation based on horizontal velocity
    float theta_vel = (velocity.x * velocity.mag()) / 10.0f;
    theta += theta_vel;
    Poping();
  }

  // This display() method overrides the parent class display() method
  void display() {
    noStroke();
    beginShape();
    texture(balImg);
    vertex(position.x - baW/2, position.y - baH/2, 0, 0);
    vertex(position.x + baW/2, position.y- baH/2, baW, 0);
    vertex(position.x + baW/2, position.y + baH/2, baW, baH);
    vertex(position.x- baW/2, position.y + baH/2, 0, baH);
    endShape();
  }
}

// An ArrayList is used to manage the list of Particles

class ParticleSystem {
  ArrayList<Particle> particles;    // An arraylist for all the particles
  //PVector origin;                   // An origin point for where particles are birthed
  int pertindex;
  int number;
  ParticleSystem(int num) {
    particles = new ArrayList<Particle>();   // Initialize the arraylist
    pertindex = 0;
    number = num;
  }
  void Init()
  {
    for (int i = 0; i < number; i++) {
      float y=random(height - 2*bubblewid, height);
      PVector origin = getorigin(y);
      particles.add(new Particle(origin));    // Add "num" amount of particles to the arraylist
    }
  }
  PVector getorigin(float y)
  {
    PVector origin = new PVector((1+list.get(pertindex))*bubblewid*4, y);
    pertindex = pertindex+1;
    if (pertindex>=Init_max)
    {
      Collections.shuffle(list);
      pertindex=0;
    }
    return origin;
  }


  void run() {
    // Cycle through the ArrayList backwards, because we are deleting while iterating
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run(particles);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  void addParticle(Particle p) {
    particles.add(p);
  }

  void addParticle() {
    Particle p;
    float y=random(height - 2*bubblewid, height);
    PVector origin = getorigin(y);
    p = new Particle(origin);
    particles.add(p);
  }
  // A method to test if the particle system still has particles
  boolean dead() {
    return particles.isEmpty();
  }
}

class Bubblesys extends ParticleSystem
{
  Bubblesys(int num) {
    super(num);
    Init();
  }
  // overwrite Init()
  void Init()
  {
    for (int i = 0; i < number; i++) {
      float y=random(bubblewid, height);
      PVector origin = getorigin(y);
      particles.add(new Bubble(origin));    // Add "num" amount of particles to the arraylist
    }
  }
  // overwrite Init()
  void addParticle() {
    Particle p;
    float y=random(height - 2*bubblewid, height);
    PVector origin = getorigin(y);
    p = new Bubble(origin);
    particles.add(p);
  }
}

class Ballonsys extends ParticleSystem
{
  Ballonsys(int num) {
    super(num);
    Init();
  }
  // overwrite Init()
  void Init()
  {
    for (int i = 0; i < number; i++) {
      float y=random(height + 2*bubblewid, height);
      PVector origin = getorigin(y);
      particles.add(new Ballon(origin));    // Add "num" amount of particles to the arraylist
    }
  }
  // overwrite Init()
  void addParticle() {
    Particle p;
    float y=random(height + 2*bubblewid, height);
    PVector origin = getorigin(y);

    // random color
    int col = int(random(5)) ;
    p = new Ballon(origin, Color[col]);
    particles.add(p);
  }
}
