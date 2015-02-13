import java.util.List;

World world;

void setup() {
  size(800, 600);
  frameRate(20);
  world = new CartWorld("Map2.png");
  Actor a = new CartActor(100, 100, "player.png");
  
  place(world, a);
}

void draw() {
  world.update();
  world.draw(this);
}
