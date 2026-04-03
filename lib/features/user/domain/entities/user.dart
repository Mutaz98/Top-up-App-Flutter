import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final double balance;
  final bool isVerified;
  final double monthlyTopUpTotal;

  const User({
    required this.id,
    required this.name,
    required this.balance,
    required this.isVerified,
    required this.monthlyTopUpTotal,
  });

  User copyWith({
    String? id,
    String? name,
    double? balance,
    bool? isVerified,
    double? monthlyTopUpTotal,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      isVerified: isVerified ?? this.isVerified,
      monthlyTopUpTotal: monthlyTopUpTotal ?? this.monthlyTopUpTotal,
    );
  }

  @override
  List<Object> get props => [id, name, balance, isVerified, monthlyTopUpTotal];
}
