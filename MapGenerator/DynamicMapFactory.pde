// Class that generates moving maps, which are defined with multiple frames
public abstract class DynamicMapFactory extends MapFactory {
  public DynamicMapFactory(int width, int height, color wallColor, color emptyColor) {
    super(width, height, wallColor, emptyColor, color(-1,-1,-1));
  }
}

// Generates a map that moves a line around a circle, like a lighthouse
public class LighthouseMapFactory extends DynamicMapFactory {
  int lineWidth; // Determines how wide the line is
  int framesPerLoop; // Determines the length of time for the light to make one revolution
  float theta = 0; // Current angle the line is drawn at
  public LighthouseMapFactory(int width, int height, color wallColor, color emptyColor, int lineWidth, int framesPerLoop) {
    super(width, height, wallColor, emptyColor);
    this.lineWidth = lineWidth;
    this.framesPerLoop = framesPerLoop;
  }

  public PImage generateMap() {
    PGraphics graphics = createGraphics(width, height);

    // Draw the background
    graphics.beginDraw();
    graphics.background(emptyColor);
    
    // Draw lines between each point and connect them
    graphics.noFill();
    graphics.strokeJoin(ROUND);
    graphics.strokeWeight(lineWidth);
    graphics.stroke(wallColor);
    
    // Draw the line
    float d = max(width, height);
    PVector center = new PVector(width/2, height/2);
    graphics.line(center.x, center.y, center.x + d*cos(theta), center.y + d*sin(theta));
    
    graphics.endDraw();
    
    // Update theta so the next time a map is generated, the map shifts slightly
    theta += 2*PI/framesPerLoop;

    return graphics.get();
  }
}
