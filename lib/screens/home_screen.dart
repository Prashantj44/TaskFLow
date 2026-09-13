import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import '../models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/ai_magic_input_sheet.dart';
import '../widgets/ai_assistant_dialog.dart';
import 'login_screen.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _aiService = AiService();

  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String _selectedEnergyFilter = 'All';
  bool _showCompleted = true;

  final List<String> _categories = ['All', 'Work', 'Personal', 'Study', 'Health', 'Dev', 'Creative'];

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  void _openAiMagicInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => AiMagicInputSheet(),
    );
  }

  void _openAiAssistant(List<TaskModel> tasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiAssistantDialog(tasks: tasks),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Text(
              'TaskFlow AI',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _firestoreService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          final allTasks = snapshot.data ?? [];
          final digest = _aiService.generateDailyDigest(allTasks);

          // Apply Filter Logic
          List<TaskModel> filteredTasks = allTasks.where((task) {
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final matchesTitle = task.title.toLowerCase().contains(query);
              final matchesDesc = task.description.toLowerCase().contains(query);
              if (!matchesTitle && !matchesDesc) return false;
            }
            if (_selectedCategoryFilter != 'All' && task.category != _selectedCategoryFilter) {
              return false;
            }
            if (_selectedEnergyFilter == 'Quick Wins' && task.energyLevel != 'Quick Win') {
              return false;
            } else if (_selectedEnergyFilter == 'High Focus' && task.energyLevel != 'High Focus') {
              return false;
            } else if (_selectedEnergyFilter == 'Urgent' && task.priority != 'high') {
              return false;
            }
            if (!_showCompleted && task.isCompleted) {
              return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Executive AI Daily Digest Banner
              _buildAiDigestCard(digest, () => _openAiAssistant(allTasks)),

              // Search Bar & Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search tasks, tags, or AI priorities...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12),

              // Filter Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ..._categories.map((cat) {
                      final isSel = _selectedCategoryFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: Color(0xFF4F46E5),
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategoryFilter = cat);
                          },
                        ),
                      );
                    }).toList(),

                    SizedBox(width: 8),

                    // Quick Wins & Urgent Filters
                    FilterChip(
                      label: Text('⚡ Quick Wins', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                      selected: _selectedEnergyFilter == 'Quick Wins',
                      onSelected: (selected) {
                        setState(() => _selectedEnergyFilter = selected ? 'Quick Wins' : 'All');
                      },
                    ),
                    SizedBox(width: 6),
                    FilterChip(
                      label: Text('🔥 Urgent', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                      selected: _selectedEnergyFilter == 'Urgent',
                      onSelected: (selected) {
                        setState(() => _selectedEnergyFilter = selected ? 'Urgent' : 'All');
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Task List
              Expanded(
                child: filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return TaskCard(
                            task: task,
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditTaskScreen(task: task),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.extended(
              heroTag: 'ai_magic',
              onPressed: _openAiMagicInput,
              backgroundColor: Color(0xFF0F172A),
              elevation: 4,
              icon: Icon(Icons.auto_awesome, color: Color(0xFF38BDF8)),
              label: Text(
                'AI Magic Task',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'add_task',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditTaskScreen()),
                );
              },
              backgroundColor: Color(0xFF4F46E5),
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiDigestCard(Map<String, dynamic> digest, VoidCallback onChatPressed) {
    final int score = digest['productivityScore'] ?? 100;
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4F46E5).withOpacity(0.35),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 20),
                  SizedBox(width: 8),
                  Text(
                    digest['greeting'] ?? 'AI Daily Digest',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onChatPressed,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Ask AI',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            digest['headline'] ?? '',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            digest['topRecommendation'] ?? '',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '$score% Velocity',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.indigo.shade200),
          SizedBox(height: 16),
          Text(
            'No matching tasks found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap "AI Magic Task" to create one with natural language!',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
