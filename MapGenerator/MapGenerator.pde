int width = 1000;
int height = 600;
boolean loop = false;

color black = color(0, 0, 0);
color white = color(255, 255, 255);
color green = color(0, 255, 0);
MapFactory map;

void setup() {
  size(width, height);
  if (loop){
    frameRate(10);
  }
  else {
    noLoop();
  }
  
  // map = new RandomMapFactory(width, height, black, white, green, 20, .5);
  map = new LoopMapFactory(width, height, black, white, green, 30, 100, 20, 20);
  // map = new MazeMapFactory(width, height, black, white, green, 20, .5);
}

void draw() {
  background(white);
  PImage mapImage = map.generateMap();
  image(mapImage, 0, 0);
}
