/*
 * Interface for World Object that ensures basic functionality
 */
interface World {
  void update();
  void draw(CartEntropy canvas);
  boolean isValidLoc(PVector pos);
  boolean isValidLoc(int x, int y);

  void addActor(Actor actor);
}

/*
 * Basic World for Cart simulations
 */
class CartWorld implements World {
  // the loaded map
  PImage map;
  
  // list of actors that will interact with map and each other
  List<Actor> actors = new ArrayList<Actor>();

  // constructor that loads map
  CartWorld(String mapFile) {
    map = loadImage(mapFile);
  }
  
  // calls update on all actors
  void update() {
    for (Actor a : actors) {
      a.act();
    }
  }
  
  // draws the world onto screen
  void draw(CartEntropy canvas) {
    background(255);
    //canvas.rotate(radians(30));
    canvas.image(map, 0, 0);
    //canvas.rotate(radians(-30));
    //canvas.line(0, 0, 800, 600);
    for (Actor a : actors) {
      a.draw(canvas);
    }
  }

  // take
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
