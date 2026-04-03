class AppConstants {
  AppConstants._();

  // Beneficiary limits
  static const int maxBeneficiaries = 5;
  static const int maxNicknameLength = 20;

  // Top-up amounts (AED)
  static const List<double> topUpAmounts = [5, 10, 20, 30, 50, 75, 100];

  // Transaction fee (AED)
  static const double transactionFee = 3.0;

  // Monthly limits (AED)
  static const double unverifiedMonthlyLimitPerBeneficiary = 500.0;
  static const double verifiedMonthlyLimitPerBeneficiary = 1000.0;
  static const double totalMonthlyLimit = 3000.0;

  // Hive box names
  static const String userBoxName = 'userBox';
  static const String beneficiaryBoxName = 'beneficiaryBox';
  static const String pendingTopUpsBoxName = 'pendingTopUpsBox';

  // Hive type IDs
  static const int userHiveTypeId = 0;
  static const int beneficiaryHiveTypeId = 1;
  static const int pendingTopUpHiveTypeId = 2;
}
