class Actor {
  World world;
  int simulationDepth = 100;
  int simulationBreadth = 100;

  public Actor(World world) {
    this.world = world;
  }

  public Actor copy() {
    return new Actor(this.world);
  }

  // Actor chooses an action that maximizes its freedom
  public Action act(World world, Action[] posActions) {
    if (posActions.length == 0){
      return new Action("NONE");
    }

    double[] freedoms = evaluateFreedoms(world, posActions, simulationDepth);
    double maxFreedom = 0;
    int maxFreedomIndex = 0;
    for (int i = 0; i < posActions.length; i++) {
      if (freedoms[i] > maxFreedom) {
        maxFreedom = freedoms[i];
        maxFreedomIndex = i;
      }
    }
    // Output for debugging
    // println("---");
    // for (int i = 0; i < freedoms.length; i++){
    //   println(posActions[i] + ": " + freedoms[i]);
    // }
    // println("---");
    return posActions[maxFreedomIndex];
  }

  // Method that defines freedoms based on a world and some possible actions.
  // The current algorithm is as follows:
  //   Simulate one immediate decision and continue simulating with random decisions
  //     At each decision, evaluate whether that decision influenced the world
  //       If so, increase the freedom score based on the depth of the simulation and the number of possibilities
  //   Do this a certain number of times for that one decision
  //   Do this a certain number of times for all the other decisions
  public double[] evaluateFreedoms(World world, Action[] posActions, int depth) {
    double[] freedoms = new double[posActions.length];
    for (int i = 0; i < posActions.length; i++) {
      World possibility = world.simulate(new Actor[]{this}, new Action[]{posActions[i]});
      for (int j = 0; j < simulationBreadth; j++) {
        World randomFuture = possibility.copy();
        for (int k = 0; k < simulationDepth; k++) {
          Action[] futurePosActions = randomFuture.posActions();
          if (futurePosActions.length == 0){
            break;
          }
          int randomIndex = (int)(futurePosActions.length*random(1));
          Action randomAction = futurePosActions[randomIndex];
          
          World noActionFuture = randomFuture.simulate(new Actor[]{}, new Action[]{});
          randomFuture = randomFuture.simulate(new Actor[]{this}, new Action[]{randomAction});
          if (!noActionFuture.isEquivalent(randomFuture)) {
            freedoms[i] += 1.0*k/(posActions.length*simulationDepth*simulationBreadth);
          }
        }
      }
    }
    return freedoms;
  }
}
