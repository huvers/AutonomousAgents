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
  PosState pstate;

  int vel = 8;
  int turn = 30;
  int depth = 5;
  int bredth;

  List<PosState> leftLst = new ArrayList<PosState>();
  List<PosState> noneLst = new ArrayList<PosState>();
  List<PosState> rightLst = new ArrayList<PosState>();

  CartActor(int x, int y) {
    PVector pos = new PVector(x, y);
    PVector dir = PVector.fromAngle(0);
    pstate = new PosState(pos, dir);
  }

  void act() {
    // if (world.isValidLoc(x + vel, y)) {
    //   x = x + vel;
    // }

    genPosStates(depth);

    // println(leftLst.size(), noneLst.size(), rightLst.size());

    pstate = getMove();
  }

  void draw(CartEntropy canvas) {
    canvas.stroke(#000000);
    canvas.fill(#FF0000);
    canvas.ellipse(pstate.pos.x, pstate.pos.y, 16, 16);

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

  void setPos(PVector pos) {
    this.pstate.pos = pos;
  }

  PVector getPos() {
    return pstate.pos;
  }


  // act sub class and functions
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


  void genPosStates(PosState ps, int depth, List lst) {
    if (depth > 0) {
      PosState left = ps.getLeft();
      PosState none = ps.getNone();
      PosState right = ps.getRight();

      if (world.isValidLoc(left.pos)) {
        genPosStates(left, depth - 1, lst);
      }
      if (world.isValidLoc(none.pos)) {
        genPosStates(none, depth - 1, lst);
      }
      if (world.isValidLoc(right.pos)) {
        genPosStates(right, depth - 1, lst);
      }
    } else {
      if (world.isValidLoc(ps.pos)) {
        lst.add(ps);
      }
    }
  }

  class PosState {
    PVector pos, dir;

    PosState(PVector pos, PVector dir) {
      this.pos = pos;
      this.dir = dir;
    }

    PosState getLeft() {
      PVector dir = this.dir.copy();
      dir.rotate(-turn * PI / 180);
      PVector pos = PVector.add(this.pos, PVector.mult(dir, vel));
      return new PosState(pos, dir);
    }

    PosState getNone() {
      PVector dir = this.dir.copy();
      PVector pos = PVector.add(this.pos, PVector.mult(dir, vel));
      return new PosState(pos, dir);
    }

    PosState getRight() {
      PVector dir = this.dir.copy();
      dir.rotate(turn * PI / 180);
      PVector pos = PVector.add(this.pos, PVector.mult(dir, vel));
      return new PosState(pos, dir);
    }
  }
}
