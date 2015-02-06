int width = 1000;
int height = 600;
boolean loop = true;

color black = color(0, 0, 0);
color white = color(255, 255, 255);
MapFactory map;

void setup() {
  size(width, height);
  if (loop){
    frameRate(10);
  }
  else {
    noLoop();
  }
  
  // map = new RandomMapFactory(width, height, black, 20, .5);
  // map = new LoopMapFactory(width, height, black, 30, 100, 20, 20);
  map = new MazeMapFactory(width, height, black, 20, .5);
}

void draw() {
  background(white);
  PImage mapImage = map.generateMap();
  image(mapImage, 0, 0);
}
