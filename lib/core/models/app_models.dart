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
  double balance;
  final String avatarUrl;

  FamilyMember({
    required this.id,
    required this.name,
    this.balance = 0.0,
    this.avatarUrl = '',
  });
}

enum GoalPeriod { daily, weekly, monthly }

class Goal {
  final String id;
  final String assignedToId; // Child ID
  final String assignedToName;
  final int maxMinutes; // Screen time limit
  final double rewardAmount;
  final GoalPeriod period;
  // For daily goals: which days apply (1=Mon … 7=Sun). Empty = every day.
  final List<int> activeDays;
  final DateTime createdAt;
  bool isActive;

  Goal({
    required this.id,
    required this.assignedToId,
    required this.assignedToName,
    required this.maxMinutes,
    required this.rewardAmount,
    required this.period,
    this.activeDays = const [],
    required this.createdAt,
    this.isActive = true,
  });

  String get periodLabel {
    switch (period) {
      case GoalPeriod.daily:
        return 'Daily';
      case GoalPeriod.weekly:
        return 'Weekly';
      case GoalPeriod.monthly:
        return 'Monthly';
    }
  }

  bool appliesToday() {
    if (!isActive) return false;
    if (activeDays.isEmpty) return true;
    return activeDays.contains(DateTime.now().weekday);
  }
}

class GoalResult {
  final String id;
  final String goalId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int actualMinutes;
  final bool met;
  final double rewardEarned;

  GoalResult({
    required this.id,
    required this.goalId,
    required this.periodStart,
    required this.periodEnd,
    required this.actualMinutes,
    required this.met,
    required this.rewardEarned,
  });
}
