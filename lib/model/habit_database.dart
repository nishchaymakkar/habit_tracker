import 'dart:async';

import 'package:flutter/material.dart';
import 'package:habit_tracker/model/app_settings.dart';
import 'package:habit_tracker/model/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier{

  static late Isar isar;


  /*
  * SETUP
  */


// Initialize the database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([HabitSchema,AppSettingsSchema],directory: dir.path );
  }
  // save the first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if(existingSettings == null){
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));

    }
  }
// Get the first date of app startup (for heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }
/*
* CRUD Operations
*/

// Lists of habits
  final List<Habit> currentHabits=[];
// CREATE add new habit
  Future<void> addHabit(Habit habit) async {
    final newhabit = Habit()..name = habit.name;

    await isar.writeTxn(() => isar.habits.put(newhabit));

    readHabits();
  }
// READ  read saved habits from db
  Future<void> readHabits() async {
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    notifyListeners();
  }
// UPDATE check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);
    if(habit != null){
      await isar.writeTxn(() async {
          //if habit is completed -> add current the current date to the completed list

        if(isCompleted && !habit.completedDates.contains(DateTime.now())){
          final today = DateTime.now();
          habit.completedDates.add(
            DateTime(
              today.year,
              today.month,
              today.day
            )
          );
        } else {
          habit.completedDates.removeWhere((date)=>
          date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day
          );
        }
        await isar.habits.put(habit);
      });
    }
    readHabits();
  }
// UPDATE edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    final habit = await isar.habits.get(id);

    if(habit != null){
      await isar.writeTxn(() async {
        habit.name = newName;
        await isar.habits.put(habit);
      });

    }
    readHabits();
  }
// DELETE delete habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    readHabits();

  }

}