class BirdData {
  final String key;
  final String bname;
  final String fname;
  final String desc;
  final List<String> originalImages;
  final List<String> resizedImages;
  final String scientificName;

  BirdData({
    required this.key,
    required this.bname,
    required this.fname,
    required this.desc,
    required this.originalImages,
    required this.resizedImages,
    required this.scientificName,
  });

  factory BirdData.fromJson(Map<String, dynamic> json) {
    return BirdData(
      key: json['key'],
      bname: json['bname'] ?? '',
      fname: json['fname'] ?? '',
      desc: json['desc'] ?? '',
      originalImages: List<String>.from(json['originalImages'] ?? []),
      resizedImages: List<String>.from(json['resizedImages'] ?? []),
      scientificName: json['scientificName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'bname': bname,
      'fname': fname,
      'desc': desc,
      'originalImages': originalImages,
      'resizedImages': resizedImages,
      'scientificName': scientificName,
    };
  }

  List<String> get displayImages => resizedImages.isNotEmpty
      ? resizedImages
      : originalImages;

  bool get hasMultipleImages => displayImages.length > 1;

  String getDisplayName({bool showBname = true, bool showLatin = false}) {
    String name = '';

    if (showBname && bname.isNotEmpty) {
      name = bname;
      if (fname.isNotEmpty) {
        name += '\n$fname';
      }
    } else if (fname.isNotEmpty) {
      name = fname;
    } else {
      name = scientificName;
    }

    if (showLatin) {
      name += '\n$scientificName';
    }

    return name;
  }

  String get simpleName {
    if (fname.isNotEmpty) return fname;
    if (bname.isNotEmpty) return bname;
    return scientificName;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BirdData && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}