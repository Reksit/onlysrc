class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? department;
  final String? className;
  final String? phoneNumber;
  final bool? verified;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.className,
    this.phoneNumber,
    this.verified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      department: json['department'],
      className: json['className'],
      phoneNumber: json['phoneNumber'],
      verified: json['verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'department': department,
      'className': className,
      'phoneNumber': phoneNumber,
      'verified': verified,
    };
  }
}

class Assessment {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final int totalMarks;
  final List<Question> questions;
  final List<String> assignedTo;

  Assessment({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalMarks,
    required this.questions,
    required this.assignedTo,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: json['duration'] ?? 0,
      totalMarks: json['totalMarks'] ?? 0,
      questions: (json['questions'] as List?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
      assignedTo: List<String>.from(json['assignedTo'] ?? []),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String location;
  final String type;
  final String organizer;
  final String organizerName;
  final int? maxAttendees;
  final List<String> attendees;
  final bool isVirtual;
  final String? meetingLink;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    this.endDateTime,
    required this.location,
    required this.type,
    required this.organizer,
    required this.organizerName,
    this.maxAttendees,
    required this.attendees,
    required this.isVirtual,
    this.meetingLink,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: json['endDateTime'] != null ? DateTime.parse(json['endDateTime']) : null,
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      organizer: json['organizer'] ?? '',
      organizerName: json['organizerName'] ?? '',
      maxAttendees: json['maxAttendees'],
      attendees: List<String>.from(json['attendees'] ?? []),
      isVirtual: json['isVirtual'] ?? false,
      meetingLink: json['meetingLink'],
    );
  }
}

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type;
  final String? salary;
  final String description;
  final List<String> requirements;
  final String postedBy;
  final String postedByName;
  final String postedByEmail;
  final DateTime postedAt;
  final String? applicationUrl;
  final String? contactEmail;
  final String status;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    this.salary,
    required this.description,
    required this.requirements,
    required this.postedBy,
    required this.postedByName,
    required this.postedByEmail,
    required this.postedAt,
    this.applicationUrl,
    this.contactEmail,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      salary: json['salary'],
      description: json['description'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      postedBy: json['postedBy'] ?? '',
      postedByName: json['postedByName'] ?? '',
      postedByEmail: json['postedByEmail'] ?? '',
      postedAt: DateTime.parse(json['postedAt']),
      applicationUrl: json['applicationUrl'],
      contactEmail: json['contactEmail'],
      status: json['status'] ?? 'ACTIVE',
    );
  }
}

class AlumniProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String department;
  final String? graduationYear;
  final String? batch;
  final String? currentCompany;
  final String? currentPosition;
  final String? location;
  final String? bio;
  final List<String>? skills;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final bool? isAvailableForMentorship;

  AlumniProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.department,
    this.graduationYear,
    this.batch,
    this.currentCompany,
    this.currentPosition,
    this.location,
    this.bio,
    this.skills,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.isAvailableForMentorship,
  });

  factory AlumniProfile.fromJson(Map<String, dynamic> json) {
    return AlumniProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      department: json['department'] ?? '',
      graduationYear: json['graduationYear'],
      batch: json['batch'],
      currentCompany: json['currentCompany'] ?? json['placedCompany'],
      currentPosition: json['currentPosition'] ?? json['currentJob'],
      location: json['location'],
      bio: json['bio'] ?? json['aboutMe'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      linkedinUrl: json['linkedinUrl'],
      githubUrl: json['githubUrl'],
      portfolioUrl: json['portfolioUrl'],
      isAvailableForMentorship: json['isAvailableForMentorship'] ?? json['mentorshipAvailable'] ?? json['availableForMentorship'],
    );
  }
}

class Task {
  final String id;
  final String taskName;
  final String description;
  final DateTime dueDate;
  final String status;
  final List<String> roadmap;
  final bool roadmapGenerated;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.taskName,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.roadmap,
    required this.roadmapGenerated,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      taskName: json['taskName'] ?? '',
      description: json['description'] ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      status: json['status'] ?? 'PENDING',
      roadmap: List<String>.from(json['roadmap'] ?? []),
      roadmapGenerated: json['roadmapGenerated'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final DateTime timestamp;
  final bool read;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    required this.read,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'] ?? false,
    );
  }
}

class Circular {
  final String id;
  final String title;
  final String body;
  final String senderId;
  final String senderName;
  final String senderRole;
  final List<String> recipientTypes;
  final DateTime createdAt;
  final String status;
  final List<String> readBy;

  Circular({
    required this.id,
    required this.title,
    required this.body,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.recipientTypes,
    required this.createdAt,
    required this.status,
    required this.readBy,
  });

  factory Circular.fromJson(Map<String, dynamic> json) {
    return Circular(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderRole: json['senderRole'] ?? '',
      recipientTypes: List<String>.from(json['recipientTypes'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'ACTIVE',
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }
}