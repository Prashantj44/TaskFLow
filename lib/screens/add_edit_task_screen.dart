import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  AddEditTaskScreen({this.task});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _firestoreService = FirestoreService();
  
  DateTime _selectedDate = DateTime.now();
  bool _isCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.date;
      _isCompleted = widget.task!.isCompleted;
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        if (widget.task == null) {
          final newTask = TaskModel(
            id: '',
            title: _titleController.text,
            description: _descriptionController.text,
            date: _selectedDate,
            isCompleted: _isCompleted,
          );
          // Don't await to make UI feel instant
          _firestoreService.addTask(newTask);
        } else {
          final updatedTask = TaskModel(
            id: widget.task!.id,
            title: _titleController.text,
            description: _descriptionController.text,
            date: _selectedDate,
            isCompleted: _isCompleted,
          );
          // Don't await to make UI feel instant
          _firestoreService.updateTask(updatedTask);
        }
        // Go back immediately
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
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Task Details',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.inter(),
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF4F46E5), width: 2),
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? 'Please enter a title' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: GoogleFonts.inter(),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF4F46E5), width: 2),
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? 'Please enter a description' : null,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF4F46E5)),
                                  SizedBox(width: 8),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(_selectedDate),
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<bool>(
                                isExpanded: true,
                                value: _isCompleted,
                                icon: Icon(Icons.arrow_drop_down, color: Color(0xFF4F46E5)),
                                items: [
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text('Pending', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                                  ),
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text('Completed', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _isCompleted = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                    : ElevatedButton(
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
      ),
    );
  }
}
