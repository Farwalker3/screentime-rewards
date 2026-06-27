import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_models.dart';

class AddGoalSheet extends StatefulWidget {
  final List<FamilyMember> children;
  final void Function(Goal goal) onSave;

  const AddGoalSheet({
    super.key,
    required this.children,
    required this.onSave,
  });

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  String? _selectedChildId;
  GoalPeriod _period = GoalPeriod.daily;
  double _rewardAmount = 1.00;
  int _limitHours = 2;
  int _limitMinutes = 0;
  // Which weekdays are active (1=Mon..7=Sun). Empty = every day.
  final Set<int> _activeDays = {};

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayValues = [1, 2, 3, 4, 5, 6, 7];

  int get _totalMinutes => _limitHours * 60 + _limitMinutes;

  @override
  void initState() {
    super.initState();
    if (widget.children.isNotEmpty) {
      _selectedChildId = widget.children.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              'New Goal',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 24),

            // Child selector
            if (widget.children.length > 1) ...[
              _sectionLabel('For'),
              const SizedBox(height: 8),
              _buildChildSelector(),
              const SizedBox(height: 20),
            ],

            // Period
            _sectionLabel('Period'),
            const SizedBox(height: 8),
            _buildPeriodToggle(),
            const SizedBox(height: 20),

            // Day-of-week selector (only for daily goals)
            if (_period == GoalPeriod.daily) ...[
              _sectionLabel('Active days  (none = every day)'),
              const SizedBox(height: 8),
              _buildDaySelector(),
              const SizedBox(height: 20),
            ],

            // Screen time limit
            _sectionLabel('Screen time limit'),
            const SizedBox(height: 8),
            _buildTimePicker(),
            const SizedBox(height: 20),

            // Reward
            _sectionLabel('Reward'),
            const SizedBox(height: 8),
            _buildRewardPicker(),
            const SizedBox(height: 32),

            // Summary chip
            _buildSummary(),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedChildId == null || _totalMinutes == 0
                    ? null
                    : _save,
                child: const Text('Save Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textGrey,
          letterSpacing: 0.5),
    );
  }

  Widget _buildChildSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedChildId,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: widget.children
          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
          .toList(),
      onChanged: (v) => setState(() => _selectedChildId = v),
    );
  }

  Widget _buildPeriodToggle() {
    return SegmentedButton<GoalPeriod>(
      segments: const [
        ButtonSegment(value: GoalPeriod.daily, label: Text('Daily')),
        ButtonSegment(value: GoalPeriod.weekly, label: Text('Weekly')),
        ButtonSegment(value: GoalPeriod.monthly, label: Text('Monthly')),
      ],
      selected: {_period},
      onSelectionChanged: (s) => setState(() {
        _period = s.first;
        _activeDays.clear();
      }),
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = _dayValues[i];
        final selected = _activeDays.contains(day);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _activeDays.remove(day);
            } else {
              _activeDays.add(day);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  selected ? AppTheme.primaryPurple : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppTheme.primaryPurple
                    : Colors.grey.shade300,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _dayLabels[i],
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.textGrey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hours',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                DropdownButton<int>(
                  value: _limitHours,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: List.generate(
                    13,
                    (i) => DropdownMenuItem(
                        value: i, child: Text('$i hr')),
                  ),
                  onChanged: (v) => setState(() => _limitHours = v ?? 0),
                ),
              ],
            ),
          ),
          Container(
              width: 1, height: 48, color: Colors.grey.shade200),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('Minutes',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textGrey)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: DropdownButton<int>(
                    value: _limitMinutes,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [0, 15, 30, 45]
                        .map((m) => DropdownMenuItem(
                            value: m, child: Text('$m min')))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _limitMinutes = v ?? 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPicker() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${_rewardAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark)),
            Row(
              children: [
                _rewardBtn(Icons.remove, () {
                  if (_rewardAmount > 0.25) {
                    setState(() => _rewardAmount =
                        double.parse(
                            (_rewardAmount - 0.25).toStringAsFixed(2)));
                  }
                }),
                const SizedBox(width: 8),
                _rewardBtn(Icons.add, () {
                  setState(() => _rewardAmount =
                      double.parse(
                          (_rewardAmount + 0.25).toStringAsFixed(2)));
                }),
              ],
            )
          ],
        ),
        Slider(
          value: _rewardAmount,
          min: 0.25,
          max: 10.0,
          divisions: 39,
          activeColor: AppTheme.primaryPurple,
          onChanged: (v) => setState(() =>
              _rewardAmount = double.parse(v.toStringAsFixed(2))),
        ),
      ],
    );
  }

  Widget _rewardBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textDark),
      ),
    );
  }

  Widget _buildSummary() {
    final child = widget.children
        .firstWhere((c) => c.id == _selectedChildId,
            orElse: () =>
                FamilyMember(id: '', name: '—', balance: 0));
    final h = _limitHours;
    final m = _limitMinutes;
    final timeStr = h > 0 && m > 0
        ? '${h}h ${m}m'
        : h > 0
            ? '${h}h'
            : '${m}m';
    final daysStr = _period == GoalPeriod.daily && _activeDays.isNotEmpty
        ? ' on selected days'
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.2)),
      ),
      child: Text(
        '${child.name} earns \$${_rewardAmount.toStringAsFixed(2)} '
        'for staying under $timeStr of screen time '
        '${_period.name}$daysStr.',
        style: const TextStyle(
            color: AppTheme.textDark, fontSize: 14, height: 1.5),
      ),
    );
  }

  void _save() {
    final child =
        widget.children.firstWhere((c) => c.id == _selectedChildId);
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      assignedToId: child.id,
      assignedToName: child.name,
      maxMinutes: _totalMinutes,
      rewardAmount: _rewardAmount,
      period: _period,
      activeDays: _activeDays.toList()..sort(),
      createdAt: DateTime.now(),
    );
    widget.onSave(goal);
    Navigator.of(context).pop();
  }
}
