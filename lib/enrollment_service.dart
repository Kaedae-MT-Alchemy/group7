import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnrollmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please sign in to enrol in a course.');
    }

    return user.uid;
  }

  // Save a course enrolment for the signed-in user.
  Future<void> enrollInCourse({
    required String courseId,
    required String courseTitle,
  }) async {
    final enrollmentRef = _db
        .collection('users')
        .doc(_userId)
        .collection('enrollments')
        .doc(courseId);

    final existingEnrollment = await enrollmentRef.get();

    if (existingEnrollment.exists) {
      return;
    }

    await enrollmentRef.set({
      'courseId': courseId,
      'courseTitle': courseTitle,
      'enrolledAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'completedLessons': 0,
      'progress': 0,
    });
  }

  // Retrieve all enrolments belonging to the signed-in user.
  Stream<QuerySnapshot<Map<String, dynamic>>> getEnrollments() {
    return _db
        .collection('users')
        .doc(_userId)
        .collection('enrollments')
        .snapshots();
  }

  // Retrieve the IDs of all courses enrolled by the current user.
  Future<Set<String>> getEnrolledCourseIds() async {
    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('enrollments')
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  // Retrieve each enrolled course's saved progress from Firestore.
  Future<Map<String, Map<String, dynamic>>> getEnrollmentRecords() async {
    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('enrollments')
        .get();

    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }

  // Persist lesson completion for an enrolled course.
  Future<void> updateLessonProgress({
    required String courseId,
    required int completedLessons,
    required int totalLessons,
  }) async {
    if (totalLessons <= 0) {
      throw ArgumentError.value(
        totalLessons,
        'totalLessons',
        'Must be greater than zero.',
      );
    }

    final safeCompleted = completedLessons.clamp(0, totalLessons);
    final progress = safeCompleted / totalLessons;
    final enrollmentRef = _db
        .collection('users')
        .doc(_userId)
        .collection('enrollments')
        .doc(courseId);

    await _db.runTransaction((transaction) async {
      final enrollment = await transaction.get(enrollmentRef);
      if (!enrollment.exists) {
        throw StateError(
          'You must be enrolled in this course before saving progress.',
        );
      }

      final currentData = enrollment.data() as Map<String, dynamic>;
      final currentCompleted =
          (currentData['completedLessons'] as num?)?.toInt() ?? 0;
      // Never reduce progress if an older lesson is revisited.
      final updatedCompleted = safeCompleted > currentCompleted
          ? safeCompleted
          : currentCompleted;
      final updatedProgress = updatedCompleted / totalLessons;

      transaction.update(enrollmentRef, {
        'completedLessons': updatedCompleted,
        'progress': updatedProgress,
        'status': updatedCompleted >= totalLessons ? 'completed' : 'active',
      });
    });
  }

  // Resolve a learner's display name from their profile, then Firebase Auth.
  Future<String> getLearnerName() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to access your certificate.');
    }

    final profile = await _db.collection('users').doc(user.uid).get();
    final data = profile.data() ?? <String, dynamic>{};

    final fullName =
        (data['fullName'] ??
                data['name'] ??
                data['displayName'] ??
                data['full_name'])
            ?.toString()
            .trim();

    if (fullName != null && fullName.isNotEmpty) return fullName;

    final firstName = data['firstName']?.toString().trim() ?? '';
    final lastName = data['lastName']?.toString().trim() ?? '';
    final profileName = '$firstName $lastName'.trim();
    if (profileName.isNotEmpty) return profileName;

    final authName = user.displayName?.trim();
    if (authName != null && authName.isNotEmpty) return authName;

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    throw StateError(
      'Your account does not have a learner name. Please update your profile first.',
    );
  }

  // Issue one certificate per completed course. Repeated requests return
  // the existing certificate ID rather than creating duplicates.
  Future<Map<String, dynamic>> issueCertificate({
    required String courseId,
    required String courseTitle,
    required int totalLessons,
    required String learnerName,
  }) async {
    if (totalLessons <= 0) {
      throw ArgumentError.value(
        totalLessons,
        'totalLessons',
        'Must be greater than zero.',
      );
    }

    final enrollmentRef = _db
        .collection('users')
        .doc(_userId)
        .collection('enrollments')
        .doc(courseId);
    final proposedCertificateId =
        'MTA-${_userId.substring(0, _userId.length >= 6 ? 6 : _userId.length).toUpperCase()}-'
        '${_db.collection('_certificateIds').doc().id.substring(0, 8).toUpperCase()}';

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(enrollmentRef);
      if (!snapshot.exists) {
        throw StateError('No enrolment record exists for this course.');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final completed = (data['completedLessons'] as num?)?.toInt() ?? 0;
      if (completed < totalLessons || data['status'] != 'completed') {
        throw StateError(
          'Complete every lesson before generating your certificate.',
        );
      }

      final existingId = data['certificateId']?.toString();
      if (existingId != null && existingId.isNotEmpty) return;

      transaction.update(enrollmentRef, {
        'certificateId': proposedCertificateId,
        'certificateLearnerName': learnerName,
        'certificateCourseTitle': courseTitle,
        'certificateIssuedAt': FieldValue.serverTimestamp(),
      });
    });

    final updated = await enrollmentRef.get();
    return updated.data() ?? <String, dynamic>{};
  }

  // Retrieve certificates already issued to the signed-in learner.
  // Certificates are stored on the corresponding enrolment documents.
  Future<List<Map<String, dynamic>>> getCertificates() async {
    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('enrollments')
        .get();

    return snapshot.docs
        .where((doc) {
          final certificateId = doc.data()['certificateId'];
          return certificateId is String && certificateId.isNotEmpty;
        })
        .map((doc) => <String, dynamic>{...doc.data(), 'courseId': doc.id})
        .toList();
  }

  // Check whether the user is enrolled in a particular course.
  Future<bool> isEnrolled(String courseId) async {
    final enrollment = await _db
        .collection('users')
        .doc(_userId)
        .collection('enrollments')
        .doc(courseId)
        .get();

    return enrollment.exists;
  }
}
