
import java.util.List;
import java.util.Map;
import java.util.LinkedList;

World world;
PImage map;

void setup() {
  
  map = loadImage("Map.png");
  CartWorld world = new CartWorld();
  Actor actor = new Actor();
  actor.addMotive("Basic", new BasicMotive(5,0));
  world.addCart(new Cart(100,100,0, actor));
}

void draw() {
  world = world.update();
  PGraphics pg = createGraphics(800, 600);
  world.draw(pg);
  image(pg, 0, 0);
}
