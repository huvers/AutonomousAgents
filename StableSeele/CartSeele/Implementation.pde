
List dots;
final List<PVector> fdots = new ArrayList<PVector>();
final List<PVector> ldots = new ArrayList<PVector>();
final List<PVector> rdots = new ArrayList<PVector>();

class BasicMotive extends Motive {
  int depth;
  
  BasicMotive(int depth) { this.depth = depth; }
  
  String getVote(World world) {
    List<String> actions = world.currValidActions();
    
    String maxAction = null;
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





class CartWorld extends World {
  final List<Cart> carts = new LinkedList<Cart>();
  
  CartWorld() {}
  
  void addCart(Cart cart) { carts.add(cart); }
  private void nextCart() { carts.add(carts.remove(0)); println(carts); }
  
  World update() {
    World world = this;
    for (int i = 0; i < carts.size(); i++) {
      world = world.transform(currActor().getAction(world));
      ((CartWorld)world).nextCart();
    }
    return world;
  }
  
  Cart currCart() { return carts.get(0); }
  Actor currActor() { return currCart().actor; }
  
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
    if (action != null) {
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





class Cart {
  int vel = 8, turn = 30;
  XYA xya;
  Actor actor;
  
  Cart(int x, int y, float deg, Actor actor) { xya = new XYA(x, y, deg); this.actor = actor; }
  
  XYA getForward() { return xya.mv(vel); }
  XYA getLeft() { return xya.rt(-turn).mv(vel); }
  XYA getRight() {  return xya.rt(turn).mv(vel); }
  
  private Cart(Cart cart) { this.xya = new XYA(cart.xya); this.actor = new Actor(cart.actor); }
  Cart cpy() { return new Cart(this); }
}





class XYA {
  PVector pos;
  PVector angle;
  
  XYA(int x, int y, float deg) { pos = new PVector(x, y); angle = PVector.fromAngle(radians(deg)); }
  
  XYA mv(int vel) { return new XYA(PVector.add(pos, PVector.mult(angle, vel)), angle); }
  XYA rt(float deg) { XYA c = cpy(); c.angle.rotate(radians(deg)); return c; }
  
  private XYA(PVector pos, PVector angle) { this.pos = pos; this.angle = angle; } // dangerous because it doesn't copy PVectors
  private XYA(XYA xya) { this.pos = new PVector(xya.pos.x, xya.pos.y); this.angle = new PVector(xya.angle.x, xya.angle.y); }
  XYA cpy() { return new XYA(this); }
}
