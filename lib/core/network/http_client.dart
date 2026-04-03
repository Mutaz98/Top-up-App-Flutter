abstract class HttpClient {
  Future<Map<String, dynamic>> get(String endpoint);
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  });
}
