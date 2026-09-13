import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class FocusTimerDialog extends StatefulWidget {
  final TaskModel task;

  const FocusTimerDialog({Key? key, required this.task}) : super(key: key);

  @override
  _FocusTimerDialogState createState() => _FocusTimerDialogState();
}

class _FocusTimerDialogState extends State<FocusTimerDialog> {
  final _firestoreService = FirestoreService();
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = (widget.task.estimatedMinutes > 0 ? widget.task.estimatedMinutes : 25) * 60;
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          _showCompletionAlert();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
    });
  }

  void _showCompletionAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('🎉 Focus Session Completed!', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'Great job focusing on "${widget.task.title}"! Would you like to mark this task as completed?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Pending'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.markCompleted(widget.task.id, true);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Mark Completed'),
          ),
        ],
      ),
    );
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    double progress = _totalSeconds > 0 ? (_totalSeconds - _remainingSeconds) / _totalSeconds : 0.0;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF0F172A), // Sleek Dark Obsidian Theme
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Color(0xFF38BDF8), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'AI Deep Work Mode',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              widget.task.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
            ),
            SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formattedTime,
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _isRunning ? 'FOCUSING' : 'PAUSED',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isRunning ? Color(0xFF34D399) : Colors.white38,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white10,
                    padding: EdgeInsets.all(16),
                  ),
                  icon: Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _resetTimer,
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Color(0xFFEF4444) : Color(0xFF6366F1),
                    padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _toggleTimer,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _isRunning ? 'Pause' : 'Start Focus',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.task.subtasks.isNotEmpty) ...[
              SizedBox(height: 28),
              Divider(color: Colors.white12),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Subtasks to Complete:',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 8),
              ...List.generate(widget.task.subtasks.length, (index) {
                final st = widget.task.subtasks[index];
                return CheckboxListTile(
                  dense: true,
                  activeColor: Color(0xFF6366F1),
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    st.title,
                    style: GoogleFonts.inter(
                      color: st.isCompleted ? Colors.white38 : Colors.white70,
                      decoration: st.isCompleted ? TextDecoration.lineThrough : null,
                      fontSize: 13,
                    ),
                  ),
                  value: st.isCompleted,
                  onChanged: (val) async {
                    setState(() {
                      st.isCompleted = val ?? false;
                    });
                    await _firestoreService.updateSubtasks(widget.task.id, widget.task.subtasks);
                  },
                );
              }),
            ],
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
