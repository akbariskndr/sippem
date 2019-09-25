class Disease {
  final int id;
  final String nama;

  Disease(this.id, this.nama);

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(json['id'], json['nama']);
  }
}

class Symptom {
  final int id;
  final String nama;
  final String pertanyaan;
  bool checked = false;

  Symptom(this.id, this.nama, this.pertanyaan, {this.checked = false});

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(json['id'], json['nama'], json['pertanyaan']);
  }

  Map toJson() {
    return {
      'id': id,
      'nama': nama,
      'pertanyaan': pertanyaan,
    };
  }
}

class DiseaseDetail {
  final Disease disease;
  final List<Symptom> symptoms;

  DiseaseDetail(this.disease, this.symptoms);

  factory DiseaseDetail.fromJson(Map<String, dynamic> json) {
    final disease = Disease.fromJson(json);
    final List<Symptom> symptoms = json['gejala'].map<Symptom>(
      (item) => Symptom(item['id'], item['nama'], item['pertanyaan'], checked: item['checked'])
    ).toList();

    return DiseaseDetail(disease, symptoms);
  }
}


class DiseaseSymptomRequest {
  final int diseaseId;
  final String name;
  final List<int> symptomIds;

  DiseaseSymptomRequest(this.diseaseId, this.name, this.symptomIds);

  Map toJson() {
    return {
      'id': diseaseId,
      'nama': name,
      'gejala': symptomIds,
    };
  }
}