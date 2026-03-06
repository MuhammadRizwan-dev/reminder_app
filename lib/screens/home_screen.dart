import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/reminder_model.dart';
import '../tools/database_helper.dart';
import '../tools/notification_service.dart';

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
  static const Color premiumGold = Color(0xFFD4AF37);
  static const Color premiumBlack = Color(0xFF1A1A1A);
  static const Color lightCream = Color(0xFFF5F5F0);
  void _loadData() async {
    final data = await DatabaseHelper.instance.fetchReminders();
    setState(() {
      reminderList = data
          .map(
            (item) => Reminder(
              id: item['id'],
              title: item['title'],
              date: item['date'],
              time: item['time'] ?? "",
            ),
          )
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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
      backgroundColor: lightCream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: 60.h,
                left: 20.w,
                right: 20.w,
                bottom: 50.h,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [premiumBlack, Color(0xFF333333)],
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
                  Text(
                    "Welcome!",
                    style: TextStyle(color: premiumGold, fontSize: 16.sp),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "My Reminders",
                    style: TextStyle(
                      color: premiumGold,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -30.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: reminderController,cursorColor: premiumGold,
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : null,
                            decoration: InputDecoration(
                              labelText: "What to remind?",
                              labelStyle: TextStyle(color: premiumBlack.withOpacity(0.6)),
                              prefixIcon: Icon(Icons.alarm,color: premiumGold, size: 22.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: premiumGold, width: 2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: dateController,
                            cursorColor: premiumGold,
                            readOnly: true,
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : null,
                            decoration: InputDecoration(
                              labelText: "Select Date",
                              prefixIcon: Icon(
                                Icons.calendar_today,color: premiumGold,
                                size: 22.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
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
                                  dateController.text =
                                      "${date.day}-${date.month}-${date.year}";
                                });
                              }
                            },
                          ),
                          SizedBox(height: 12.h),
                          TextFormField(
                            controller: timeController,
                            cursorColor: premiumGold,
                            readOnly: true,
                            validator: (value) => value == null || value.isEmpty
                                ? "Required"
                                : null,
                            decoration: InputDecoration(
                              labelText: "Select Time",
                              prefixIcon: Icon(
                                CupertinoIcons.time,color: premiumGold,
                                size: 22.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
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
                                backgroundColor: premiumBlack,
                                foregroundColor: premiumGold,
                                elevation: 4,
                                shadowColor: premiumGold.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(color: premiumGold, width: 0.5),
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    selectedDate != null &&
                                    selectedTime != null) {
                                  final finalTime = DateTime(
                                    selectedDate!.year,
                                    selectedDate!.month,
                                    selectedDate!.day,
                                    selectedTime!.hour,
                                    selectedTime!.minute,
                                  );
                                  int id = await DatabaseHelper.instance
                                      .insertReminder(
                                        reminderController.text,
                                        dateController.text,
                                        timeController.text,
                                      );
                                  NotificationService.showInstantNotification(
                                    "Reminder Set",
                                    "Title: ${reminderController.text}",
                                  );
                                  NotificationService.scheduleNotification(
                                    id,
                                    "Reminder",
                                    reminderController.text,
                                    finalTime,
                                  );
                                  _loadData();

                                  reminderController.clear();
                                  dateController.clear();
                                  timeController.clear();
                                  selectedDate = null;
                                  selectedTime = null;
                                }
                              },
                              child: Text(
                                "Set Reminder",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Scheduled Tasks",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  reminderList.isEmpty
                      ? Center(
                          child: Text(
                            "No reminders yet",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reminderList.length,
                          itemBuilder: (context, index) {
                            final reminder = reminderList[index];
                            return Dismissible(
                              key: Key(reminderList[index].id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                margin: EdgeInsets.only(bottom: 10.h),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (direction) async {
                                final messenger = ScaffoldMessenger.of(context);
                                final reminderTitle = reminder.title;
                                await DatabaseHelper.instance.deleteReminder(
                                  reminder.id,
                                );
                                if (!mounted) return;
                                _loadData();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text("$reminderTitle deleted"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              },

                              child: Card(
                                elevation: 0,
                                margin: EdgeInsets.only(bottom: 10.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                  side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: premiumGold
                                        .withValues(alpha: 0.1),
                                    child: Icon(
                                      Icons.notifications_active,
                                      color: premiumGold,
                                      size: 20.sp,
                                    ),
                                  ),
                                  title: Text(
                                    reminder.title,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${reminder.date} | ${reminder.time}",
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.grey,
                                      size: 20.sp,
                                    ),
                                    onPressed: () async {
                                      await DatabaseHelper.instance
                                          .deleteReminder(reminder.id);
                                      _loadData();
                                      setState(() {
                                        reminderList.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
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
