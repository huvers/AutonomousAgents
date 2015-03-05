
abstract class Motive implements Cloneable {
  double weight = 1;
  
  void setWeight(double w) {
    weight = w;
  }
  
  double getWeight() {
    return weight;
  }
  
  abstract Action getVote(World world);
  
  public abstract Object clone();
  // Object clone() { return null; }
}
