abstract class Service {
  void registerMethod(String method, Function callback);
  Future sendRequest(String method, parameters);
}
