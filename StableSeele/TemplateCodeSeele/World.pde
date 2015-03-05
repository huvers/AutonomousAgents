
abstract class World {  
  abstract World update();
  
  abstract Actor currActor();
  abstract List<Action> currValidActions();
  abstract World transform(Action action);
  
  void draw(PGraphics pg) {
    draw(pg, 0);
  }
  abstract void draw(PGraphics pg, int mode);
}
