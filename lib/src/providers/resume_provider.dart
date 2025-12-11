import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/resume_model.dart';

final resumeProvider =
FutureProvider.family<ResumeModel, String>((ref, name) async {
  final cleanName = Uri.encodeComponent(name.isEmpty ? "demo" : name);
  final url =
      "https://expressjs-api-resume-random.onrender.com/resume?name=$cleanName";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception("Error fetching resume: ${response.statusCode}");
  }

  final data = jsonDecode(response.body);

  if (data is List && data.isNotEmpty) {
    return ResumeModel.fromJson(
      Map<String, dynamic>.from(data[0]),
    );
  }

  if (data is Map) {
    final parsed = ResumeModel.fromJson(Map<String, dynamic>.from(data));

  // If API does not include name → use entered name
    if (parsed.name == "Unknown") {
      return ResumeModel(
        name: name,
        skills: parsed.skills,
        projects: parsed.projects,
      );
    }

    return parsed;

  }

  return ResumeModel(
    name: cleanName,
    skills: [],
    projects: [],
  );
});
