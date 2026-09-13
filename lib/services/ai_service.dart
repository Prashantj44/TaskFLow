import 'dart:math';
import '../models/task_model.dart';

class AiService {
  /// Parses natural language user input into a structured TaskModel
  Future<TaskModel> parseNaturalLanguageTask(String prompt) async {
    // Artificial slight delay to simulate fast AI inference
    await Future.delayed(Duration(milliseconds: 400));

    final cleanPrompt = prompt.trim();
    final lowerPrompt = cleanPrompt.toLowerCase();

    // Priority detection
    String priority = 'medium';
    double aiScore = 55.0;
    if (lowerPrompt.contains('urgent') ||
        lowerPrompt.contains('high priority') ||
        lowerPrompt.contains('asap') ||
        lowerPrompt.contains('critical') ||
        lowerPrompt.contains('important')) {
      priority = 'high';
      aiScore = 88.0;
    } else if (lowerPrompt.contains('low priority') ||
        lowerPrompt.contains('whenever') ||
        lowerPrompt.contains('casual')) {
      priority = 'low';
      aiScore = 30.0;
    }

    // Category detection
    String category = 'Work';
    if (lowerPrompt.contains('workout') ||
        lowerPrompt.contains('health') ||
        lowerPrompt.contains('gym') ||
        lowerPrompt.contains('doctor') ||
        lowerPrompt.contains('run')) {
      category = 'Health';
    } else if (lowerPrompt.contains('study') ||
        lowerPrompt.contains('exam') ||
        lowerPrompt.contains('read') ||
        lowerPrompt.contains('course') ||
        lowerPrompt.contains('chapter')) {
      category = 'Study';
    } else if (lowerPrompt.contains('flutter') ||
        lowerPrompt.contains('code') ||
        lowerPrompt.contains('dev') ||
        lowerPrompt.contains('bug') ||
        lowerPrompt.contains('app') ||
        lowerPrompt.contains('github') ||
        lowerPrompt.contains('api')) {
      category = 'Dev';
    } else if (lowerPrompt.contains('design') ||
        lowerPrompt.contains('art') ||
        lowerPrompt.contains('write') ||
        lowerPrompt.contains('blog') ||
        lowerPrompt.contains('music')) {
      category = 'Creative';
    } else if (lowerPrompt.contains('buy') ||
        lowerPrompt.contains('clean') ||
        lowerPrompt.contains('home') ||
        lowerPrompt.contains('family') ||
        lowerPrompt.contains('personal')) {
      category = 'Personal';
    }

    // Energy level detection
    String energy = 'Quick Win';
    if (lowerPrompt.contains('deep') ||
        lowerPrompt.contains('focus') ||
        lowerPrompt.contains('heavy') ||
        lowerPrompt.contains('complex') ||
        category == 'Dev' ||
        category == 'Study') {
      energy = 'High Focus';
    } else if (lowerPrompt.contains('easy') ||
        lowerPrompt.contains('quick') ||
        lowerPrompt.contains('call') ||
        lowerPrompt.contains('mail')) {
      energy = 'Quick Win';
    }

    // Estimated duration detection
    int estimatedMinutes = 30;
    if (lowerPrompt.contains('15m') || lowerPrompt.contains('15 min')) {
      estimatedMinutes = 15;
    } else if (lowerPrompt.contains('45m') || lowerPrompt.contains('45 min')) {
      estimatedMinutes = 45;
    } else if (lowerPrompt.contains('1h') || lowerPrompt.contains('60m') || lowerPrompt.contains('hour')) {
      estimatedMinutes = 60;
    } else if (lowerPrompt.contains('2h') || lowerPrompt.contains('120m')) {
      estimatedMinutes = 120;
    }

    // Due date detection
    DateTime date = DateTime.now();
    if (lowerPrompt.contains('tomorrow')) {
      date = DateTime.now().add(Duration(days: 1));
    } else if (lowerPrompt.contains('next week')) {
      date = DateTime.now().add(Duration(days: 7));
    } else if (lowerPrompt.contains('friday')) {
      int daysUntilFriday = (DateTime.friday - DateTime.now().weekday + 7) % 7;
      if (daysUntilFriday == 0) daysUntilFriday = 7;
      date = DateTime.now().add(Duration(days: daysUntilFriday));
    }

    // Capitalize Title nicely
    String title = cleanPrompt;
    if (title.length > 50) {
      title = title.substring(0, 50) + '...';
    }

    // Generate intelligent subtasks
    List<SubTask> subtasks = await generateSubtasks(title, cleanPrompt, category: category);

    return TaskModel(
      id: '',
      title: title,
      description: 'AI Generated Task from NLP Prompt: "$cleanPrompt"',
      date: date,
      priority: priority,
      category: category,
      subtasks: subtasks,
      estimatedMinutes: estimatedMinutes,
      energyLevel: energy,
      aiPriorityScore: aiScore,
    );
  }

  /// Generates subtasks tailored to task context
  Future<List<SubTask>> generateSubtasks(String title, String description, {String category = 'Work'}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final text = '$title $description'.toLowerCase();

    List<String> steps = [];

    if (text.contains('flutter') || text.contains('app') || text.contains('code')) {
      steps = [
        'Outline app architecture & state requirements',
        'Build responsive UI screens & themes',
        'Integrate Firebase & AI API logic',
        'Run flutter analyze & test on device',
      ];
    } else if (text.contains('study') || text.contains('exam') || text.contains('read')) {
      steps = [
        'Gather lecture notes & reference materials',
        'Summarize core formulas & key definitions',
        'Solve 3 practice questions',
        'Perform timed self-assessment quiz',
      ];
    } else if (text.contains('presentation') || text.contains('deck') || text.contains('report')) {
      steps = [
        'Draft executive summary & slide outline',
        'Gather relevant metrics & chart graphics',
        'Design visually engaging slide visuals',
        'Conduct 5-minute practice dry run',
      ];
    } else if (text.contains('gym') || text.contains('workout') || text.contains('health')) {
      steps = [
        'Prepare hydration & pre-workout gear',
        'Warm-up: 5 mins light cardio & stretching',
        'Execute core exercise sequence (3 sets)',
        'Cool down & log personal record',
      ];
    } else if (text.contains('clean') || text.contains('organize') || text.contains('home')) {
      steps = [
        'Clear clutter from workspace/room',
        'Wipe surfaces & organize essentials',
        'Take out trash & recycling',
      ];
    } else {
      steps = [
        'Initial research & resource setup',
        'Execute primary action items',
        'Quality check & finalize outcome',
      ];
    }

    return steps.map((s) => SubTask(title: s, isCompleted: false)).toList();
  }

  /// Generates daily digest & AI focus recommendations
  Map<String, dynamic> generateDailyDigest(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return {
        'greeting': 'Hello Innovator! 👋',
        'headline': 'Your canvas is completely clean!',
        'topRecommendation': 'Tap "+ AI Magic Task" to create your first intelligent workflow.',
        'focusTip': 'Setting clear daily goals increases completion rate by 80%.',
        'productivityScore': 100,
        'completedCount': 0,
        'pendingCount': 0,
      };
    }

    int completed = tasks.where((t) => t.isCompleted).length;
    int pending = tasks.length - completed;
    int score = (tasks.isEmpty) ? 100 : ((completed / tasks.length) * 100).round();

    List<TaskModel> pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    // Sort pending by AI Priority Score descending
    pendingTasks.sort((a, b) => b.aiPriorityScore.compareTo(a.aiPriorityScore));

    String topRec = pendingTasks.isNotEmpty
        ? '🎯 Start with "${pendingTasks.first.title}" (${pendingTasks.first.energyLevel} • ${pendingTasks.first.priority.toUpperCase()} priority)'
        : '🎉 All tasks for today are completed! Great work!';

    String focusTip = 'Pro Tip: Complete 1 "High Focus" task early in the morning for maximum momentum.';
    if (pendingTasks.any((t) => t.energyLevel == 'Quick Win')) {
      focusTip = 'Pro Tip: You have quick win tasks ready! Clear them in 15 mins to boost your streak.';
    }

    return {
      'greeting': 'TaskFlow AI Command Center ⚡',
      'headline': '$pending Pending • $completed Completed ($score% Velocity)',
      'topRecommendation': topRec,
      'focusTip': focusTip,
      'productivityScore': score,
      'completedCount': completed,
      'pendingCount': pending,
    };
  }

  /// Answers user query in the interactive AI Assistant Sheet
  Future<String> chatWithAiAssistant(String query, List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: 500));
    final q = query.toLowerCase();

    final pending = tasks.where((t) => !t.isCompleted).toList();
    final highPriority = pending.where((t) => t.priority == 'high').toList();

    if (q.contains('what next') || q.contains('recommend') || q.contains('start')) {
      if (highPriority.isNotEmpty) {
        return '🤖 Based on priority scoring, I strongly recommend focusing on "${highPriority.first.title}" next. It requires ${highPriority.first.estimatedMinutes} mins of ${highPriority.first.energyLevel}.';
      } else if (pending.isNotEmpty) {
        return '🤖 I suggest starting with "${pending.first.title}". Completing this will give you momentum for the rest of your day!';
      } else {
        return '🤖 All current tasks are done! Would you like me to help you plan new goals for tomorrow?';
      }
    } else if (q.contains('summary') || q.contains('status') || q.contains('how am i doing')) {
      final done = tasks.length - pending.length;
      return '📊 You currently have ${tasks.length} total tasks. $done completed and ${pending.length} pending. ${highPriority.length} marked as High Priority.';
    } else if (q.contains('tip') || q.contains('motivation') || q.contains('focus')) {
      final tips = [
        '💡 Try the Pomodoro technique: 25 minutes of deep focus followed by a 5-minute break.',
        '💡 Group similar tasks (e.g. all Dev or all Emails) into single focus blocks.',
        '💡 Tackle your hardest "High Focus" task first when your cognitive energy is highest.',
      ];
      return tips[Random().nextInt(tips.length)];
    }

    return '🤖 I am your TaskFlow AI assistant. I can help you prioritize tasks, auto-generate subtasks, plan study sessions, or track your daily momentum. Ask me "What should I do next?" or "Summarize my status"!';
  }
}
