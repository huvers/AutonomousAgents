int width = 1000;
int height = 600;
boolean loop = true;

color black = color(0, 0, 0);
color white = color(255, 255, 255);
color green = color(0, 255, 0);
MapFactory map;
MapFactory mapOverlay = null;
PImage mapImage = null;

void setup() {
  size(width, height);
  if (loop){
    frameRate(10);
  }
  else {
    noLoop();
  }
  
  // map = new RandomMapFactory(width, height, black, white, green, 20, .5);
  // map = new LoopMapFactory(width, height, black, white, green, 30, 100, 20, 20);
  // map = new MazeMapFactory(width, height, black, white, green, 20, .5);
  map = new LighthouseMapFactory(width, height, black, white, 100, 1000);
  // mapOverlay = new LighthouseMapFactory(width, height, black, white, 100, 1000);
}

void draw() {
  background(white);
  PImage image;
  if (mapOverlay == null){
    image = map.generateMap();
  }
  else {
    if (mapImage == null){
      mapImage = map.generateMap();
    }
    image = mapOverlay.compositeMap(mapImage, map);
  }
  image(image, 0, 0);
}
