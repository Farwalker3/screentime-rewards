import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_models.dart';
import '../auth/login_screen.dart';
import '../child/child_dashboard.dart';

class ParentDashboard extends StatefulWidget {
  final AppUser user;

  const ParentDashboard({super.key, required this.user});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  // Mock Data
  final List<FamilyMember> _members = [
    FamilyMember(id: '1', name: 'Kid 1', balance: 3.0),
    FamilyMember(id: '2', name: 'Kid 2', balance: 5.5),
  ];

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
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6), // Light Purple
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                   CircleAvatar(
                    backgroundColor: AppTheme.primaryPurple,
                    child: Text(widget.user.name.isNotEmpty ? widget.user.name[0] : '?', style: const TextStyle(color: Colors.white)),
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
                           color: AppTheme.textDark
                         ),
                       ),
                       Text(
                         widget.user.role.toUpperCase(),
                         style: const TextStyle(
                           color: AppTheme.primaryPurple,
                           fontSize: 12,
                           fontWeight: FontWeight.w600
                         ),
                       ),
                     ],
                   )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Family\nAllowance',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F36), // Dark Blue-Black
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage screen time goals\nand track earnings',
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    backgroundColor: AppTheme.primaryPurple,
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 32),

            // Stat Cards
            _buildStatCard(
              title: 'Family Members',
              value: _members.length.toString(),
              icon: Icons.people_outline,
              color: Colors.purple.shade50,
              iconColor: Colors.purple,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChildDashboard(
                      user: AppUser(
                        id: 'child1', 
                        email: '', 
                        name: 'Kid 1', 
                        role: 'child'
                      ),
                    ),
                  ),
                );
              },
              child: _buildStatCard(
                title: 'Active Goals (Tap to View Child UI)',
                value: '3', // Mock
                icon: Icons.track_changes,
                color: Colors.blue.shade50,
                iconColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Total Earned',
              value: '\$${_members.fold(0.0, (sum, m) => sum + m.balance).toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.green.shade50,
              iconColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
        ],
      ),
    );
  }
}
