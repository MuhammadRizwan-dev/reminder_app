class Reminder {
  final int id;
  final String title;
  final String date;
  final String time;

  Reminder({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
  });
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      date: map['date'],
      time: map['time'] ?? "",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
    };
  }
}
