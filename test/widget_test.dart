import 'dart:math';

List<double> generateSuggestions(double amount) {
  double generateAmount(int amount) {
    Random random = Random();
    double result = (random.nextInt(max(1000, amount)) / 1000).round() * 1000.0;
    return result.clamp(1000.0, 2000000.0);
  }

  List<double> result = [];
  for (int i = 0; i < 10; i++) {
    double amount1 = generateAmount(amount.toInt() + 100000);
    double amount2 = generateAmount(amount.toInt() - 100000);
    result.addAll([amount1, amount2]);
  }
  result.sort();

  return Set.of(result).toList();
}

void main() {
  double amount = 0;
  List<double> suggestions = generateSuggestions(amount);

  print("Montant de la transaction : $amount");
  print("Suggestions de soldes : $suggestions");
}
