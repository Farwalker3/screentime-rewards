import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_models.dart';
import '../../core/services/screen_time_service.dart';
import '../auth/login_screen.dart';
import '../child/child_dashboard.dart';
import 'add_goal_sheet.dart';

class ParentDashboard extends StatefulWidget {
  final AppUser user;

  const ParentDashboard({super.key, required this.user});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final List<FamilyMember> _children = [
    FamilyMember(id: '1', name: 'Kid 1', balance: 3.0),
    FamilyMember(id: '2', name: 'Kid 2', balance: 5.5),
  ];

  final List<Goal> _goals = [];

  int _selectedTab = 0; // 0 = Overview, 1 = Goals, 2 = Children

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildOverviewTab(),
                _buildGoalsTab(),
                _buildChildrenTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: _openAddGoalSheet,
              backgroundColor: AppTheme.primaryPurple,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Goal',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Overview', 'Goals', 'Children'];
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active
                          ? AppTheme.primaryPurple
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? AppTheme.primaryPurple : AppTheme.textGrey,
                    fontWeight:
                        active ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Overview Tab ───────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    final totalEarned =
        _children.fold(0.0, (sum, c) => sum + c.balance);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingCard(),
          const SizedBox(height: 20),
          _buildStatRow([
            _StatData(
              label: 'Children',
              value: _children.length.toString(),
              icon: Icons.people_outline,
              color: Colors.purple,
            ),
            _StatData(
              label: 'Active Goals',
              value: _goals.where((g) => g.isActive).length.toString(),
              icon: Icons.track_changes,
              color: Colors.blue,
            ),
            _StatData(
              label: 'Total Earned',
              value: '\$${totalEarned.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
          ]),
          const SizedBox(height: 24),
          const Text(
            'Quick Access',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 12),
          ..._children.map((child) => _buildChildQuickCard(child)),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryPurple,
            child: Text(
              widget.user.name.isNotEmpty ? widget.user.name[0] : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textDark),
              ),
              const Text(
                'PARENT',
                style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(List<_StatData> stats) {
    return Row(
      children: stats
          .map((s) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(s.icon, color: s.color, size: 24),
                      const SizedBox(height: 8),
                      Text(
                        s.value,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark),
                      ),
                      Text(
                        s.label,
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textGrey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildChildQuickCard(FamilyMember child) {
    final childGoals =
        _goals.where((g) => g.assignedToId == child.id && g.isActive).toList();
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChildDashboard(
            user: AppUser(
                id: child.id, email: '', name: child.name, role: 'child'),
            goalMinutes: childGoals.isNotEmpty ? childGoals.first.maxMinutes : 120,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
              child: Text(
                child.name[0],
                style: const TextStyle(
                    color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textDark)),
                  Text(
                    '${childGoals.length} active goal${childGoals.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${child.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }

  // ─── Goals Tab ──────────────────────────────────────────────────────────────

  Widget _buildGoalsTab() {
    if (_goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No goals yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap + New Goal to create one',
              style: TextStyle(color: AppTheme.textGrey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _goals.length,
      itemBuilder: (ctx, i) => _buildGoalCard(_goals[i]),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.timer_outlined,
                color: AppTheme.primaryPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.assignedToName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textDark),
                ),
                Text(
                  '${goal.periodLabel} · under ${ScreenTimeService.formatMinutes(goal.maxMinutes)}',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+\$${goal.rewardAmount.toStringAsFixed(2)}',
              style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: goal.isActive,
            activeColor: AppTheme.primaryPurple,
            onChanged: (v) => setState(() => goal.isActive = v),
          ),
        ],
      ),
    );
  }

  // ─── Children Tab ───────────────────────────────────────────────────────────

  Widget _buildChildrenTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _children.length + 1,
      itemBuilder: (ctx, i) {
        if (i == _children.length) return _buildAddChildButton();
        return _buildChildDetailCard(_children[i]);
      },
    );
  }

  Widget _buildChildDetailCard(FamilyMember child) {
    final childGoals =
        _goals.where((g) => g.assignedToId == child.id).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
                child: Text(
                  child.name[0],
                  style: const TextStyle(
                      color: AppTheme.primaryPurple,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textDark)),
                    Text(
                      '${childGoals.length} goal${childGoals.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${child.balance.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successGreen),
              ),
            ],
          ),
          if (childGoals.isNotEmpty) ...[
            const Divider(height: 24),
            ...childGoals.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.circle,
                          size: 8,
                          color: g.isActive
                              ? AppTheme.successGreen
                              : Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${g.periodLabel} · under ${ScreenTimeService.formatMinutes(g.maxMinutes)}',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textDark),
                      ),
                      const Spacer(),
                      Text(
                        '+\$${g.rewardAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildAddChildButton() {
    return GestureDetector(
      onTap: _showAddChildDialog,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined,
                color: AppTheme.primaryPurple.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              'Add Child',
              style: TextStyle(
                  color: AppTheme.primaryPurple.withOpacity(0.7),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  void _openAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddGoalSheet(
        children: _children,
        onSave: (goal) => setState(() => _goals.add(goal)),
      ),
    );
  }

  void _showAddChildDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Child"),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Child's name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                setState(() => _children.add(FamilyMember(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name)));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatData(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
}
