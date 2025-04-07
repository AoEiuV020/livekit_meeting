class MeetingException implements Exception {
  final String message;
  const MeetingException(this.message);
  @override
  String toString() => message;
}
