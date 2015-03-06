
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
  Actor actor = new Actor();
  actor.addMotive("Basic", new BasicMotive(5));  
  ((CartWorld)world).addCart(new Cart(100,100,0, actor));
  
  Actor actor2 = actor.cpy();
  ((CartWorld)world).addCart(new Cart(100,200,0, actor2));
  
  Actor actor3 = actor.cpy();
  ((CartWorld)world).addCart(new Cart(100,300,0, actor3));
  
  Actor actor4 = actor.cpy();
  ((CartWorld)world).addCart(new Cart(100,400,0, actor4));
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
