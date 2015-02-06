abstract class World {

  public abstract World copy();
  
  public abstract void draw(Entropy canvas);
  
  public abstract void getInput();
  public abstract void updateObjs();
  public abstract World simulate(Actor[] actors, Action[] actions);
  public abstract Action[] posActions();
  
  public abstract boolean isEquivalent(World world);
}

class StickWorld extends World {
  PVector stickTopLoc;
  PVector stickBotLoc;
  PVector stickTopVel;
  PVector stickBotVel;
  float g;
  float moveAcc;
  float stickLength;
  float friction;

  Actor platformActor;
  Action newAction = new Action("NONE");
  
  Action[] posActions = new Action[] {
    new Action("LEFT"),
    new Action("RIGHT"),
    new Action("NONE")
  };

  public StickWorld(PVector top, PVector bot, PVector topVel, PVector botVel, float g, float moveAcc, float friction) {
    this.stickTopLoc = top;
    this.stickBotLoc = bot;
    this.stickTopVel = topVel;
    this.stickBotVel = botVel;
    this.g = g;
    this.moveAcc = moveAcc;
    this.platformActor = new Actor(this);
    this.stickLength = top.dist(bot);
    this.friction = friction;
  }

  public World copy() {
    StickWorld world = new StickWorld(this.stickTopLoc.copy(), this.stickBotLoc.copy(), this.stickTopVel.copy(), this.stickBotVel.copy(), this.g, this.moveAcc, this.friction);
    world.platformActor = this.platformActor.copy();
    return world;
  }

  public void draw(Entropy canvas) {
    background(255);
    
    canvas.line(this.stickTopLoc.x, height-this.stickTopLoc.y, this.stickBotLoc.x, height-this.stickBotLoc.y);
    canvas.fill(128);
    canvas.ellipse(this.stickTopLoc.x, height-this.stickTopLoc.y, 20, 20);
    canvas.rect(this.stickBotLoc.x-20, height-this.stickBotLoc.y, 40, 10);
    canvas.fill(0);
    if (this.newAction.equals(new Action("LEFT"))) {
      canvas.rect(this.stickBotLoc.x-20, height-this.stickBotLoc.y, 20, 10);
    }
    else if (this.newAction.equals(new Action("RIGHT"))) {
      canvas.rect(this.stickBotLoc.x, height-this.stickBotLoc.y, 20, 10);
    }
    canvas.text("g: " + this.g + "\nactor acceleration: " + moveAcc + "\nstick length: " + this.stickLength + "\nfriction: " + this.friction,10,10);
  }

  public void getInput() {
    this.newAction = this.platformActor.act(this, posActions);
  }

  // Do basic inverted pendulum "physics"
  public void updateObjs() {
    double theta = atan2(this.stickTopLoc.y-this.stickBotLoc.y, this.stickTopLoc.x-this.stickBotLoc.x);

    float acc = this.moveAcc*(this.newAction.equals(new Action("RIGHT"))?1:-1);
    if (this.newAction.equals(new Action("NONE"))){
      acc = 0;
    }
    PVector accTop = new PVector(this.g*cos((float)theta), this.g*sin((float)theta)-this.g);
    PVector accBot = new PVector(acc, 0);

    this.stickTopVel.mult(1-this.friction);
    this.stickBotVel.mult(1-this.friction);
    this.stickTopVel.add(accTop);
    this.stickBotVel.add(accBot);


    if (this.stickTopLoc.y <= this.stickBotLoc.y) {
      this.stickTopLoc.y = this.stickBotLoc.y;
    } else {
      this.stickTopLoc.add(this.stickTopVel);
      this.stickBotLoc.add(this.stickBotVel);
    }
    theta = atan2(this.stickTopLoc.y-this.stickBotLoc.y, this.stickTopLoc.x-this.stickBotLoc.x);
    this.stickTopLoc = PVector.add(this.stickBotLoc,new PVector(this.stickLength*cos((float)theta), this.stickLength*sin((float)theta)));
  }

  public World simulate(Actor[] actors, Action[] actions) {
    StickWorld copy = (StickWorld)this.copy();
    if (actions.length > 0) {
      copy.newAction = actions[0];
    }
    copy.updateObjs();
    return copy;
  }
  public Action[] posActions(){
    return this.posActions;
  }

  public boolean isEquivalent(World world) {
    return PVector.sub(this.stickTopLoc, this.stickBotLoc).equals(PVector.sub(((StickWorld)world).stickTopLoc, ((StickWorld)world).stickBotLoc));
  }
}

class CheckersWorld extends World {
  char[][] board;
  boolean isWhiteTurn = true;
  Action newAction = new Action("NONE");
  boolean justAte = false; // Intended for double jumps, not currently implemented
  int[] pieceJustAte = {-1,-1};
  int turnCount = 0;
  
  public CheckersWorld(){
    this.board = newBoard();
  }
  
  public char[][] newBoard(){
    String initBoardData = " b b b b"+
                           "b b b b "+
                           " b b b b"+
                           "        "+
                           "        "+
                           "w w w w "+
                           " w w w w"+
                           "w w w w ";
    char[][] board = new char[8][8];
    for (int i = 0; i < initBoardData.length(); i++){
      board[i/8][i%8] = initBoardData.charAt(i);
    }
    
    return board;
  }
  
  public World copy(){
    CheckersWorld copy = new CheckersWorld();
    for (int i = 0; i < this.board.length; i++){
      for (int j = 0; j < this.board[0].length; j++){
        copy.board[i][j] = this.board[i][j];
      }
    }
    copy.isWhiteTurn = this.isWhiteTurn;
    copy.justAte = this.justAte;
    copy.pieceJustAte = this.pieceJustAte;
    copy.turnCount = this.turnCount; // Used by AI for making deterministic, but seemingly random moves
    return copy;
  }
  
  public void draw(Entropy canvas){
    canvas.background(128);
    float rectSize = 50;
    for (int i = 0; i < this.board.length; i++){
      for (int j = 0; j < this.board[0].length; j++){
        boolean isWhiteSquare = (i+j)%2==0;
        if (isWhiteSquare){
          fill(255);
        }
        else {
          fill(0);
        }
        canvas.rect(j*rectSize,i*rectSize,rectSize,rectSize);
        
        if (!isWhiteSquare){
          fill(255);
        }
        else {
          fill(0);
        }
        canvas.textSize(40);
        canvas.text(Character.toString(board[i][j]),j*rectSize+10,(i+1)*rectSize-10);
      }
    }
    fill(0);
    canvas.textSize(20);
    canvas.text((this.isWhiteTurn?"white":"black") + "'s turn",410,100,90,200);
  }
  
  public void getInput(){
    if (this.isWhiteTurn){
      ArrayList<Action> posActionsList = this.getPosActions();
      Action[] posActions = posActionsList.toArray(new Action[posActionsList.size()]);
      this.newAction = new Actor(this).act(this, posActions);
    }
    else{
      // Nothing to do
    }
  }
  
  public ArrayList<Action> getPosActions(){
    ArrayList<Action> posMoves = new ArrayList<Action>();
    for (int i = 0; i < this.board.length; i++){
      for (int j = 0; j < this.board[0].length; j++){
        if (!this.isEmpty(i,j) && (this.isWhiteTurn == this.isWhite(i,j))){
          int dI = this.isWhiteTurn?-1:1;
          
          // up left
          this.addMoveIfValid(posMoves,i,j,i+dI,j-1);
                   
          // up right
          this.addMoveIfValid(posMoves,i,j,i+dI,j+1);
          
          // eat up left          
          this.addMoveIfValid(posMoves,i,j,i+2*dI,j-2);
          
          // eat up right
          this.addMoveIfValid(posMoves,i,j,i+2*dI,j+2);
          
          // Kings moving backwards
          if (this.isKing(i,j)){
            // down left
            this.addMoveIfValid(posMoves,i,j,i-dI,j-1);
            
            // down right
            this.addMoveIfValid(posMoves,i,j,i-dI,j+1);
            
            // eat down left          
            this.addMoveIfValid(posMoves,i,j,i-2*dI,j-2);
            
            // eat down right
            this.addMoveIfValid(posMoves,i,j,i-2*dI,j+2);
          }
        }
      }
    }
    
    return posMoves;
  }
  
  public boolean isValidSquare(int i, int j){
    return i >= 0 && i < this.board.length && j >= 0 && j < this.board[0].length;
  }
  
  public boolean isKing(int i, int j){
    char square = this.board[i][j];
    return square == 'W' || square == 'B';
  }
  
  public boolean isEmpty(int i, int j){
    char square = this.board[i][j];
    return square == ' ';
  }
  
  public boolean isWhite(int i, int j){
    char square = this.board[i][j];
    return square == 'w' || square == 'W';
  }
  
  public void addMoveIfValid(ArrayList<Action> posMoves, int i, int j, int i2, int j2){
    boolean isEat = abs(i-i2) > 1;
    if (!isEat && this.isValidSquare(i2,j2) && this.isEmpty(i2,j2)){
      posMoves.add(new Action(writeAction(new int[]{i,j,i2,j2})));
    }
    
    int mI = (i+i2)/2;
    int mJ = (j+j2)/2;
    if (isEat && this.isValidSquare(i2,j2) && this.isEmpty(i2,j2) && !this.isEmpty(mI,mJ) && (this.isWhite(i,j)!=this.isWhite(mI,mJ))){
      posMoves.add(new Action(writeAction(new int[]{i,j,i2,j2})));
    }    
  }
  
  // Encodes a possible movement into a string.
  public String writeAction(int[] in){
    // Input is an array of 4 integers, which denote source and destination squares
    return ""+in[0]+in[1]+in[2]+in[3];
  }
  public int[] readAction(String str){
    int[] out = new int[4];
    for (int i = 0; i < 4; i++){
      out[i] = (int)(str.charAt(i))-(int)'0';
    }
    return out;
  }
  
  public void updateObjs(){
    int[] move; // A move is represented by an array of 4 integers, or the source and destination squares
    if (this.isWhiteTurn && !this.newAction.equals(new Action("NONE"))){
      move = readAction(this.newAction.data);
      this.newAction = new Action("NONE");
    }
    else{
      // Insesrt computer AI here
      ArrayList<Action> posActions = this.getPosActions();
      if (posActions.size()==0){
        return;
      }
      
      // Black always captures a piece if possible, otherwise a seemingly random move
      int moveIndex = this.turnCount*this.turnCount % posActions.size();
      move = readAction(posActions.get(moveIndex).data);
      for (Action action : posActions){
        int[] posMove = readAction(action.data);
        if (abs(posMove[0]-posMove[2])==2){
          move = posMove;
        }
      }
      
      
    }
    // Movement
    if (abs(move[0]-move[2]) == 1){
      this.board[move[2]][move[3]] = this.board[move[0]][move[1]];
      this.board[move[0]][move[1]] = ' ';
    }
    // Capturing
    if (abs(move[0]-move[2]) == 2){
      this.board[move[2]][move[3]] = this.board[move[0]][move[1]];
      this.board[move[0]][move[1]] = ' ';
      this.board[(move[0]+move[2])/2][(move[1]+move[3])/2] = ' ';
    }
    // Being kinged
    if (!this.isKing(move[2],move[3]) && (move[2]==0 || move[2]==this.board.length-1)){
      this.board[move[2]][move[3]] += 'A' - 'a';
    }
    this.isWhiteTurn = !this.isWhiteTurn;
    this.turnCount++;
  }
  
  public World simulate(Actor[] actors, Action[] actions) {
    CheckersWorld copy = (CheckersWorld)this.copy();
    if (actions.length > 0) {
      copy.newAction = actions[0];
    }
    copy.updateObjs();
    return copy;
  }
  
  public Action[] posActions(){
    ArrayList<Action> actions = this.getPosActions();
    return actions.toArray(new Action[actions.size()]);
  }
  
  public boolean isEquivalent(World world){
    if (this.isWhiteTurn != ((CheckersWorld)world).isWhiteTurn){
      return false;
    }
    
    for (int i = 0; i < this.board.length; i++){
      for (int j = 0; j < this.board[0].length; j++){
        if (this.board[i][j] != ((CheckersWorld)world).board[i][j]){
          return false;
        }
      }
    }
    return true;
  }
}
