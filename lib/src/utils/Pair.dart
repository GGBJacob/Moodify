
class Pair<T1, T2> {
  T1 first;
  T2 second;

  Pair(this.first, this.second);

  T1 getFirst() => first;

  T2 getSecond() => second;

  void setFirst(T1 value) {
    first = value;
  }

  void setSecond(T2 value) {
    second = value;
  }
  
  @override
  String toString() => 'Pair($first, $second)';
}