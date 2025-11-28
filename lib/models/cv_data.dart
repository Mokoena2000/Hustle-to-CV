class CVData {
  final List<String> experiences;
  final String preferredLanguage;
  String professionalSummary;
  List<String> skills;
  List<WorkExperience> workExperience;
  PersonalInfo personalInfo;

  CVData({
    required this.experiences,
    required this.preferredLanguage,
    this.professionalSummary = '',
    this.skills = const [],
    this.workExperience = const [],
    this.personalInfo = const PersonalInfo(),
  });
}

class WorkExperience {
  final String title;
  final String company;
  final String description;

  const WorkExperience({
    required this.title,
    required this.company,
    required this.description,
  });
}

class PersonalInfo {
  final String fullName;
  final String email;
  final String phone;
  final String location;

  const PersonalInfo({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
  });
}