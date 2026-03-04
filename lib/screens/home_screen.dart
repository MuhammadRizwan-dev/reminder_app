import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/reminder_model.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController reminderController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  List<Reminder> reminderList = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void dispose() {
    reminderController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Halka sa grey background modern lagta hai
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- TOP PURPLE CONTAINER ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 60.h, left: 20.w, right: 20.w, bottom: 50.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome!", style: TextStyle(color: Colors.white70, fontSize: 16.sp)),
                  SizedBox(height: 5.h),
                  Text(
                    "My Reminders",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // --- INPUT FORM (TRANSFORMED TO OVERLAP) ---
            Transform.translate(
              offset: Offset(0, -30.h), // Ye form ko purple ke upar move karega
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: reminderController,
                            validator: (value) => value == null || value.isEmpty ? "Required" : null,
                            decoration: InputDecoration(
                              labelText: "What to remind?",
                              prefixIcon: Icon(Icons.alarm, size: 22.sp),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: dateController,
                            readOnly: true,
                            validator: (value) => value == null || value.isEmpty ? "Required" : null,
                            decoration: InputDecoration(
                              labelText: "Select Date",
                              prefixIcon: Icon(Icons.calendar_today, size: 22.sp),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            onTap: () async {
                              DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setState(() {
                                  selectedDate = date;
                                  dateController.text = "${date.day}-${date.month}-${date.year}";
                                });
                              }
                            },
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: timeController,
                            readOnly: true,
                            validator: (value) => value == null || value.isEmpty ? "Required" : null,
                            decoration: InputDecoration(
                              labelText: "Select Time",
                              prefixIcon: Icon(CupertinoIcons.time, size: 22.sp),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            onTap: () async {
                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  selectedTime = time;
                                  timeController.text = time.format(context);
                                });
                              }
                            },
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate() && selectedDate != null && selectedTime != null) {
                                  final finalTime = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, selectedTime!.hour, selectedTime!.minute);

                                  NotificationService.showInstantNotification("Reminder Set", "Title: ${reminderController.text}");
                                  NotificationService.scheduleNotification(DateTime.now().millisecond, "Reminder", reminderController.text, finalTime);

                                  setState(() {
                                    reminderList.add(Reminder(title: reminderController.text, date: dateController.text, time: timeController.text));
                                  });

                                  reminderController.clear();
                                  dateController.clear();
                                  timeController.clear();
                                  selectedDate = null;
                                  selectedTime = null;
                                }
                              },
                              child: Text("Set Reminder", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- LIST SECTION ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Scheduled Tasks", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 10.h),
                  reminderList.isEmpty
                      ? Center(child: Text("No reminders yet", style: TextStyle(color: Colors.grey, fontSize: 14.sp)))
                      : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reminderList.length,
                    itemBuilder: (context, index) {
                      final reminder = reminderList[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 10.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.withOpacity(0.1),
                            child: Icon(Icons.notifications_active, color: Colors.deepPurple, size: 20.sp),
                          ),
                          title: Text(reminder.title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                          subtitle: Text("${reminder.date} | ${reminder.time}", style: TextStyle(fontSize: 12.sp)),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}