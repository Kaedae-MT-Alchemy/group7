import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'enrollment_service.dart';
import 'auth_navigation.dart';

const Color hubNavy = Color(0xFF202B48);
const Color hubOat = Color(0xFFF4F0E8);
const Color hubLilac = Color(0xFFDCD5EA);
const Color hubPurple = Color(0xFF7664A5);
const Color hubGold = Color(0xFFF0D977);
const Color hubSage = Color(0xFFB9C8B8);
const Color hubInk = Color(0xFF343746);

class HubCourse {
  final String id;
  final String category;
  final String title;
  final String description;
  final String duration;
  final double price;
  final IconData icon;
  final Color color;
  final List<String> lessons;
  final List<String> outcomes;

  const HubCourse({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
    required this.icon,
    required this.color,
    required this.lessons,
    required this.outcomes,
  });
}

const List<HubCourse> hubCourses = [
  HubCourse(
    id: 'self-awareness',
    category: 'DISCOVER',
    title: 'The Art of Self-Awareness',
    description: 'Understand your patterns, values, emotional triggers and strengths.',
    duration: '3 lessons · 35 minutes',
    price: 49.00,
    icon: Icons.explore_outlined,
    color: hubLilac,
    lessons: ['Notice your patterns', 'Name what you feel', 'Map your strengths'],
    outcomes: ['Recognise personal patterns', 'Identify emotional triggers', 'Choose one growth goal'],
  ),
  HubCourse(
    id: 'emotional-intelligence',
    category: 'PRACTISE',
    title: 'Emotional Intelligence',
    description: 'Build practical skills for thoughtful interactions and stronger relationships.',
    duration: '3 lessons · 45 minutes',
    price: 69.00,
    icon: Icons.auto_awesome_outlined,
    color: hubSage,
    lessons: ['Pause before responding', 'Listen with curiosity', 'Practise empathy'],
    outcomes: ['Respond rather than react', 'Listen without interrupting', 'Use empathy in daily conversations'],
  ),
  HubCourse(
    id: 'purpose-action',
    category: 'TRANSFORM',
    title: 'Purpose into Action',
    description: 'Turn personal insight into realistic habits and meaningful action.',
    duration: '3 lessons · 30 minutes',
    price: 59.00,
    icon: Icons.lightbulb_outline,
    color: hubGold,
    lessons: ['Define a meaningful goal', 'Build a small habit', 'Reflect and adjust'],
    outcomes: ['Set a clear intention', 'Plan a manageable habit', 'Review progress with kindness'],
  ),
];

// Cached enrolment IDs loaded from Firestore for the signed-in user.
final Set<String> hubEnrolledCourseIds = <String>{};
final Map<String, int> hubCompletedLessons = <String, int>{};

int completedLessonsFor(HubCourse course) {
  if (!hubEnrolledCourseIds.contains(course.id)) {
    return 0;
  }

  return hubCompletedLessons[course.id] ?? 0;
}

double progressFor(HubCourse course) {
  if (!hubEnrolledCourseIds.contains(course.id)) {
    return 0.0;
  }

  if (course.lessons.isEmpty) {
    return 0.0;
  }

  return (completedLessonsFor(course) / course.lessons.length)
      .clamp(0.0, 1.0)
      .toDouble();
}

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  String selectedFilter = 'All';
  final EnrollmentService _enrollmentService = EnrollmentService();
  bool isLoadingEnrollments = true;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    try {
      final records = await _enrollmentService.getEnrollmentRecords();
      if (!mounted) return;

      setState(() {
        hubEnrolledCourseIds
          ..clear()
          ..addAll(records.keys);
        hubCompletedLessons
          ..clear()
          ..addEntries(records.entries.map((entry) {
            final value = (entry.value['completedLessons'] as num?)?.toInt() ?? 0;
            return MapEntry(entry.key, value);
          }));
        isLoadingEnrollments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingEnrollments = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load enrolments: $e')),
      );
    }
  }

  bool showMyLearning = false;
  final Set<String> generatingCertificates = <String>{};

  Future<void> _openPlayer(HubCourse course) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HubCoursePlayerScreen(course: course),
      ),
    );
    if (mounted) {
      await _loadEnrollments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrolledCourses = hubCourses
        .where((course) => hubEnrolledCourseIds.contains(course.id))
        .toList();

    final visibleCourses = hubCourses.where((course) {
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'In progress') {
        return hubEnrolledCourseIds.contains(course.id) && progressFor(course) < 1;
      }
      if (selectedFilter == 'Not started') {
        return !hubEnrolledCourseIds.contains(course.id);
      }
      return hubEnrolledCourseIds.contains(course.id) && progressFor(course) >= 1;
    }).toList();

    final enrolledLessonCount = enrolledCourses.fold<int>(
      0,
          (sum, course) => sum + course.lessons.length,
    );
    final totalCompleted = enrolledCourses.fold<int>(
      0,
          (sum, course) => sum + completedLessonsFor(course),
    );
    final overallProgress = enrolledLessonCount == 0
        ? 0.0
        : (totalCompleted / enrolledLessonCount).clamp(0.0, 1.0).toDouble();
    final inProgressCount =
        enrolledCourses.where((course) => progressFor(course) < 1).length;
    final completedCourseCount =
        enrolledCourses.where((course) => progressFor(course) >= 1).length;

    return Scaffold(
      backgroundColor: hubOat,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: hubOat,
        foregroundColor: hubNavy,
        elevation: 0,
        title: const Text(
          'MT ALCHEMY',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
        ),
        leading: IconButton(
          tooltip: 'Return to Home',
          icon: const Icon(Icons.home_outlined),
          onPressed: () {
            Navigator.of(context).pushNamed('/');
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/');
            },
            child: const Text('HOME', style: TextStyle(color: hubNavy)),
          ),
          TextButton.icon(
            onPressed: () => confirmAndSignOut(context),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign out'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: isLoadingEnrollments
          ? const Center(child: CircularProgressIndicator(color: hubPurple))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _welcomeBanner(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _hubTab(
                          label: 'Explore courses',
                          selected: !showMyLearning,
                          onTap: () => setState(() => showMyLearning = false),
                        ),
                      ),
                      Expanded(
                        child: _hubTab(
                          label: 'My learning',
                          selected: showMyLearning,
                          onTap: () => setState(() => showMyLearning = true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                if (showMyLearning) ...[
                  _myLearningDashboard(
                    enrolledCourses: enrolledCourses,
                    overallProgress: overallProgress,
                    totalCompleted: totalCompleted,
                    enrolledLessonCount: enrolledLessonCount,
                    inProgressCount: inProgressCount,
                    completedCourseCount: completedCourseCount,
                  ),
                ] else ...[
                  const Text(
                    'YOUR LEARNING JOURNEY',
                    style: TextStyle(
                      color: hubPurple,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Small steps. Meaningful change.',
                    style: TextStyle(
                      color: hubNavy,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _progressCard(
                    overallProgress,
                    hubEnrolledCourseIds.length,
                    totalCompleted,
                    enrolledLessonCount,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Explore your pathways',
                    style: TextStyle(
                      color: hubNavy,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'In progress', 'Not started', 'Completed']
                        .map((filter) {
                      final selected = selectedFilter == filter;
                      return ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => selectedFilter = filter),
                        selectedColor: hubLilac,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: hubNavy,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: selected
                              ? hubPurple
                              : const Color(0xFFE1DBD2),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 850
                          ? 3
                          : (constraints.maxWidth >= 560 ? 2 : 1);
                      final width = (constraints.maxWidth -
                          ((columns - 1) * 16)) /
                          columns;
                      if (visibleCourses.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            'No courses in this category yet. Choose another filter to explore more.',
                            style: TextStyle(color: hubInk, height: 1.5),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: visibleCourses
                            .map(
                              (course) => SizedBox(
                            width: width,
                            child: _courseCard(course),
                          ),
                        )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: hubNavy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'A MOMENT TO REFLECT',
                          style: TextStyle(
                            color: hubGold,
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'What is one small change you can make today?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Growth is not a race. Give yourself room to learn.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Course content is sample data. Enrolments and lesson progress are saved to Firestore.',
                  style: TextStyle(color: Color(0xFF777777), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hubTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: selected ? hubNavy : Colors.white,
        foregroundColor: selected ? Colors.white : hubNavy,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _myLearningDashboard({
    required List<HubCourse> enrolledCourses,
    required double overallProgress,
    required int totalCompleted,
    required int enrolledLessonCount,
    required int inProgressCount,
    required int completedCourseCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MY LEARNING',
          style: TextStyle(
            color: hubPurple,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your courses, all in one place.',
          style: TextStyle(
            color: hubNavy,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pick up where you left off and keep moving towards completion.',
          style: TextStyle(color: hubInk, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 22),
        _progressCard(
          overallProgress,
          enrolledCourses.length,
          totalCompleted,
          enrolledLessonCount,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 12.0;
            final columns = constraints.maxWidth >= 700 ? 3 : 1;
            final width =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _dashboardStat('Enrolled courses', '${enrolledCourses.length}', Icons.menu_book_outlined, width),
                _dashboardStat('In progress', '$inProgressCount', Icons.play_circle_outline, width),
                _dashboardStat('Completed', '$completedCourseCount', Icons.task_alt, width),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your enrolled courses',
                style: TextStyle(
                  color: hubNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => showMyLearning = false),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Browse courses'),
              style: TextButton.styleFrom(foregroundColor: hubPurple),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (enrolledCourses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Icon(Icons.menu_book_outlined, color: hubPurple, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'You have not enrolled in a course yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hubNavy,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore the available pathways and enrol in a course to see it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: hubInk, height: 1.5),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setState(() => showMyLearning = false),
                  style: FilledButton.styleFrom(backgroundColor: hubNavy),
                  child: const Text('Explore courses'),
                ),
              ],
            ),
          )
        else
          ...enrolledCourses.map(_myLearningCourseCard),
      ],
    );
  }

  Widget _dashboardStat(String label, String value, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: hubLilac,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: hubNavy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: hubNavy, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: hubInk, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _generateCertificate(HubCourse course) async {
    if (generatingCertificates.contains(course.id)) return;

    setState(() => generatingCertificates.add(course.id));
    try {
      final learnerName = await _enrollmentService.getLearnerName();
      final certificate = await _enrollmentService.issueCertificate(
        courseId: course.id,
        courseTitle: course.title,
        totalLessons: course.lessons.length,
        learnerName: learnerName,
      );

      final issuedAt = certificate['certificateIssuedAt'];
      final completionDate = issuedAt is Timestamp
          ? issuedAt.toDate()
          : DateTime.now();
      final certificateId = certificate['certificateId'] as String;

      final document = pw.Document();
      final navy = PdfColor.fromInt(0xFF202B48);
      final purple = PdfColor.fromInt(0xFF7664A5);
      final gold = PdfColor.fromInt(0xFFF0D977);
      final oat = PdfColor.fromInt(0xFFF4F0E8);

      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(26),
          build: (context) => pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: navy, width: 3),
            ),
            padding: const pw.EdgeInsets.all(22),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: gold, width: 2),
                color: oat,
              ),
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 26,
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'MT ALCHEMY',
                    style: pw.TextStyle(
                      fontSize: 17,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 3,
                      color: navy,
                    ),
                  ),
                  pw.SizedBox(height: 18),
                  pw.Text(
                    'CERTIFICATE OF COMPLETION',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 27,
                      fontWeight: pw.FontWeight.bold,
                      color: purple,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'This certificate is proudly presented to',
                    style: pw.TextStyle(fontSize: 13, color: navy),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    learnerName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 30,
                      fontWeight: pw.FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'for successfully completing the course',
                    style: pw.TextStyle(fontSize: 13, color: navy),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    course.title,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: purple,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(width: 110, height: 2, color: gold),
                  pw.SizedBox(height: 16),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'DATE OF COMPLETION',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: purple,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            '${completionDate.day.toString().padLeft(2, '0')}/'
                                '${completionDate.month.toString().padLeft(2, '0')}/'
                                '${completionDate.year}',
                            style: pw.TextStyle(fontSize: 11, color: navy),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'CERTIFICATE ID',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: purple,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            certificateId,
                            style: pw.TextStyle(fontSize: 10, color: navy),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) => document.save(),
        name: 'MT_Alchemy_${course.id}_Certificate.pdf',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Certificate generated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to generate certificate: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => generatingCertificates.remove(course.id));
      }
    }
  }

  Widget _myLearningCourseCard(HubCourse course) {
    final completed = completedLessonsFor(course);
    final total = course.lessons.length;
    final progress = progressFor(course);
    final isComplete = total > 0 && completed >= total;
    final nextLessonIndex = total == 0 ? 0 : completed.clamp(0, total - 1).toInt();
    final nextLesson = total == 0 ? 'No lessons available' : course.lessons[nextLessonIndex];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E1D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: course.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(course.icon, color: hubNavy, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.category, style: const TextStyle(color: hubPurple, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(course.title, style: const TextStyle(color: hubNavy, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      isComplete ? 'Completed' : (completed == 0 ? 'Not started' : 'In progress'),
                      style: TextStyle(
                        color: isComplete ? Colors.green.shade700 : hubPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text('${(progress * 100).round()}%', style: const TextStyle(color: hubNavy, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: hubOat,
              valueColor: const AlwaysStoppedAnimation<Color>(hubPurple),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completed of $total lessons completed',
            style: const TextStyle(color: hubInk, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            isComplete ? 'All lessons completed. You can revisit the course at any time.' : 'Next lesson: $nextLesson',
            style: const TextStyle(color: hubInk, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: total == 0 ? null : () => _openPlayer(course),
              style: FilledButton.styleFrom(
                backgroundColor: hubNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: Icon(isComplete ? Icons.replay : Icons.play_arrow),
              label: Text(isComplete ? 'Review course' : (completed == 0 ? 'Start learning' : 'Continue learning')),
            ),
          ),
          if (isComplete) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: generatingCertificates.contains(course.id)
                    ? null
                    : () => _generateCertificate(course),
                icon: generatingCertificates.contains(course.id)
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.workspace_premium_outlined),
                label: Text(
                  generatingCertificates.contains(course.id)
                      ? 'Preparing certificate...'
                      : 'Generate & download certificate',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: hubPurple,
                  side: const BorderSide(color: hubPurple),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _welcomeBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(color: hubLilac, borderRadius: BorderRadius.circular(22)),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('WELCOME TO YOUR LEARNING SPACE', style: TextStyle(color: hubNavy, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
      SizedBox(height: 12),
      Text('Your next chapter starts here.', style: TextStyle(color: hubNavy, fontSize: 30, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('Explore ideas, practise new skills, and make change meaningful.', style: TextStyle(color: hubNavy, fontSize: 16)),
    ]),
  );

  Widget _progressCard(double progress, int enrolled, int completed, int total) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('YOUR OVERALL PROGRESS', style: TextStyle(color: hubNavy, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
      const SizedBox(height: 14),
      Row(children: [
        const Expanded(child: Text('Keep building momentum', style: TextStyle(color: hubNavy, fontSize: 19, fontWeight: FontWeight.w600)),),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: hubGold, borderRadius: BorderRadius.circular(30)), child: Text('$enrolled of ${hubCourses.length} enrolled', style: const TextStyle(color: hubNavy, fontWeight: FontWeight.bold, fontSize: 12))),
      ]),
      const SizedBox(height: 16),
      ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: hubOat, valueColor: const AlwaysStoppedAnimation<Color>(hubPurple))),
      const SizedBox(height: 8),
      Text('$completed of $total lessons completed · ${(progress * 100).round()}% overall', style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ]),
  );

  Widget _courseCard(HubCourse course) {
    final enrolled = hubEnrolledCourseIds.contains(course.id);
    final progress = progressFor(course);
    final progressLabel = progress >= 1 ? 'Course completed' : (progress > 0 ? '${(progress * 100).round()}% complete' : (enrolled ? 'Ready to begin' : 'Not enrolled yet'));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7E1D8))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: course.color, borderRadius: BorderRadius.circular(14)), child: Icon(course.icon, color: hubNavy, size: 25)),
        const SizedBox(height: 20),
        Text(course.category, style: const TextStyle(color: hubPurple, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(course.title, style: const TextStyle(color: hubNavy, fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(course.description, style: const TextStyle(color: Color(0xFF626262), fontSize: 14, height: 1.5)),
        const SizedBox(height: 12),
        Text(course.duration, style: const TextStyle(color: hubInk, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 18),
        if (enrolled) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: hubOat,
              valueColor: const AlwaysStoppedAnimation<Color>(hubPurple),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressLabel,
            style: const TextStyle(
              color: Color(0xFF626262),
              fontSize: 12,
            ),
          ),
        ] else ...[
          const Text(
            'Not enrolled yet',
            style: TextStyle(
              color: Color(0xFF626262),
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HubCourseDetailScreen(course: course),
              ),
            );
            if (mounted) {
              await _loadEnrollments();
            }
          },
          style: OutlinedButton.styleFrom(foregroundColor: hubNavy, side: const BorderSide(color: hubNavy), padding: const EdgeInsets.symmetric(vertical: 14)),
          child: Text(progress >= 1 ? 'Review course' : (enrolled ? 'Continue learning' : 'Explore course')),
        )),
      ]),
    );
  }
}

class HubCourseDetailScreen extends StatelessWidget {
  final HubCourse course;
  const HubCourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final enrolled = hubEnrolledCourseIds.contains(course.id);
    final progress = progressFor(course);
    return Scaffold(
      backgroundColor: hubOat,
      appBar: AppBar(backgroundColor: hubOat, foregroundColor: hubNavy, elevation: 0, title: const Text('COURSE DETAILS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: course.color, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(course.icon, color: hubNavy, size: 38),
            const SizedBox(height: 18),
            Text(course.category, style: const TextStyle(color: hubNavy, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Text(course.title, style: const TextStyle(color: hubNavy, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(course.description, style: const TextStyle(color: hubInk, fontSize: 16, height: 1.6)),
            const SizedBox(height: 12),
            Text(course.duration, style: const TextStyle(color: hubNavy, fontWeight: FontWeight.w700)),
          ])),
          const SizedBox(height: 24),
          _section('What you will learn', course.outcomes.map((item) => _bullet(item)).toList()),
          const SizedBox(height: 22),
          _section('Course modules', course.lessons.asMap().entries.map((entry) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: hubLilac, borderRadius: BorderRadius.circular(10)), alignment: Alignment.center, child: Text('${entry.key + 1}', style: const TextStyle(color: hubNavy, fontWeight: FontWeight.bold))),
            const SizedBox(width: 14),
            Expanded(child: Text(entry.value, style: const TextStyle(color: hubNavy, fontWeight: FontWeight.w600))),
            Icon(completedLessonsFor(course) > entry.key ? Icons.check_circle : Icons.play_circle_outline, color: hubPurple),
          ]))).toList()),
          const SizedBox(height: 24),
          if (enrolled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOUR PROGRESS',
                    style: TextStyle(
                      color: hubPurple,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: hubOat,
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(hubPurple),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).round()}% complete',
                    style: const TextStyle(color: hubInk),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: hubNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(18),
              ),
              onPressed: () async {
                try {
                  if (!enrolled) {
// Checkout must succeed before a Firestore enrolment is created.
                    final paymentSuccessful = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HubCourseCheckoutScreen(course: course),
                      ),
                    );

                    if (paymentSuccessful != true || !context.mounted) return;

                    await EnrollmentService().enrollInCourse(
                      courseId: course.id,
                      courseTitle: course.title,
                    );
                    hubEnrolledCourseIds.add(course.id);
                  }

                  if (!context.mounted) return;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HubCoursePlayerScreen(course: course),
                    ),
                  );

                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to complete checkout or enrolment: $e')),
                  );
                }
              },
              icon: Icon(enrolled ? Icons.play_arrow : Icons.lock_open_outlined),
              label: Text(
                enrolled
                    ? (progress >= 1 ? 'Review lessons' : 'Continue course')
                    : 'Proceed to checkout · RM ${course.price.toStringAsFixed(2)}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Course enrolments and lesson progress are saved to your signed-in account in Firestore.', style: TextStyle(color: Colors.black54, fontSize: 12)),
        ]))),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: hubNavy, fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 14),
    ...children,
  ]);

  Widget _bullet(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.check_circle_outline, color: hubPurple, size: 20),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: const TextStyle(color: hubInk, height: 1.5))),
  ]));
}


class HubCourseCheckoutScreen extends StatefulWidget {
  final HubCourse course;

  const HubCourseCheckoutScreen({super.key, required this.course});

  @override
  State<HubCourseCheckoutScreen> createState() =>
      _HubCourseCheckoutScreenState();
}

class _HubCourseCheckoutScreenState extends State<HubCourseCheckoutScreen> {
  String selectedMethod = 'Online banking';
  bool isProcessing = false;

  Future<void> _confirmPayment() async {
    setState(() => isProcessing = true);

// This is a demonstration only. No real payment provider is contacted.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: hubPurple, size: 48),
        title: const Text('Payment successful'),
        content: Text(
          'Your simulated payment of RM ${widget.course.price.toStringAsFixed(2)} '
              'for ${widget.course.title} was successful.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: hubNavy),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      backgroundColor: hubOat,
      appBar: AppBar(
        backgroundColor: hubOat,
        foregroundColor: hubNavy,
        elevation: 0,
        title: const Text('CHECKOUT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete your enrolment',
                  style: TextStyle(
                    color: hubNavy,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review your course and choose a simulated payment method.',
                  style: TextStyle(color: hubInk, height: 1.5),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORDER SUMMARY',
                        style: TextStyle(
                          color: hubPurple,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: hubNavy,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(course.duration,
                          style: const TextStyle(color: hubInk)),
                      const Divider(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  color: hubNavy,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            'RM ${course.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: hubNavy,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'PAYMENT METHOD',
                  style: TextStyle(
                    color: hubPurple,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'Online banking',
                        groupValue: selectedMethod,
                        activeColor: hubPurple,
                        onChanged: isProcessing
                            ? null
                            : (value) =>
                            setState(() => selectedMethod = value!),
                        title: const Text('Online banking'),
                        subtitle:
                        const Text('Simulated bank payment for testing'),
                        secondary: const Icon(Icons.account_balance,
                            color: hubPurple),
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        value: 'Demo card',
                        groupValue: selectedMethod,
                        activeColor: hubPurple,
                        onChanged: isProcessing
                            ? null
                            : (value) =>
                            setState(() => selectedMethod = value!),
                        title: const Text('Demo card'),
                        subtitle:
                        const Text('No card number or CVV is collected'),
                        secondary: const Icon(Icons.credit_card,
                            color: hubPurple),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: hubLilac.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: hubNavy),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Demonstration checkout only. No real money is charged and no payment details are collected.',
                          style: TextStyle(color: hubNavy, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isProcessing ? null : _confirmPayment,
                    style: FilledButton.styleFrom(
                      backgroundColor: hubNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                    ),
                    icon: isProcessing
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.lock_outline),
                    label: Text(isProcessing
                        ? 'Processing demo payment...'
                        : 'Pay RM ${course.price.toStringAsFixed(2)}'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: isProcessing
                        ? null
                        : () => Navigator.pop(context, false),
                    child: const Text('Cancel and return to course'),
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

class HubCoursePlayerScreen extends StatefulWidget {
  final HubCourse course;
  const HubCoursePlayerScreen({super.key, required this.course});

  @override
  State<HubCoursePlayerScreen> createState() => _HubCoursePlayerScreenState();
}

class _HubCoursePlayerScreenState extends State<HubCoursePlayerScreen> {
  late int lessonIndex;
  bool videoPlaying = false;
  int? selectedAnswer;
  bool quizSubmitted = false;
  bool isSavingProgress = false;
  final EnrollmentService _enrollmentService = EnrollmentService();

  @override
  void initState() {
    super.initState();
    lessonIndex = completedLessonsFor(widget.course).clamp(0, widget.course.lessons.length - 1).toInt();
  }

  void goToLesson(int nextIndex) {
    setState(() {
      lessonIndex = nextIndex;
      videoPlaying = false;
      selectedAnswer = null;
      quizSubmitted = false;
    });
  }

  Map<String, dynamic> _quizForLesson(String courseId, int index) {
    final quizzes = <String, List<Map<String, dynamic>>>{
      'self-awareness': [
        {'question': 'What is the most useful first step when you notice a strong emotion?', 'options': ['React immediately', 'Pause and name what you feel', 'Ignore it completely'], 'answer': 1, 'explanation': 'Naming an emotion creates a little space between the feeling and your response.'},
        {'question': 'An emotional trigger is best understood as…', 'options': ['A situation that reliably sparks a reaction', 'A personality flaw', 'Something you must avoid forever'], 'answer': 0, 'explanation': 'Noticing patterns helps you prepare a more intentional response.'},
        {'question': 'A useful strengths practice is to…', 'options': ['Compare yourself with everyone', 'Focus only on weaknesses', 'Notice when your strengths help you contribute'], 'answer': 2, 'explanation': 'Awareness of strengths helps you use them deliberately.'},
      ],
      'emotional-intelligence': [
        {'question': 'During a tense conversation, what is a helpful first move?', 'options': ['Speak louder to be understood', 'Pause and listen before replying', 'Assume the other person’s intent'], 'answer': 1, 'explanation': 'A pause can reduce reactivity and make room for understanding.'},
        {'question': 'Active listening means…', 'options': ['Planning your reply while they speak', 'Agreeing with everything', 'Trying to understand before responding'], 'answer': 2, 'explanation': 'Listening for meaning does not require you to agree; it shows curiosity.'},
        {'question': 'Empathy is the practice of…', 'options': ['Trying to understand another person’s perspective', 'Solving every problem for them', 'Avoiding difficult conversations'], 'answer': 0, 'explanation': 'Empathy starts with perspective-taking and a willingness to understand.'},
      ],
      'purpose-action': [
        {'question': 'Which goal is easiest to put into action?', 'options': ['Become better someday', 'Practise a 5-minute habit after lunch', 'Change everything this week'], 'answer': 1, 'explanation': 'Small, specific actions are easier to repeat and review.'},
        {'question': 'A sustainable habit is usually built by…', 'options': ['Starting small and repeating it', 'Waiting for perfect motivation', 'Setting the biggest possible target'], 'answer': 0, 'explanation': 'A manageable action repeated consistently builds momentum.'},
        {'question': 'When a habit does not go to plan, try to…', 'options': ['Give up on the goal', 'Blame yourself', 'Review what got in the way and adjust'], 'answer': 2, 'explanation': 'Reflection helps you adapt the plan without abandoning the intention.'},
      ],
    };
    return quizzes[courseId]![index];
  }

  Future<void> markComplete() async {
    if (isSavingProgress) return;

    final nextCompleted = (lessonIndex + 1)
        .clamp(0, widget.course.lessons.length)
        .toInt();

    setState(() => isSavingProgress = true);

    try {
      await _enrollmentService.updateLessonProgress(
        courseId: widget.course.id,
        completedLessons: nextCompleted,
        totalLessons: widget.course.lessons.length,
      );

      if (!mounted) return;

      hubCompletedLessons[widget.course.id] = nextCompleted;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextCompleted == widget.course.lessons.length
                ? 'Course completed — well done!'
                : 'Lesson progress saved.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save lesson progress: $e')),
      );
    } finally {
      if (mounted) setState(() => isSavingProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = completedLessonsFor(widget.course);
    final isLessonComplete = lessonIndex < completed;
    final allComplete = completed >= widget.course.lessons.length;
    final quiz = _quizForLesson(widget.course.id, lessonIndex);
    final quizCorrect = selectedAnswer == quiz['answer'];
    return Scaffold(
      backgroundColor: hubOat,
      appBar: AppBar(backgroundColor: hubOat, foregroundColor: hubNavy, elevation: 0, title: const Text('COURSE PLAYER')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 950), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.course.title, style: const TextStyle(color: hubNavy, fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Lesson ${lessonIndex + 1} of ${widget.course.lessons.length}', style: const TextStyle(color: hubPurple, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: completed / widget.course.lessons.length, minHeight: 8, backgroundColor: Colors.white, valueColor: const AlwaysStoppedAnimation<Color>(hubPurple)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFF182137),
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF202B48), Color(0xFF554C76)]),
          ),
          child: Stack(alignment: Alignment.center, children: [

            Positioned(
              top: 18,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'VIDEO LESSON PREVIEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(videoPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 68, color: hubGold),
              const SizedBox(height: 10),
              Text(videoPlaying ? 'Preview playing' : 'Play lesson preview', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Sample video area · no external video required', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            Positioned(left: 20, right: 20, bottom: 18, child: Row(children: [
              IconButton(onPressed: () => setState(() => videoPlaying = !videoPlaying), icon: Icon(videoPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white), tooltip: videoPlaying ? 'Pause preview' : 'Play preview'),
              Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: videoPlaying ? 0.62 : 0.12, minHeight: 5, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(hubGold)))),
              const SizedBox(width: 10),
              Text(videoPlaying ? '01:24 / 02:15' : '00:00 / 02:15', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
          ]),
        ),
        const SizedBox(height: 24),
        Container(width: double.infinity, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: hubNavy, borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.self_improvement, color: hubGold, size: 42),
          const SizedBox(height: 18),
          const Text('PAUSE · NOTICE · REFLECT', style: TextStyle(color: hubGold, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(widget.course.lessons[lessonIndex], style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          const Text('Take a moment to connect this idea to a real situation in your life. What did you notice? What might you try differently next time? Small, deliberate steps can create lasting change.', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.7)),
        ])),
        const SizedBox(height: 24),
        Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE7E1D8))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('KNOWLEDGE CHECK', style: TextStyle(color: hubPurple, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(quiz['question'] as String, style: const TextStyle(color: hubNavy, fontSize: 18, height: 1.45, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...((quiz['options'] as List<String>).asMap().entries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: selectedAnswer == entry.key ? hubLilac.withOpacity(0.55) : hubOat.withOpacity(0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: selectedAnswer == entry.key ? hubPurple : Colors.transparent)),
            child: RadioListTile<int>(value: entry.key, groupValue: selectedAnswer, onChanged: quizSubmitted ? null : (value) => setState(() => selectedAnswer = value), activeColor: hubPurple, title: Text(entry.value, style: const TextStyle(color: hubInk, height: 1.35)), dense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
          ))),
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            FilledButton(onPressed: selectedAnswer == null ? null : () => setState(() => quizSubmitted = true), style: FilledButton.styleFrom(backgroundColor: hubNavy), child: Text(quizSubmitted ? 'Answer checked' : 'Check answer')),
            if (quizSubmitted) TextButton(onPressed: () => setState(() { selectedAnswer = null; quizSubmitted = false; }), child: const Text('Try again')),
          ]),
          if (quizSubmitted) ...[
            const SizedBox(height: 12),
            Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: quizCorrect ? hubSage.withOpacity(0.45) : const Color(0xFFFFE8E4), borderRadius: BorderRadius.circular(12)), child: Text(quizCorrect ? 'Correct. ${quiz['explanation']}' : 'Not quite. ${quiz['explanation']}', style: const TextStyle(color: hubNavy, height: 1.45))),
          ],
        ])),
        const SizedBox(height: 24),
        Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('REFLECTION PROMPT', style: TextStyle(color: hubPurple, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('What is one insight from “${widget.course.lessons[lessonIndex]}” that you can put into practice this week?', style: const TextStyle(color: hubNavy, fontSize: 18, height: 1.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          const TextField(maxLines: 3, decoration: InputDecoration(hintText: 'Write a reflection (optional)', border: OutlineInputBorder())),
        ])),
        const SizedBox(height: 22),
        Wrap(spacing: 12, runSpacing: 12, children: [
          OutlinedButton.icon(onPressed: lessonIndex > 0 ? () => goToLesson(lessonIndex - 1) : null, icon: const Icon(Icons.arrow_back), label: const Text('Previous')),
          FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: hubNavy, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)), onPressed: (isLessonComplete || isSavingProgress || !(quizSubmitted && quizCorrect)) ? null : markComplete, icon: const Icon(Icons.check), label: Text(isLessonComplete ? 'Lesson completed' : ((quizSubmitted && quizCorrect) ? 'Mark complete' : 'Pass quiz to complete'))),
          FilledButton.tonalIcon(onPressed: lessonIndex < widget.course.lessons.length - 1 ? () => goToLesson(lessonIndex + 1) : null, icon: const Icon(Icons.arrow_forward), label: const Text('Next lesson')),
          if (allComplete) FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: hubPurple), onPressed: () => Navigator.pop(context), icon: const Icon(Icons.celebration), label: const Text('Back to course')),
        ]),
        const SizedBox(height: 20),
        const Text('Video is a visual prototype placeholder, and quiz questions are sample learning content. Lesson completion is saved to your account in Firestore.', style: TextStyle(color: Colors.black54, fontSize: 12)),
      ])))),
    );
  }
}

