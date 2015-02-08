// Class that generates maps
public abstract class MapFactory {
  int width;
  int height;
  color defaultColor;
  color emptyColor;
  color spawnColor;
  public MapFactory(int width, int height, color defaultColor, color emptyColor, color spawnColor) {
    this.width = width;  
    this.height = height;
    this.defaultColor = defaultColor;
    this.emptyColor = emptyColor;
    this.spawnColor = spawnColor;
  }

  public abstract PImage generateMap();
}

// Generates noise
public class RandomMapFactory extends MapFactory {
  int blockSize; // Determines the "resolution" of the map by defining the size of the n by n squares on the map
  float density; // Determines the probability of a particular area being filled with a color
  public RandomMapFactory(int width, int height, color defaultColor, color emptyColor, color spawnColor, int blockSize, float density) {
    super(width, height, defaultColor, emptyColor, spawnColor);
    this.blockSize = blockSize;
    this.density = density;
  }

  public PImage generateMap() {
    PImage img = createImage(width, height, RGB);
    img.loadPixels();
    
    boolean addedSpawnPoint = false;

    for (int y = 0; y < height; y+=blockSize) {
      for (int x = 0; x < width; x+=blockSize) {
        if (x == 0 || x >= width-blockSize || y == 0 || y >= height-blockSize || random(1) < density) {
          // Create borders and generate random squares
          for (int blockY = 0; blockY < blockSize; blockY++) {
            for (int blockX = 0; blockX < blockSize; blockX++) {
              img.pixels[(y+blockY)*width + (x+blockX)] = defaultColor;
              if (!addedSpawnPoint){
                img.pixels[(y+blockY)*width + (x+blockX)] = spawnColor;
                addedSpawnPoint = true;
              }
            }
          }
        }
      }
    }

    img.updatePixels();
    return img;
  }
}

// Generates an elliptical map with twists and turns
public class LoopMapFactory extends MapFactory {
  float loopWidth; // Determines the width of the loop
  float loopDeviation; // Determines how large the twists and turns of the loop are
  float loopWindedness; // Determines the number of twists and turns
  int borderSize; // Determines how much buffer space there is on the edge of the image
  public LoopMapFactory(int width, int height, color defaultColor, color emptyColor, color spawnColor, float loopWidth, float loopDeviation, float loopWindedness, int borderSize) {
    super(width, height, defaultColor, emptyColor, spawnColor);
    this.loopWidth = loopWidth;
    this.loopDeviation = loopDeviation;
    this.loopWindedness = loopWindedness;
    this.borderSize = borderSize;
  }

  public PImage generateMap() {
    PGraphics graphics = createGraphics(width, height);

    // The loop is represented by a number of points.
    ArrayList<PVector> loopPoints = new ArrayList<PVector>();

    float a = width/2 - loopDeviation - loopWidth - borderSize; // a is half the ellipse
    float b = height/2 - loopDeviation - loopWidth - borderSize; // b is half the ellipse height
    
    // Create random points near the ellipse with theta at random intervals
    float theta = 0;
    while (theta < 2*PI) {
      float x = (a + (random(2)-1)*loopDeviation)*cos(theta) + width/2;
      float y = (b + (random(2)-1)*loopDeviation)*sin(theta) + height/2;
      PVector point = new PVector(x, y);
      loopPoints.add(point);
      theta += (0.5 + random(1)) * (2*PI/loopWindedness);
    }

    // Draw the background
    graphics.beginDraw();
    graphics.background(defaultColor);
    
    // Only draw one spawn point
    boolean addedSpawnPoint = false;
    PVector spawnPoint = null;
    
    // Draw lines between each point and connect them
    graphics.noFill();
    graphics.strokeJoin(ROUND);
    graphics.strokeWeight(loopWidth);
    graphics.beginShape();
    for (int i = 0; i < loopPoints.size(); i++) {
      PVector point = loopPoints.get(i);
      graphics.stroke(emptyColor);
      graphics.vertex(point.x, point.y);
      if (!addedSpawnPoint){
        spawnPoint = point;
        addedSpawnPoint = true;
      }
    }
    if (!loopPoints.isEmpty()){
      graphics.vertex(loopPoints.get(0).x, loopPoints.get(0).y);
    }
    graphics.endShape();
    
    graphics.strokeWeight(1);
    graphics.stroke(spawnColor);
    graphics.point(spawnPoint.x, spawnPoint.y);
    
    graphics.endDraw();

    return graphics.get();
  }
}

// Generates a maze row by row using the Eller algorithm
public class MazeMapFactory extends MapFactory {
  int blockSize; // Determines the "resolution" of the map by defining the size of the n by n squares on the map
  float verticalBias; // Influences how many paths go up and down versus left and right. Ranges from 0 to 1.
  public MazeMapFactory(int width, int height, color defaultColor, color emptyColor, color spawnColor, int blockSize, float verticalBias) {
    super(width, height, defaultColor, emptyColor, spawnColor);
    this.blockSize = blockSize;
    this.verticalBias = verticalBias;
  }

  public PImage generateMap() {
    PGraphics graphics = createGraphics(width, height);

    // The grid that defines the maze
    boolean[][] grid = generateMazeEller(width/blockSize, height/blockSize, verticalBias);
    
    // Draw the background
    graphics.beginDraw();
    graphics.background(defaultColor);
    
    // Only one spawn point should be added
    boolean addedSpawnPoint = false;
    
    // Draw the maze
    graphics.fill(emptyColor);
    graphics.noStroke();
    for (int x = 0; x < grid.length; x++){
      for (int y = 0; y < grid[0].length; y++){
        if (!grid[x][y]){
          graphics.noStroke();
          graphics.rect(x*blockSize, y*blockSize, blockSize, blockSize);
          if (!addedSpawnPoint){
            graphics.stroke(spawnColor);
            graphics.point(x*blockSize+blockSize/2, x*blockSize + blockSize/2);
            addedSpawnPoint = true;
          }
        }
      }
    }
    
    graphics.endDraw();
    return graphics.get();
  }
  
  
  // Outputs a grid that will represent a maze
  boolean[][] generateMazeEller(int numCols, int numRows, float verticalModifier){    
    // Necessary for the Eller algorithm
    int numWallsX = (numCols-2)/2;
    int numWallsY = (numRows-2)/2;
    int nextSetID = 0; // Used to get unique ID's for sets
    int[] currSets = new int[numWallsX]; // List of sets of the current row by column
    boolean[][] rightWalls = new boolean[numWallsY][numWallsX-1]; // Is there a wall to the right at this row and column?
    boolean[][] bottomWalls = new boolean[numWallsY][numWallsX]; // Is there a wall below at this row and column?
    
    // Make the first row out of unique sets
    for (int i = 0; i < numWallsX; i++){
      currSets[i] = nextSetID;
      nextSetID++;
    }
    
    // Make rows until the maze is full
    int row = 0;
    while (true){
      // Make right walls
      for (int i = 0; i < numWallsX-1; i++){
        // Add right walls randomly
        if (currSets[i] == currSets[i+1] || random(1) < verticalModifier){
          // If they have the same set, we MUST add a wall
          rightWalls[row][i] = true;
        }
        else {  
          // Don't make a wall, so combine sets
          rightWalls[row][i] = false;
          // Combine sets
          int setID = currSets[i+1];
          for (int j = 0; j < numWallsX; j++){
            if (currSets[j] == setID){
              currSets[j] = currSets[i];
            }
          }
        }
      }
      
      // Make bottom walls
      for (int i = 0; i < numWallsX; i++){
        int numInSet = 0; // count the number of rooms with the same ID
        boolean hasBottomPassage = false; // Ensure that there is a passage downward per set
        for (int j = i; j < numWallsX; j++){
          if (currSets[j] == currSets[i]){
            numInSet++;
            
            // Add bottom walls randomly
            boolean addWall = random(1) > verticalModifier;
            bottomWalls[row][j] = addWall;
            
            if (!addWall){
              hasBottomPassage = true;
            }
          }
          else {
            break;
          }
        }
        
        //Add the mandatory bottom passage per set
        if (!hasBottomPassage){
          bottomWalls[row][i+(int)random(numInSet)] = false;
        }
        
        i += numInSet-1;
      }
      
      // This is where we decide if we want to stop making more rows.
      if (row == numWallsY-1){
        break;
      }
            
      // Fill in the room with unique ID's if it had a bottom wall above it
      for (int i = 0; i < numWallsX; i++){
        if (bottomWalls[row][i]){
          currSets[i] = nextSetID;
          nextSetID++;
        }
      }
      
      // We are now working on another row.
      row++;
    }
    
    // Completing the maze with the last row.
    for (int i = 0; i < numWallsX-1; i++){
      // Remove a wall in between if they're in a different set
      if (currSets[i] != currSets[i+1]){
        rightWalls[row][i] = false;
        // Combine sets
        int setID = currSets[i+1];
        for (int j = 0; j < numWallsX; j++){
          if (currSets[j] == setID){
            currSets[j] = currSets[i];
          }
        }
      }
      
      // All elements in the last row have a bottom wall.
      bottomWalls[row][i] = true;
    }
    // The element in the lower corner also has a bottom wall.
    bottomWalls[row][numWallsX-1] = true;
        
    return wallToBoolean(rightWalls, bottomWalls);
  }
  
  
  // Turns a maze made of "sticks" into a "block" maze
  boolean[][] wallToBoolean(boolean[][] rightWalls, boolean[][] bottomWalls){
    // Resizing, final size will be an odd number
    int numRows = 2*(bottomWalls.length)+1;
    int numCols = 2*(rightWalls[0].length+1)+1;
    boolean[][] grid = new boolean[numCols][numRows];
    for (int x = 0; x < numCols; x++){
      for (int y = 0; y < numRows; y++){
        // Borders are filled in
        if (x == 0 || y == 0 || x == numCols-1 || y == numRows-1){
          grid[x][y] = true;
        }
        // One box in every 4 squares are filled
        else if (x%2==0 && y%2==0){
          grid[x][y] = true;
        }
        else {
          grid[x][y] = false;
        }
      }
    }
    
    // Fill in the walls of the maze
    for (int i = 0; i < rightWalls.length; i++){
      for (int j = 0; j < rightWalls[0].length; j++){
        grid[2+2*j][1+2*i] = rightWalls[i][j];
      }
    }
    for (int i = 0; i < bottomWalls.length; i++){
      for (int j = 0; j < bottomWalls[0].length; j++){
        grid[1+2*j][2+2*i] = bottomWalls[i][j];
      }
    }
    
    return grid;
  }
  
  // Makes a string from one row of walls for output purposes
  String wallToString(boolean[] rightWalls, boolean[] bottomWalls){
    String rowString = "";
    rowString += "|";
    for (int i = 0; i < bottomWalls.length; i++){
      // Add bottom wall to string
      if (bottomWalls[i]){
        rowString += "_";
      }
      else {
        rowString += " ";
      }
      
      // Add right wall to string
      if (i < rightWalls.length && rightWalls[i]){
        rowString += "|";
      }
      else {
        rowString += " ";
      }
    }
    rowString += "|";
    return rowString;
  }
}
