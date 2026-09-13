import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import 'category_chip.dart';
import 'priority_badge.dart';
import 'focus_timer_dialog.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onEdit;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onEdit,
  }) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final _firestoreService = FirestoreService();
  bool _isExpanded = false;

  void _openFocusTimer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FocusTimerDialog(task: widget.task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final hasSubtasks = task.subtasks.isNotEmpty;
    final double completionRatio = task.completionPercentage;
    final int completedSubtasksCount = task.subtasks.where((s) => s.isCompleted).length;

    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: task.isCompleted
              ? Colors.grey.shade200
              : (task.priority == 'high'
                  ? Color(0xFFEF4444).withOpacity(0.3)
                  : Colors.grey.shade200),
          width: task.priority == 'high' && !task.isCompleted ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _firestoreService.markCompleted(task.id, !task.isCompleted);
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted ? Color(0xFF10B981) : Colors.transparent,
                          border: Border.all(
                            color: task.isCompleted ? Color(0xFF10B981) : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: task.isCompleted ? Colors.grey.shade400 : Color(0xFF1E293B),
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    PriorityBadge(priority: task.priority),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 38.0),
                    child: Text(
                      task.description,
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 38.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CategoryChip(category: task.category),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 12, color: Colors.indigo.shade600),
                            SizedBox(width: 4),
                            Text(
                              task.energyLevel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                            SizedBox(width: 4),
                            Text(
                              '${task.estimatedMinutes}m',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                          SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d').format(task.date),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (hasSubtasks) ...[
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 38.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtasks: $completedSubtasksCount/${task.subtasks.length}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => _isExpanded = !_isExpanded);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    _isExpanded ? 'Hide' : 'Show',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Color(0xFF6366F1),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    size: 18,
                                    color: Color(0xFF6366F1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completionRatio,
                            minHeight: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              completionRatio == 1.0 ? Color(0xFF10B981) : Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isExpanded && hasSubtasks) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Container(
              color: Color(0xFFF8FAFC),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: List.generate(task.subtasks.length, (index) {
                  final st = task.subtasks[index];
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.only(left: 38),
                    activeColor: Color(0xFF6366F1),
                    title: Text(
                      st.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: st.isCompleted ? Colors.grey.shade400 : Color(0xFF334155),
                        decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    value: st.isCompleted,
                    onChanged: (val) async {
                      setState(() {
                        st.isCompleted = val ?? false;
                      });
                      await _firestoreService.updateSubtasks(task.id, task.subtasks);
                    },
                  );
                }),
              ),
            ),
          ],
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF6366F1),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: Icon(Icons.bolt_rounded, size: 18),
                  label: Text(
                    'Deep Focus',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _openFocusTimer,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 18, color: Colors.grey.shade600),
                      onPressed: widget.onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                      onPressed: () {
                        _firestoreService.deleteTask(task.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
