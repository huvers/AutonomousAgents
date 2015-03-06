
/*
 * Alternative 
 */

abstract class World {
  abstract World update();
  
  abstract Actor currActor();
  abstract List<String> currValidActions();
  abstract World transform(String action);
  
  void draw(PGraphics pg) { draw(pg, 0); }
  abstract void draw(PGraphics pg, int mode);
  
  abstract World cpy();
}





class Actor {
  final Map<String, Motive> motives = new HashMap<String, Motive>();
  
  Actor() {}
  
  void addMotive(String name, Motive motive) { motives.put(name, motive); }
  void rmMotive(String name) { motives.remove(name); }
  
  String getAction(World world) {
    if (motives.isEmpty()) return null;
    
    Map<String, Float> votes = new HashMap<String, Float>();
    
    String maxAction = null;
    Float maxWeight = Float.MIN_VALUE;
    
    for (Entry<String, Motive> entry : motives.entrySet()) {
      Motive m = entry.getValue();
      String a = m.getVote(world);
      Float w;
      if (votes.containsKey(a)){
        w = votes.get(a) + m.getWeight();
      } else {
        w = m.getWeight();
      }
      votes.put(a, w);
      
      if (w > maxWeight) {
        maxAction = a;
        maxWeight = w;
      }
    }
    
    return maxAction;
  }
  
  private Actor(Actor actor) {
    for (Entry<String, Motive> entry : actor.motives.entrySet()) {
      this.motives.put(entry.getKey(), entry.getValue().cpy());
    }
  }
  Actor cpy() { return new Actor(this); }
}




abstract class Motive {
  float weight = 1;
  void setWeight(float w) { weight = w; }
  float getWeight() { return weight; }
  
  abstract String getVote(World world);
  
  abstract Motive cpy();
  // public abstract Object clone();
  // Object clone() { return null; }
}
