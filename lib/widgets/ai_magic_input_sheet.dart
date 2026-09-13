import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';

class AiMagicInputSheet extends StatefulWidget {
  const AiMagicInputSheet({Key? key}) : super(key: key);

  @override
  _AiMagicInputSheetState createState() => _AiMagicInputSheetState();
}

class _AiMagicInputSheetState extends State<AiMagicInputSheet> {
  final _controller = TextEditingController();
  final _aiService = AiService();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Prepare pitch deck tomorrow 4pm high priority work',
    'Study physics chapter 5 next week 60m deep focus',
    'Quick workout at gym today 30m high focus',
    'Clean office desk tomorrow low priority personal',
  ];

  void _processPrompt([String? promptText]) async {
    final text = promptText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final task = await _aiService.parseNaturalLanguageTask(text);
      await _firestoreService.addTask(task);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ AI created task "${task.title}" with ${task.subtasks.length} subtasks!'),
            backgroundColor: Color(0xFF6366F1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate task: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Magic Task Generator',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'Type naturally. AI auto-extracts dates, priority & subtasks.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'e.g. "Prepare Flutter presentation for client by tomorrow 4pm high priority work 60m"',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
              filled: true,
              fillColor: Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Try Quick AI Presets:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    backgroundColor: Colors.indigo.shade50,
                    side: BorderSide(color: Colors.indigo.shade100),
                    label: Text(
                      prompt.length > 30 ? prompt.substring(0, 30) + '...' : prompt,
                      style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF4338CA)),
                    ),
                    onPressed: () {
                      _controller.text = prompt;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 24),
          _isLoading
              ? Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFF6366F1)),
                      SizedBox(height: 8),
                      Text('AI is parsing prompt & creating subtasks...',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4F46E5),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  onPressed: () => _processPrompt(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Generate Task with AI',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
