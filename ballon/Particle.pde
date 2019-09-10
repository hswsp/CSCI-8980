import java.util.List;
import java.util.Collections;
int bubblewid = 30;
int bubblehig = 30;
int Init_max;

List<Integer> list = new ArrayList<Integer>();
// A simple Particle class
class Particle {
  PVector position;
  PVector pos_old;
  PVector velocity;
  PVector acceleration;
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

class balloon extends Particle {
  float size;
  float theta;
  PVector Color;
  // The balloon constructor can call the parent class (super class) constructor
  balloon(PVector l) {
    // "super" means do everything from the constructor in Particle
    super(l);
    // One more line of code to deal with the new variable, theta
    theta = 0.0;   
    size = random(0.5*bubblewid,2*bubblewid);
    Color = new PVector(random(255), random(255), random(255));
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
      float desiredseparation = 1.5*(size+other.size);
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
  PVector align (ArrayList<balloon> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (balloon other : boids) {
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
  PVector cohesion (ArrayList<balloon> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (balloon other : boids) {
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
    fill(Color.x, Color.y, Color.z, lifespan);//255, 102, 255,
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

void Init_pertumation()
{
  for (int i=0; i<Init_max; ++i)
  {
    list.add(i);
  }
  Collections.shuffle(list);
}


// An ArrayList is used to manage the list of Particles

class ParticleSystem {

  ArrayList<balloon> particles;    // An arraylist for all the particles
  //PVector origin;                   // An origin point for where particles are birthed
  int pertindex;
  ParticleSystem(int num) {
    particles = new ArrayList<balloon>();   // Initialize the arraylist
    pertindex = 0;
    
    for (int i = 0; i < num; i++) {
      float y=random(height - 2*bubblewid, height);
      PVector origin = getorigin(y);
      particles.add(new balloon(origin));    // Add "num" amount of particles to the arraylist
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
    float y=random(height - 2*bubblewid, height);
    
    
    PVector origin = getorigin(y);
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
