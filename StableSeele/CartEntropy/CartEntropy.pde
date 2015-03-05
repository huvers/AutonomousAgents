import java.util.List;

World world;
Actor a;

void setup() {
  size(800, 600);
  frameRate(20);
  world = new CartWorld("Map.png");
  a = new CartActor(100, 100);
  
  place(world, a);
}

void draw() {
  world.update();
  world.draw(this);
  println(((CartActor)a).pstate.pos.x);
}
