class ResumeModel {
  final String name;
  final List<String> skills;
  final List<String> projects;

  ResumeModel({
    required this.name,
    required this.skills,
    required this.projects,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    final basics = json["basics"] ?? {};

    List<String> skillsList = [];
    if (json["skills"] is List) {
      skillsList = (json["skills"] as List).map((e) => e.toString()).toList();
    }

    List<String> projectList = [];
    if (json['projects'] is List) {
      projectList = (json['projects'] as List).map((item) {
        if (item is Map) {
          final title = item['title'] ?? 'Untitled Project';
          final desc = item['description'] ?? '';
          final start = item['startDate'] ?? '';
          final end = item['endDate'] ?? '';

          return "$title\n  - $desc\n  - Start: $start\n  - End: $end";
        }
        return item.toString();
      }).toList();
    }


    return ResumeModel(
      name: basics["name"]?.toString() ?? "Unknown",
      skills: skillsList,
      projects: projectList,
    );
  }

  String toReadableText() {
    final sb = StringBuffer();

    sb.writeln("Name: $name\n");

    sb.writeln("SKILLS:");
    if (skills.isEmpty) sb.writeln("- None");
    for (final s in skills) {
      sb.writeln("• $s");
    }

    sb.writeln("\nPROJECTS:");
    if (projects.isEmpty) sb.writeln("- None");

    for (final p in projects) {
      sb.writeln("\n• $p\n");
    }

    return sb.toString();
  }

}
