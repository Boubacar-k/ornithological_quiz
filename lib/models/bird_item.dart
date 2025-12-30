class BirdItem {
  final String key; // clé unique comme "ceryle-rudis"
  final String bname; // nom bambara
  final String fname; // nom français
  final String desc; // description
  final List<String> imagePaths; // chemins des images
  final String scientificName; // nom scientifique (déduit de la clé)

  BirdItem({
    required this.key,
    required this.bname,
    required this.fname,
    required this.desc,
    required this.imagePaths,
  }) : scientificName = key.replaceAll('-', ' ');

  factory BirdItem.fromTxt(String content, String key) {
    // Parse le contenu comme dans le Python
    final bnameMatch = RegExp(r'<bname>(.*?)</bname>').firstMatch(content);
    final fnameMatch = RegExp(r'<fname>(.*?)</fname>').firstMatch(content);
    final descMatch = RegExp(r'<desc>(.*?)</desc>').firstMatch(content);

    String desc = descMatch?.group(1) ?? '';
    desc = desc.replaceAll('<p>', '\n\n').replaceAll('<br>', '\n');

    return BirdItem(
      key: key,
      bname: bnameMatch?.group(1) ?? '',
      fname: fnameMatch?.group(1) ?? '',
      desc: desc,
      imagePaths: [],
    );
  }
}