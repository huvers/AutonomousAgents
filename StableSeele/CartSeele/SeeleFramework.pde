
/*
 * Alternative 
 */

abstract class World {
  abstract World update();
  
  abstract void addActor(Actor actor);
  abstract Actor currActor();
  abstract List<String> currValidActions();
  abstract World transform(String action);
  
  void draw(PGraphics pg) { draw(pg, 0); }
  abstract void draw(PGraphics pg, int mode);
  
  abstract World cpy();
}





abstract class Actor {
  final List<Motive> motives = new ArrayList<Motive>();
  
  Actor() {}
  Actor(Motive... motives) { for(int i = 0; i < motives.length; i++) { this.motives.add(motives[i]); } }
  
  String getAction(World world) {
    if (motives.isEmpty()) { return null; }
    
    Map<String, Float> votes = new HashMap<String, Float>();
    
    String maxAction = null;
    Float maxWeight = Float.MIN_VALUE;
    
    for (Motive motive : motives) {
      String a = motive.getVote(world);
      float w = (votes.containsKey(a) ? votes.get(a) + motive.getWeight() : motive.getWeight());
      votes.put(a, w);
      
      if (w > maxWeight) { maxAction = a; maxWeight = w; }
    }
    return maxAction;
  }
  
  private Actor(Actor actor) { for (Motive motive : actor.motives) { this.motives.add(motive.cpy()); } }
  abstract Actor cpy();
}




abstract class Motive {
  float weight = 1;
  void setWeight(float w) { weight = w; }
  float getWeight() { return weight; }
  
  abstract String getVote(World world);
  
  abstract Motive cpy();
}
