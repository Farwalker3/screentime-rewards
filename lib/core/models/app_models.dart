class AppUser {
  final String id;
  final String email;
  final String name;
  final String role; // 'parent' or 'child'
  final String? familyId;

  AppUser({
    required this.id, 
    required this.email, 
    required this.name, 
    required this.role,
    this.familyId,
  });

  bool get isParent => role == 'parent';
}

class FamilyMember {
  final String id;
  final String name;
  final double balance;
  final String avatarUrl; // Placeholder

  FamilyMember({
    required this.id, 
    required this.name, 
    required this.balance,
    this.avatarUrl = '',
  });
}

class Goal {
  final String id;
  final String title;
  final String assignedToId; // Child ID
  final int maxMinutes;
  final double rewardAmount;
  final bool isMet;
  final DateTime date;

  Goal({
    required this.id, 
    required this.title, 
    required this.assignedToId,
    required this.maxMinutes,
    required this.rewardAmount,
    this.isMet = false,
    required this.date,
  });
}
