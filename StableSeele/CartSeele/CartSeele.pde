
import java.util.List;
import java.util.Map;
import java.util.LinkedList;

World world;
PImage map;

void setup() {
  size(800, 600);
  frameRate(20);
  map = loadImage("Map.png");
  world = new CartWorld();
  Actor actor = new Actor();
  actor.addMotive("Basic", new BasicMotive(5,0));
  ((CartWorld)world).addCart(new Cart(100,100,0, actor));
}

void draw() {
  world = world.update();
  PGraphics pg = createGraphics(800, 600);
  pg.beginDraw();
  world.draw(pg);
  for (PVector pv : dots) pg.point(pv.x, pv.y);
  dots.clear();
  pg.endDraw();
  image(pg, 0, 0);
  println(((CartWorld)world).currCart().xya.pos.x);
}
