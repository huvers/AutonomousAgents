World world;

void setup() {
  size(500, 400);
  frameRate(20);
  // noLoop();
  world = new CheckersWorld();
  // world = new StickWorld(new PVector(202,200), new PVector(200,0), new PVector(0,0), new PVector(0,0), 1, 2, 0.02);
}


// int refocusRate = 100;
// int refocusCount = 0;
void draw() {
  world.getInput();
  world.updateObjs();
  world.draw(this);
  
  // if (refocusCount > refocusRate){
  //   refocus();
  //   refocusCount = 0;
  // }
  // refocusCount++;
}

void mouseClicked() {
  // refocus();
  redraw();
}


// void refocus(){
//   float xDiff = width/2-((StickWorld)world).stickBotLoc.x;
//   ((StickWorld)world).stickTopLoc.x += xDiff;
//   ((StickWorld)world).stickBotLoc.x += xDiff;
// }
