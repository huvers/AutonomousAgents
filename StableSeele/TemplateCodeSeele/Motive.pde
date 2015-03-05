
abstract class Motive {
  double weight = 0;
  
  void setWeight(double w) {
    weight = w;
  }
  
  double getWeight() {
    return weight;
  }
  
  abstract Action getVote(World world);
}
