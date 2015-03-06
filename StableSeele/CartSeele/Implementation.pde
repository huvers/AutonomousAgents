
List dots;
final List<PVector> fdots = new ArrayList<PVector>();
final List<PVector> ldots = new ArrayList<PVector>();
final List<PVector> rdots = new ArrayList<PVector>();

class BasicMotive extends Motive {
  int depth;
  
  BasicMotive(int depth) { this.depth = depth; }
  
  String getVote(World world) {
    List<String> actions = world.currValidActions();
    
    String maxAction = "";
    int maxEntropy = Integer.MIN_VALUE;
    
    for (String action : actions) {
      switch (action.charAt(0)) {
        case 'f': dots = fdots; break; 
        case 'l': dots = ldots; break;
        case 'r': dots = rdots; break;
      }

      int entropy = recursive(world.transform(action), depth - 1);
      if (entropy > maxEntropy) {
        maxAction = action;
        maxEntropy = entropy;
      }
    }
    return maxAction;
  }
  
  private int recursive(World world, int remainDepth) {    
    if (remainDepth <= 0) { dots.add(((CartWorld)world).currCart().xya.pos); return 1;}
    
    int count = 0;
    List<String> actions = world.currValidActions();
    
    for (String action : actions) {
      count += recursive(world.transform(action), remainDepth - 1);
    }
    
    return count;
  }
  
  private BasicMotive(BasicMotive motive) { this.depth = motive.depth; }
  Motive cpy() { return new BasicMotive(this); }
}

final int timerReset = 5;
class AvoidMotive extends Motive {
  final List<XYA> locations = new LinkedList<XYA>();
  int timer = timerReset;
  XYA avg = null;
  
  AvoidMotive() { }
  
  String getVote(World world) {
    timer--;
    if (timer == 0) { locations.add(((Cart)world.currActor()).xya.cpy()); avg = avgLocation(); timer = timerReset; }
    if (avg == null) { return ""; }
    
    List<String> actions = world.currValidActions();
    
    XYA currLoc = ( (Cart)(world.currActor()) ).xya;
    String maxAction = "";
    float maxDistance = 0;
    
    for (String action : actions) {
      World possible = world.transform(action);
      XYA nextLoc = ( (Cart)(possible.currActor()) ).xya;
      
      float dist = currLoc.dist(nextLoc);
      if (dist > maxDistance) { maxDistance = dist; maxAction = action; }
    }
    return maxAction;
  }
  
  private XYA avgLocation() {
    int avgx = 0, avgy = 0;
    if (locations.size() == 0) { return null; }
    for (XYA xya : locations) { avgx += xya.pos.x; avgy += xya.pos.y; }
    avgx /= locations.size();
    avgy /= locations.size();
    return new XYA(avgx, avgy, 0);    
  }
  
  private AvoidMotive(AvoidMotive motive) { for (XYA xya : motive.locations) { locations.add(xya.cpy()); } timer = motive.timer; avg = motive.avg; weight = motive.weight; }
  Motive cpy() { return new AvoidMotive(this); }
}



class CartWorld extends World {
  final List<Cart> carts = new LinkedList<Cart>();
  
  CartWorld() {}
  
  private void nextCart() { carts.add(carts.remove(0)); }
  
  World update() {
    World world = this;
    for (int i = 0; i < carts.size(); i++) {
      world = world.transform(world.currActor().getAction(world));
      ((CartWorld)world).nextCart();
    }
    return world;
  }
  
  void addActor(Actor actor) { carts.add((Cart)actor); } //TODO check if Cart
  Cart currCart() { return carts.get(0); }
  Actor currActor() { return currCart(); }
  
  List<String> currValidActions() {
    List<String> lst = new ArrayList<String>();
    
    XYA fxya = currCart().getForward();
    XYA lxya = currCart().getLeft();
    XYA rxya = currCart().getRight();
    
    if (mget(fxya) != #000000) { lst.add("f"); }
    if (mget(lxya) != #000000) { lst.add("l"); }
    if (mget(rxya) != #000000) { lst.add("r"); }
    return lst; // TODO
  }
  
  World transform(String action) {
    CartWorld world = new CartWorld(this);
    if (action != "") {
      switch (action.charAt(0)) {
        case 'f': world.currCart().xya = world.currCart().getForward(); break; 
        case 'l': world.currCart().xya = world.currCart().getLeft(); break;
        case 'r': world.currCart().xya = world.currCart().getRight(); break;
      }
    }
    return world;
  }
  
  void draw(PGraphics pg, int mode) {
    pg.image(map, 0, 0);
    for (Cart c : carts) {
      pg.fill(#FF0000);
      pg.ellipse(c.xya.pos.x, c.xya.pos.y, 16, 16);
    }
  }
  
  private CartWorld(CartWorld world) { for (Cart c : world.carts) carts.add(c.cpy()); }
  World cpy() { return new CartWorld(this); }
}





class Cart extends Actor {
  int vel = 8, turn = 30;
  XYA xya;
  
  Cart(int x, int y, float deg) { xya = new XYA(x, y, deg); }
  Cart(int x, int y, float deg, Motive... motives) {super(motives); xya = new XYA(x, y, deg); }
  
  XYA getForward() { return xya.mv(vel); }
  XYA getLeft() { return xya.rt(-turn).mv(vel); }
  XYA getRight() {  return xya.rt(turn).mv(vel); }
  
  private Cart(Cart cart) { super(cart); this.xya = new XYA(cart.xya); }
  Cart cpy() { return new Cart(this); }
}





class XYA { // TODO make immutable?
  PVector pos;
  PVector angle;
  
  XYA(int x, int y, float deg) { pos = new PVector(x, y); angle = PVector.fromAngle(radians(deg)); }
  
  XYA mv(int vel) { return new XYA(PVector.add(pos, PVector.mult(angle, vel)), angle); }
  XYA rt(float deg) { XYA c = cpy(); c.angle.rotate(radians(deg)); return c; }
  float dist(XYA xya) { float dx = (this.pos.x - xya.pos.x), dy = (this.pos.y - xya.pos.y); return (float)Math.sqrt(dx * dx + dy * dy); }
  
  private XYA(PVector pos, PVector angle) { this.pos = pos; this.angle = angle; } // dangerous because it doesn't copy PVectors
  private XYA(XYA xya) { this.pos = new PVector(xya.pos.x, xya.pos.y); this.angle = new PVector(xya.angle.x, xya.angle.y); }
  XYA cpy() { return new XYA(this); }
}
