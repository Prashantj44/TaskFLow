import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import '../widgets/category_chip.dart';
import '../widgets/priority_badge.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();
  
  final _firestoreService = FirestoreService();
  final _aiService = AiService();
  
  DateTime _selectedDate = DateTime.now();
  bool _isCompleted = false;
  String _selectedPriority = 'medium';
  String _selectedCategory = 'Work';
  String _selectedEnergy = 'Quick Win';
  int _estimatedMinutes = 30;
  List<SubTask> _subtasks = [];
  
  bool _isLoading = false;
  bool _isAiGenerating = false;

  final List<String> _categories = ['Work', 'Personal', 'Study', 'Health', 'Dev', 'Creative'];
  final List<String> _priorities = ['low', 'medium', 'high'];
  final List<String> _energyLevels = ['High Focus', 'Quick Win', 'Low Energy'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descriptionController.text = t.description;
      _selectedDate = t.date;
      _isCompleted = t.isCompleted;
      _selectedPriority = t.priority;
      _selectedCategory = t.category;
      _selectedEnergy = t.energyLevel;
      _estimatedMinutes = t.estimatedMinutes;
      _subtasks = List.from(t.subtasks.map((st) => SubTask(title: st.title, isCompleted: st.isCompleted)));
    }
  }

  void _generateAiSubtasks() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a Task Title first!')),
      );
      return;
    }

    setState(() => _isAiGenerating = true);
    try {
      final aiGenerated = await _aiService.generateSubtasks(
        title,
        _descriptionController.text,
        category: _selectedCategory,
      );
      setState(() {
        _subtasks.addAll(aiGenerated);
        _isAiGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ AI generated ${aiGenerated.length} subtasks!'),
          backgroundColor: Color(0xFF6366F1),
        ),
      );
    } catch (e) {
      setState(() => _isAiGenerating = false);
    }
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTask(title: text, isCompleted: false));
        _subtaskController.clear();
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final taskData = TaskModel(
          id: widget.task?.id ?? '',
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          isCompleted: _isCompleted,
          priority: _selectedPriority,
          category: _selectedCategory,
          energyLevel: _selectedEnergy,
          estimatedMinutes: _estimatedMinutes,
          subtasks: _subtasks,
          aiPriorityScore: _selectedPriority == 'high'
              ? 85.0
              : (_selectedPriority == 'medium' ? 55.0 : 30.0),
        );

        if (widget.task == null) {
          _firestoreService.addTask(taskData);
        } else {
          _firestoreService.updateTask(taskData);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF4F46E5), 
              onPrimary: Colors.white, 
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'New AI Task' : 'Edit Task',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g. Build Flutter AI task manager',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Category Selection
              Text(
                'Category',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CategoryChip(
                        category: cat,
                        isSelected: isSel,
                        onTap: () => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),

              // Priority & Energy Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Priority', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedPriority,
                              items: _priorities.map((p) {
                                return DropdownMenuItem(
                                  value: p,
                                  child: Row(
                                    children: [
                                      PriorityBadge(priority: p),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedPriority = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Energy Required', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedEnergy,
                              items: _energyLevels.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedEnergy = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Date & Time Picker Card
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: Color(0xFF6366F1)),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Due Date', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // AI Subtasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtasks (${_subtasks.length})',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  _isAiGenerating
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366F1)))
                      : TextButton.icon(
                          onPressed: _generateAiSubtasks,
                          icon: Icon(Icons.auto_awesome, size: 16, color: Color(0xFF6366F1)),
                          label: Text('Breakdown with AI', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6366F1))),
                        ),
                ],
              ),
              SizedBox(height: 8),

              // Subtasks list
              if (_subtasks.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _subtasks.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final st = _subtasks[index];
                      return ListTile(
                        dense: true,
                        leading: Checkbox(
                          activeColor: Color(0xFF6366F1),
                          value: st.isCompleted,
                          onChanged: (val) {
                            setState(() => st.isCompleted = val ?? false);
                          },
                        ),
                        title: Text(st.title, style: GoogleFonts.inter(fontSize: 13)),
                        trailing: IconButton(
                          icon: Icon(Icons.close, size: 16, color: Colors.grey),
                          onPressed: () {
                            setState(() => _subtasks.removeAt(index));
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
              ],

              // Manual Subtask input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      style: GoogleFonts.inter(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Add subtask item...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: Color(0xFF6366F1)),
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: _addSubtask,
                  ),
                ],
              ),
              SizedBox(height: 32),

              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4F46E5),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _saveTask,
                      child: Text(
                        widget.task == null ? 'Save Task' : 'Update Task',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
