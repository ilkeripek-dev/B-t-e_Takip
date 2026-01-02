import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  bool isExpense;

  @HiveField(5) // <--- BU SATIR VAR MI?
  String category; // <--- BU SATIR VAR MI?

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
    required this.category, 
  }) : id = const Uuid().v4();
}