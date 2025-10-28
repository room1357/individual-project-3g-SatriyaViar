import 'dart:convert';

class SharedExpense {
  final String title;
  final double amount;
  final String createdBy;
  final List<String> members;
  final DateTime date;

  SharedExpense({
    required this.title,
    required this.amount,
    required this.createdBy,
    required this.members,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'createdBy': createdBy,
    'members': members,
    'date': date.toIso8601String(),
  };

  factory SharedExpense.fromMap(Map<String, dynamic> map) => SharedExpense(
    title: map['title'],
    amount: (map['amount'] as num).toDouble(),
    createdBy: map['createdBy'],
    members: List<String>.from(map['members']),
    date: DateTime.parse(map['date']),
  );
}
