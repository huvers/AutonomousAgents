interface World {
  void update();
  void draw(CartEntropy canvas);
  boolean isValidLoc(PVector pos);
  boolean isValidLoc(int x, int y);

  void addActor(Actor actor);
}

class CartWorld implements World {
  PImage map;
  List<Actor> actors = new ArrayList<Actor>();

  CartWorld(String mapFile) {
    map = loadImage(mapFile);
  }

  void update() {
    for (Actor a : actors) {
      a.act();
    }
  }

  void draw(CartEntropy canvas) {
    background(255);
    canvas.image(map, 0, 0);
    //canvas.line(0, 0, 800, 600);
    for (Actor a : actors) {
      a.draw(canvas);
    }
  }

  boolean isValidLoc(PVector pos) {
    return isValidLoc((int)pos.x, (int)pos.y);
  }

  boolean isValidLoc(int x, int y) {
    color pixel = map.get(x, y);
    return (pixel != #000000); // color is not black
  }

  void addActor(Actor actor) {
    actors.add(actor);
  }
}
