class DocumentModel {
  final String id;
  final String title;
  final String department;
  final String departmentCode;
  final String level;
  final String type; // EX, DS, CC, CO, TD
  final String professorName;
  final String professorInitials;
  final DateTime uploadDate;
  final int downloads;
  final String googleDriveFileId;
  final String? fileSize;
  final String? year;
  final String? semester;
  final bool isValidated;

  DocumentModel({
    required this.id,
    required this.title,
    required this.department,
    required this.departmentCode,
    required this.level,
    required this.type,
    required this.professorName,
    required this.professorInitials,
    required this.uploadDate,
    required this.downloads,
    required this.googleDriveFileId,
    this.fileSize,
    this.year,
    this.semester,
    this.isValidated = true,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return DocumentModel(
      id: documentId,
      title: data['title'] ?? '',
      department: data['department'] ?? '',
      departmentCode: data['departmentCode'] ?? '',
      level: data['level'] ?? '',
      type: data['type'] ?? '',
      professorName: data['professorName'] ?? '',
      professorInitials: data['professorInitials'] ?? '',
      uploadDate: data['uploadDate'] != null
          ? DateTime.parse(data['uploadDate'].toString())
          : DateTime.now(),
      downloads: data['downloads'] ?? 0,
      googleDriveFileId: data['google_drive_file_id'] ?? '',
      fileSize: data['fileSize'],
      year: data['year'],
      semester: data['semester'],
      isValidated: data['isValidated'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'department': department,
      'departmentCode': departmentCode,
      'level': level,
      'type': type,
      'professorName': professorName,
      'professorInitials': professorInitials,
      'uploadDate': uploadDate.toIso8601String(),
      'downloads': downloads,
      'google_drive_file_id': googleDriveFileId,
      'fileSize': fileSize,
      'year': year,
      'semester': semester,
      'isValidated': isValidated,
    };
  }

  /// Human-readable relative date string
  String get relativeDate {
    final diff = DateTime.now().difference(uploadDate);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'il y a ${diff.inDays}j';
    if (diff.inDays < 30) return 'il y a ${(diff.inDays / 7).floor()} sem';
    return 'il y a ${(diff.inDays / 30).floor()} mois';
  }
}
