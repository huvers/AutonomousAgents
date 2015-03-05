
class Action {
  Map<String, Object> data = new HashMap<String, Object>();
  
  Object get(String key) {
    return data.get(key);
  }
  
  void set(String key, Object obj) {
    data.put(key, obj);
  }
  
  boolean equals(Object obj) {
    if ( !(obj instanceof Action) ) return false;
    Action othr = (Action) obj;
    return data.equals(othr.data);
  }
}
