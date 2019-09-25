class Fact {
  final int id;
  final String question;
  bool answer = false;

  Fact({this.id, this.question});

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(id: json['id'], question: json['pertanyaan']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer': answer,
    };
  }
}