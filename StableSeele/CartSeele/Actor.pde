import java.util.Map.Entry;

class Actor {
  final Map<String, Motive> motives = new HashMap<String, Motive>();
  
  Actor() {}
  Actor(Actor actor) {
    for (Entry<String, Motive> entry : actor.motives.entrySet()) {
      this.motives.put(entry.getKey(), (Motive)entry.getValue().clone());
    }
  }
  
  void addMotive(String name, Motive motive) {
    motives.put(name, motive);
  }
  
  void rmMotive(String name) {
    motives.remove(name);
  }
  
  Action getAction(World world) {
    if (motives.isEmpty()) return null;
    
    Map<Action, Double> votes = new HashMap<Action, Double>();
    
    Action maxAction = null;
    double maxWeight = Double.MIN_VALUE;
    
    for (Entry<String, Motive> entry : motives.entrySet()) {
      Motive m = entry.getValue();
      Action a = m.getVote(world);
      double w;
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
  
  Actor clone() {
    return new Actor(this);
  }
}
