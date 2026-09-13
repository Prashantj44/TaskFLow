import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../services/ai_service.dart';

class AiAssistantDialog extends StatefulWidget {
  final List<TaskModel> tasks;

  const AiAssistantDialog({Key? key, required this.tasks}) : super(key: key);

  @override
  _AiAssistantDialogState createState() => _AiAssistantDialogState();
}

class _AiAssistantDialogState extends State<AiAssistantDialog> {
  final _aiService = AiService();
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': '👋 Hi! I am TaskFlow AI. Ask me to help organize your schedule, recommend your next priority, or break down goals!'
    }
  ];
  bool _isTyping = false;

  void _sendMessage([String? customQuery]) async {
    final query = customQuery ?? _controller.text.trim();
    if (query.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _isTyping = true;
    });

    final reply = await _aiService.chatWithAiAssistant(query, widget.tasks);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'sender': 'ai', 'text': reply});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFF6366F1),
                child: Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TaskFlow AI Assistant',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Powered by TaskFlow AI Engine',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Color(0xFF4F46E5) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text']!,
                      style: GoogleFonts.inter(
                        color: isUser ? Colors.white : Color(0xFF1E293B),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)),
                    ),
                    SizedBox(width: 8),
                    Text('AI is thinking...', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  label: Text('What next?', style: TextStyle(fontSize: 11)),
                  onPressed: () => _sendMessage('What should I work on next?'),
                ),
                SizedBox(width: 6),
                ActionChip(
                  label: Text('Summarize status', style: TextStyle(fontSize: 11)),
                  onPressed: () => _sendMessage('Summarize my status'),
                ),
                SizedBox(width: 6),
                ActionChip(
                  label: Text('Focus Tip', style: TextStyle(fontSize: 11)),
                  onPressed: () => _sendMessage('Give me a focus tip'),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ask AI Assistant...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (val) => _sendMessage(),
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Color(0xFF4F46E5),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  onPressed: () => _sendMessage(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
