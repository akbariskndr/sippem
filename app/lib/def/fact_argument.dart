import 'fact.dart';

class FactArgument {
  final List<Fact> facts;

  FactArgument(this.facts);

  Map toJson() {
    return {
      "facts": facts.map((item) => item.toJson()).toList(),
    };
  }
}