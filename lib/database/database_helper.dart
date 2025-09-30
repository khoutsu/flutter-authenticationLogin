import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'student_activities.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL UNIQUE,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        program TEXT NOT NULL,
        activity_name TEXT NOT NULL,
        registration_date TEXT NOT NULL,
        user_email TEXT NOT NULL
      )
    ''');
  }

  // เพิ่มข้อมูลนักศึกษา
  Future<int> insertStudent(Student student) async {
    final db = await database;
    try {
      return await db.insert('students', student.toMap());
    } catch (e) {
      throw Exception('ไม่สามารถบันทึกข้อมูลได้: ${e.toString()}');
    }
  }

  // ดึงข้อมูลนักศึกษาทั้งหมดของผู้ใช้คนนั้น
  Future<List<Student>> getStudentsByUser(String userEmail) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'user_email = ?',
      whereArgs: [userEmail],
      orderBy: 'registration_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // ดึงข้อมูลนักศึกษาทั้งหมด (สำหรับ admin)
  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      orderBy: 'registration_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // ค้นหานักศึกษาตามกิจกรรม
  Future<List<Student>> getStudentsByActivity(
    String activityName,
    String userEmail,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'activity_name = ? AND user_email = ?',
      whereArgs: [activityName, userEmail],
      orderBy: 'registration_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  // ตรวจสอบว่านักศึกษาลงทะเบียนกิจกรรมนี้แล้วหรือไม่
  Future<bool> isStudentRegistered(
    String studentId,
    String activityName,
    String userEmail,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'students',
      where: 'student_id = ? AND activity_name = ? AND user_email = ?',
      whereArgs: [studentId, activityName, userEmail],
    );
    return result.isNotEmpty;
  }

  // ลบข้อมูลนักศึกษา
  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // อัปเดตข้อมูลนักศึกษา
  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // นับจำนวนนักศึกษาในกิจกรรม
  Future<int> getStudentCountByActivity(
    String activityName,
    String userEmail,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM students WHERE activity_name = ? AND user_email = ?',
      [activityName, userEmail],
    );
    return result.first['count'] as int;
  }

  // ดึงรายชื่อกิจกรรมทั้งหมดของผู้ใช้
  Future<List<String>> getActivitiesByUser(String userEmail) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT DISTINCT activity_name FROM students WHERE user_email = ? ORDER BY activity_name',
      [userEmail],
    );
    return result.map((row) => row['activity_name'] as String).toList();
  }

  // ลบฐานข้อมูล (สำหรับ testing)
  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'student_activities.db');
    await deleteDatabase(path);
    _database = null;
  }
}
