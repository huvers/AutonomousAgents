
final List<PVector> dots = new ArrayList<PVector>(); 


class BasicMotive extends Motive {
  int depth, bredth;
  
  BasicMotive(int depth, int bredth) {
    this.depth = depth;
    this.bredth = bredth;
  }
  
  BasicMotive(BasicMotive motive) {
    this.depth = motive.depth;
    this.bredth = motive.bredth;
  }
  
  Action getVote(World world) {
    List<Action> actions = world.currValidActions();
    
    Action maxAction = null;
    int maxEntropy = Integer.MIN_VALUE;
    
    for (Action action : actions) {
      int entropy = recursive(world.transform(action), depth - 1);
      if (entropy > maxEntropy) {
        maxAction = action;
        maxEntropy = entropy;
      }
      //print(action.data + ": " + entropy + " | ");
    }
    //println();
    return maxAction;
  }
  
  private int recursive(World world, int remainDepth) {    
    if (remainDepth <= 0) { dots.add(((CartWorld)world).currCart().xya.pos); ;return 1;}
    
    int count = 0;
    List<Action> actions = world.currValidActions();
    
    for (Action action : actions) {
      count += recursive(world.transform(action), remainDepth - 1);
    }
    
    return count;
  }
  
  Object clone() {
    return new BasicMotive(this);
  }
}





class CartWorld extends World {
  final List<Cart> carts = new LinkedList<Cart>();
  
  CartWorld() {}
  CartWorld(CartWorld world) {
    for (Cart c : world.carts) {
      carts.add(c.clone());
    }
  }
  
  void addCart(Cart cart) {
    carts.add(cart);
  }
  
  World update() {
    World world = this;
    for (int i = 0; i < carts.size(); i++) {
      world = world.transform(currActor().getAction(world));
      carts.add(carts.remove(0));
    }
    return world;
  }
  
  Cart currCart() {
    return carts.get(0);
  }
  
  Actor currActor() {
    return currCart().actor;
  }
  
  List<Action> currValidActions() {
    List<Action> lst = new ArrayList<Action>();
    
    XYA fxya = currCart().getForward();
    XYA lxya = currCart().getLeft();
    XYA rxya = currCart().getRight();
    
    if (map.get((int)fxya.pos.x, (int)fxya.pos.y) != #000000) {
      lst.add(new Action("f"));
    }
    if (map.get((int)lxya.pos.x, (int)lxya.pos.y) != #000000) {
      lst.add(new Action("l"));
    }
    if (map.get((int)rxya.pos.x, (int)rxya.pos.y) != #000000) {
      lst.add(new Action("r"));
    }
    return lst; // TODO
  }
  
  World transform(Action action) {
    CartWorld world = new CartWorld(this);
    if (action != null){
      if (action.data.equals("f")) {
        world.currCart().xya = world.currCart().getForward();
      } else if (action.data.equals("l")) {
        world.currCart().xya = world.currCart().getLeft();
      } else if (action.data.equals("r")) {
        world.currCart().xya = world.currCart().getRight();
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
  
  World clone() {
    return new CartWorld(this);
  }
}





final int CART_VEL = 8;
final int CART_TURN = 30;

class Cart {
  //PImage sprite;
  XYA xya;
  Actor actor;
  
  Cart(int x, int y, float a, Actor actor) {
    //sprite = loadImage(filename);
    xya = new XYA(x, y, a);
    this.actor = actor;
  }
  
  Cart(Cart cart) {
    this.xya = new XYA(cart.xya);
    this.actor = new Actor(cart.actor);
  }
  
  XYA getForward() {
    return xya.move(CART_VEL);
  }
  
  XYA getLeft() {
    return xya.turn(-CART_TURN).move(CART_VEL);
  }
  
  XYA getRight() {
    return xya.turn(CART_TURN).move(CART_VEL);
  }
  
  Cart clone() {
    return new Cart(this);
  }
}





class XYA {
  PVector pos;
  PVector angle;
  
  XYA(int x, int y, float a) {
    pos = new PVector(x, y);
    angle = PVector.fromAngle(radians(a));
  }
  
  XYA(PVector pos, PVector angle) {
    this.pos = pos;
    this.angle = angle;
  }
  
  XYA(XYA xya) {
    this.pos = new PVector(xya.pos.x, xya.pos.y);
    this.angle = new PVector(xya.angle.x, xya.angle.y);
  }
  
  XYA move(int vel) {
    return new XYA(PVector.add(pos, PVector.mult(angle, vel)), angle);
    
  }
  
  XYA turn(float a) {
    PVector rot = angle.copy();
    rot.rotate(radians(a));
    return new XYA(pos, rot);
  }
  
  XYA clone() {
    return new XYA(this);
  }
}
