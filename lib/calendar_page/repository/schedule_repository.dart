import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kumoh_calendar/data/schedule_data.dart';
import 'package:kumoh_calendar/data/school_schedule_data.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userId = "";

  // 싱글톤 인스턴스
  static final ScheduleRepository _instance = ScheduleRepository._internal();

  // private named constructor
  ScheduleRepository._internal();

  // factory constructor
  factory ScheduleRepository() {
    return _instance;
  }

  void setUserId(String userId) {
    this.userId = userId;
  }

  Future<List<ScheduleData>> fetchSchedules() async {
    final querySnapshot = await _firestore
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => ScheduleData.fromJson(doc.data()))
        .toList();
  }

  Future<List<ScheduleData>> fetchAcademicSchedules() async {
    final querySnapshot = await _firestore.collection('school_schedules').get();

    return querySnapshot.docs
        .map(
            (doc) => AcademicScheduleData.fromJson(doc.data()).toScheduleData())
        .toList();
  }

  // get schedule by id
  Future<ScheduleData> fetchScheduleById(int id) async {
    final querySnapshot = await _firestore
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .where('id', isEqualTo: id)
        .get();

    return querySnapshot.docs
        .map((doc) => ScheduleData.fromJson(doc.data()))
        .first;
  }

  // add schedule
  Future<void> addSchedule(ScheduleData schedule) async {
    await _firestore.collection('schedules').add(schedule.toJson());
  }

  // edit schedule
  Future<void> editSchedule(ScheduleData schedule) async {
    var target = await _firestore
        .collection('schedules')
        .where('id', isEqualTo: schedule.id)
        .get();
    target.docs.first.reference.update(schedule.toJson());
  }

  // delete schedule
  Future<void> deleteSchedule(int id) async {
    var target = await _firestore
        .collection('schedules')
        .where('id', isEqualTo: id)
        .get();
    target.docs.first.reference.delete();
  }

  // stream onScheduleChanged only my schedule
  Stream<ScheduleData> get onScheduleChanged {
    return _firestore.collection('schedules').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => ScheduleData.fromJson(doc.data()))
            .firstWhere((schedule) => schedule.userId == userId));
  }
}
