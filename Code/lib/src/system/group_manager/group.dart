class Group {
  ///1 Session is supposed to have 1 Group related to it.
  ///Find corresponding session by session ID
  ///
  /// List of pariticipants includes host as well
  /// (One who made it)
  String sessionID = '';
  List<String> participants = [];

  Group(this.sessionID);

  void addParticipant(String email) => participants.add(email);

  void removeParticipant(String email) => participants.remove(email);

  int getNumberOfParticipants() => participants.length;

  bool isEmpty() => participants.isEmpty;

  bool contains(String email) => participants.contains(email);
}
