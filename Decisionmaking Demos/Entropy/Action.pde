class Action{
  String data;
  public Action(String data){
    this.data = data;
  }
  public boolean equals(Object o){
    if (! (o instanceof Action)){
      return false;
    }
    return this.data == ((Action)o).data;
  }
  public String toString(){
    return this.data;
  }
}
