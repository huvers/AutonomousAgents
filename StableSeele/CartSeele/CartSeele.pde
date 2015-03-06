
import java.util.List;
import java.util.Map;
import java.util.LinkedList;
import java.util.Map.Entry;

World world;
PImage map;

void setup() {
  size(800, 600);
  frameRate(20);
  map = loadImage("Map.png");
  world = new CartWorld();

  world.addActor(new Cart(400,100,0, new BasicMotive(10)));
  world.addActor(new Cart(300,100,0, new BasicMotive(5)));
  world.addActor(new Cart(200,100,0, new BasicMotive(2)));
  world.addActor(new Cart(100,100,0, new BasicMotive(1)));
   
}

void draw() {
  world = world.update();
  PGraphics pg = createGraphics(800, 600);
  pg.beginDraw();
  world.draw(pg);
  drawDots(pg);
  
  pg.endDraw();
  image(pg, 0, 0);
  // println(((CartWorld)world).currCart().xya.pos.x);
}

void drawDots(PGraphics pg) {
  pg.stroke(#00FF00);
  for (PVector pv : fdots) pg.point(pv.x, pv.y);
  pg.stroke(#FF0000);
  for (PVector pv : ldots) pg.point(pv.x, pv.y);
  pg.stroke(#0000FF);
  for (PVector pv : rdots) pg.point(pv.x, pv.y);
  
  fdots.clear();
  ldots.clear();
  rdots.clear();   
}

color mget(XYA xya) { return map.get((int)xya.pos.x, (int)xya.pos.y); }
