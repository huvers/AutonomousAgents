interface Actor {
  void act();
  void draw(CartEntropy canvas);

  void setPos(PVector pos);
  PVector getPos();

  // void setWorld(World world);
  // World getWorld();
  // void setWorld();
}

class CartActor implements Actor {
  PosState pstate; // actor's position and direction
  PImage img; // actor's sprite image

  int vel = 8; // pixels moved per step
  int turn = 30; // amount turned per step
  int depth = 5; // depth of movement tree
  int bredth; // TODO implment bredth restrictions

  List<PosState> leftLst = new ArrayList<PosState>();
  List<PosState> noneLst = new ArrayList<PosState>();
  List<PosState> rightLst = new ArrayList<PosState>();

  CartActor(int x, int y, String filename) {
    PVector pos = new PVector(x, y);
    PVector dir = PVector.fromAngle(0);
    pstate = new PosState(pos, dir);
    img = loadImage(filename);
  }

  // generates the states and selects next movement
  void act() {
    genPosStates(depth);

    // println(leftLst.size(), noneLst.size(), rightLst.size());

    pstate = getMove();
  }

  // draws cart on canvas
  void draw(CartEntropy canvas) {
    canvas.stroke(#000000);
    canvas.fill(#FF0000);
    canvas.image(img, pstate.pos.x - img.width/2, pstate.pos.y - img.height/2);
    //canvas.ellipse(pstate.pos.x, pstate.pos.y, 16, 16);

    canvas.stroke(#FF0000);
    for (PosState ps : leftLst) {
      canvas.point(ps.pos.x, ps.pos.y);
    }

    canvas.stroke(#00FF00);
    for (PosState ps : noneLst) {
      canvas.point(ps.pos.x, ps.pos.y);
    }

    canvas.stroke(#0000FF);
    for (PosState ps : rightLst) {
      canvas.point(ps.pos.x, ps.pos.y);
    }
  }

  // get/set methods
  
  // sets pos
  void setPos(PVector pos) {
    this.pstate.pos = pos;
  }

  // returns pos
  PVector getPos() {
    return pstate.pos;
  }


  // clear lists and repopulate
  void genPosStates(int depth) {
    PosState left = pstate.getLeft();
    PosState none = pstate.getNone();
    PosState right = pstate.getRight();

    leftLst.clear();
    noneLst.clear();
    rightLst.clear();
    
    genPosStates(left, depth - 1, leftLst);
    genPosStates(none, depth - 1, noneLst);
    genPosStates(right, depth - 1, rightLst);
  }

  // returns the PosState for the list with most elements
  PosState getMove() {
    int leftLen = leftLst.size();
    int noneLen = noneLst.size();
    int rightLen = rightLst.size();

    if (noneLen >= leftLen && noneLen >= rightLen) {
      return pstate.getNone();
    } else if (leftLen >= rightLen) {
      return pstate.getLeft();
    } else {
      return pstate.getRight();
    }
  }


  // recursive function to generate valid moves depth chances in the future
  void genPosStates(PosState ps, int depth, List lst) {
    if (depth > 0) {
      if (!this.isValidLoc(ps)) return;
      
      PosState left = ps.getLeft();
      PosState none = ps.getNone();
      PosState right = ps.getRight();

      if (this.isValidLoc(left)) {
        genPosStates(left, depth - 1, lst);
      }
      if (this.isValidLoc(none)) {
        genPosStates(none, depth - 1, lst);
      }
      if (this.isValidLoc(right)) {
        genPosStates(right, depth - 1, lst);
      }
      // if (world.isValidLoc(left.pos)) {
      //   genPosStates(left, depth - 1, lst);
      // }
      // if (world.isValidLoc(none.pos)) {
      //   genPosStates(none, depth - 1, lst);
      // }
      // if (world.isValidLoc(right.pos)) {
      //   genPosStates(right, depth - 1, lst);
      // }
    } else {
      if (world.isValidLoc(ps.pos)) {
        lst.add(ps);
      }
    }
  }
  
  boolean isValidLoc(PosState ps) {
    pushMatrix();
    
    fill(255);
    rect(0,0,10,10);
    
    translate(ps.pos.x, ps.pos.y);
    rotate(PVector.angleBetween(ps.dir, new PVector(1,0)));
    
    PImage portion = get(0,0,img.width,img.height);
    portion.loadPixels();
    img.loadPixels();
    boolean isValid = true;
    for (int i = 0; i < portion.pixels.length; i++) {
      if (red(portion.pixels[i]) < 200 && alpha(img.pixels[i]) < 240) {
        isValid = false;
        for (int j = 0; j< portion.pixels.length; j++){
          print(red(portion.pixels[j]));
        }
        break;
      }
    }
    
    // PGraphics dupLayer = createGraphics(width, height, JAVA2D); 
    // dupLayer.loadPixels(); 
    // arrayCopy(pixels, dupLayer.pixels); 
    // dupLayer.updatePixels();
    // dupLayer.image(img, 0, 0);
    
    popMatrix();
    return isValid;
  }

  // class that represents a position and direction
  class PosState {
    PVector pos, dir;

    // constructor for new PosState
    PosState(PVector pos, PVector dir) {
      this.pos = pos;
      this.dir = dir;
    }

    // make PosState if actor turns left and takes step forward
    PosState getLeft() {
      PVector dir = this.dir.copy();
      dir.rotate(-turn * PI / 180);
      PVector pos = PVector.add(this.pos, PVector.mult(dir, vel));
      return new PosState(pos, dir);
    }

    // makes PosState if actor just takes step forward
    PosState getNone() {
      PVector dir = this.dir.copy();
      PVector pos = PVector.add(this.pos, PVector.mult(dir, vel));
      return new PosState(pos, dir);
    }

    // makes PosState if actor turns right and takes step forward
    PosState getRight() {
      PVector dir = this.dir.copy();
      dir.rotate(turn * PI / 180);
      PVector pos = PVector.add(this.pos, PVector.mult(dir, vel));
      return new PosState(pos, dir);
    }
  }
}
