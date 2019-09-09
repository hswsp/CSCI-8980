ArrayList<ParticleSystem> systems;
int bubblewid = 30;
int bubblehig = 30;
int scenario; // control the start interface
PImage bg;

boolean rectOver = false;
boolean circleOver = false;
void setup() {
  size(1000, 1280, P3D);
  systems = new ArrayList<ParticleSystem>();
  systems.add(new ParticleSystem(5));
  scenario=0;

  bg = loadImage("dreamnight.jpg");
  bg.resize(1000, 1280);
}

void draw() {
  switch(scenario)
  {
  case 0:
    background(bg);
    break;
  case 1:

    background(10);
    for (ParticleSystem ps : systems) {
      ps.run();
      ps.addParticle();
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

//judge the position of the click point
boolean overRect(int x, int y, int width, int height)  {
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
void mousePressed() {

  //systems.add(new ParticleSystem(1, new PVector(mouseX, mouseY)));
}

// A simple Particle class

class Particle {
  PVector position;
  PVector pos_old;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0, -0.5); // opposite gravity
    velocity = new PVector(random(-1, 1), random(-2, 0));
    position = l.copy();
    pos_old = position.copy();
    lifespan = 255.0;
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }
  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    // t==1
    velocity.add(acceleration);
    position.add(velocity).add(acceleration.mult(0.5));//mid point
    lifespan -= 0.5;
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

class balloon extends Particle {

  int size;
  float theta;

  // The balloon constructor can call the parent class (super class) constructor
  balloon(PVector l) {
    // "super" means do everything from the constructor in Particle
    super(l);
    // One more line of code to deal with the new variable, theta
    theta = 0.0;   
    size = bubblewid;
  }


  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<balloon> boids) {

    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (balloon other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      float desiredseparation = 2*(size+other.size);
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
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();     
      steer.sub(velocity);
    }
    return steer;
  }
  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<balloon> boids) {
    PVector sep = separate(boids);   // Separation
    // Arbitrarily weight these forces
    sep.mult(1.5);
    // Add the force vectors to acceleration
    applyForce(sep);
  }
  // This update() method overrides the parent class update() method
  void update() {
    super.update();
    // Increment rotation based on horizontal velocity
    float theta_vel = (velocity.x * velocity.mag()) / 10.0f;
    theta += theta_vel;
  }
  // overwrite run()
  void run(ArrayList<balloon> boids) {
    flock(boids);
    update();
    display();
  }
  // This display() method overrides the parent class display() method
  void display() {
    stroke(255, lifespan);
    fill(255, 102, 255, lifespan);
    ellipse(position.x, position.y, size, size);
    //if need rotate
    //pushMatrix();
    //translate(position.x, position.y);
    //rotate(theta);
    //stroke(255, lifespan);
    //line(0, 0, 25, 0);
    //popMatrix();
  }
}


// An ArrayList is used to manage the list of Particles

class ParticleSystem {

  ArrayList<balloon> particles;    // An arraylist for all the particles
  //PVector origin;                   // An origin point for where particles are birthed

  ParticleSystem(int num) {
    particles = new ArrayList<balloon>();   // Initialize the arraylist
    for (int i = 0; i < num; i++) {
      float x=random(0, width);
      PVector origin = new PVector(x, height);
      particles.add(new balloon(origin));    // Add "num" amount of particles to the arraylist
    }
  }
  // collision detection
  //void collison()
  //{
  //  for(int i =0;i<particles.size() - 1;i++)
  //    for(int j=i+1;j<particles.size();++j)
  //    {
  //      balloon p1 = particles.get(i);
  //      balloon p2 = particles.get(j);
  //      float d = p1.position.dist(p2.position);
  //      if(d<=p1.size+p2.size)
  //      {
  //        p1.position = p1.pos_old;
  //        p2.position = p2.pos_old;
  //        p1.velocity = p2.velocity;
  //        p2.velocity = p1.velocity;
  //      }

  //    }     
  //  for(int i =0;i<particles.size();i++)
  //  {
  //    balloon p = particles.get(i);
  //    p.pos_old = p.position;
  //  }
  //}


  void run() {
    // Cycle through the ArrayList backwards, because we are deleting while iterating
    for (int i = particles.size()-1; i >= 0; i--) {
      balloon p = particles.get(i);
      p.run(particles);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  void addParticle() {
    balloon p;

    float x=random(0, width);
    PVector origin = new PVector(x, height);
    p = new balloon(origin);
    particles.add(p);
  }

  void addParticle(balloon p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    return particles.isEmpty();
  }
}
