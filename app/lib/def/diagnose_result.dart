class DiagnoseResult {
  String diseaseResult;
  String diseaseProb;
  List<String> otherDiseases;
  List<String> otherDiseasesProb;

  DiagnoseResult({this.diseaseResult, this.diseaseProb, this.otherDiseases, this.otherDiseasesProb});

  factory DiagnoseResult.fromJson(Map<String, dynamic> json) {
    List<String> _otherDiseases = List<String>.from(json['otherDiseases']);
    List<String> _otherDiseasesProb = List<String>.from(json['otherDiseasesProb']);
    return DiagnoseResult(
      diseaseResult: json['diseaseResult'],
      diseaseProb: json['diseaseProb'],
      otherDiseases: _otherDiseases,
      otherDiseasesProb: _otherDiseasesProb,
    );
  }
}