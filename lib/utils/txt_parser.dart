class BirdInfo {
  final String bname; // Nom bambara
  final String fname; // Nom français
  final String desc;  // Description avec formatage

  BirdInfo({
    required this.bname,
    required this.fname,
    required this.desc,
  });

  factory BirdInfo.fromTxtContent(String content) {
    // Extraire les balises
    final bnameMatch = RegExp(r'<bname>(.*?)</bname>', caseSensitive: false)
        .firstMatch(content);
    final fnameMatch = RegExp(r'<fname>(.*?)</fname>', caseSensitive: false)
        .firstMatch(content);
    final descMatch = RegExp(r'<desc>(.*?)</desc>', caseSensitive: false)
        .firstMatch(content);

    String bname = bnameMatch?.group(1)?.trim() ?? '';
    String fname = fnameMatch?.group(1)?.trim() ?? '';
    String desc = descMatch?.group(1)?.trim() ?? '';

    // Formater la description
    desc = _formatDescription(desc);

    return BirdInfo(
      bname: bname,
      fname: fname,
      desc: desc,
    );
  }

  static String _formatDescription(String desc) {
    // Remplacer <p> par deux sauts de ligne
    desc = desc.replaceAll('<p>', '\n\n');
    // Remplacer <br> par un saut de ligne
    desc = desc.replaceAll('<br>', '\n');
    // Nettoyer les espaces multiples
    desc = desc.replaceAll(RegExp(r'\s+'), ' ');
    // Supprimer les espaces au début et à la fin des lignes
    desc = desc.split('\n').map((line) => line.trim()).join('\n');
    return desc;
  }

  Map<String, dynamic> toJson() {
    return {
      'bname': bname,
      'fname': fname,
      'desc': desc,
    };
  }
}