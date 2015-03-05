
abstract class Motive implements Cloneable {
  double weight = 0;
  
  void setWeight(double w) {
    weight = w;
  }
  
  double getWeight() {
    return weight;
  }
  
  abstract Action getVote(World world);
  
  //abstract Object clone();
  Object clone() { return null; }
}
