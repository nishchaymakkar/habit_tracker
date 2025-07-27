import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:provider/provider.dart';

import '../model/habit.dart';
import '../model/habit_database.dart';
import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {

    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();


  }

  final TextEditingController textController = TextEditingController();
  // create new Habit
  void  createNewHabit()  {
    showDialog(context: context, builder: (context) => AlertDialog(
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(
          hintText: "Create a new habit!",
        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          String newHabitName = textController.text;
          context.read<HabitDatabase>().addHabit(Habit()..name = newHabitName);
          Navigator.pop(context);
          textController.clear();
        },child: const Text("save"),),
        MaterialButton(onPressed: (){
          Navigator.pop(context);
          textController.clear();
        },child: const Text("cancel"),)
      ],
    ) );
  }

  void checkHabitOnOff(bool? value,Habit habit){
    if(value != null){
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }
  void editHabit(Habit habit){
    textController.text = habit.name;
    showDialog(context: context, builder: (context) => AlertDialog(
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(
          hintText: "Edit habit name!",
        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          String newHabitName = textController.text;
          context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);
          Navigator.pop(context);
          textController.clear();
        },child: const Text("save"),),
        MaterialButton(onPressed: (){
          Navigator.pop(context);
          textController.clear();
        },child: const Text("cancel"),)
      ],
    ));
  }
  void deleteHabit(Habit habit){
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('Are you sure you want to delete?'),
      actions: [
        MaterialButton(onPressed: (){
          context.read<HabitDatabase>().deleteHabit(habit.id);
          Navigator.pop(context);
        },child: const Text("delete"),),
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },child: const Text("cancel"),)
      ],
    ));

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(Icons.add,color: Theme.of(context).colorScheme.inversePrimary,),
      ),
      body: ListView(
        children: [
         _buildHeatMap(),
          _buildHabitList()
        ],
      ),
    );
  }

  Widget _buildHabitList(){
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final habit = currentHabits[index];

        bool isCompletedToday = isHabitCompletedToday(habit.completedDates);

        return MyHabitTile(
            isCompleted: isCompletedToday,
            text: habit.name,
            editHabit: (context) => editHabit(habit),
            deleteHabit: (context) => deleteHabit(habit),
            onChanged: (value)=> checkHabitOnOff(value,habit));
    },);
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;
    
    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context,snapshot){
          if(snapshot.hasData) {
            return MyHeatMap(startDate:snapshot.data!,
                datasets: prepareHeatMapDataset(currentHabits));
          } else {
            return Container();
          }
        }
    ) ;
  }
}
