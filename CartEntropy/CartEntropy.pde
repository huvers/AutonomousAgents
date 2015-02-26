import java.util.List;

World world;

void setup() {
  size(1200, 900);
  frameRate(20);
//  world = new CartWorld("Map2.png");
  world = new CartWorld("Map3.png");
  Actor a = new CartActor(160, 100, "player.png");
  Actor b = new CartActor(180, 180, "player.png");
  Actor c = new CartActor(180, 150, "player.png");
  
  place(world, a);
  place(world, b);
  place(world, c);
}

void draw() {
  world.update();
  world.draw(this);
}
