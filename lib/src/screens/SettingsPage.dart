import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moodify/src/components/PageTemplate.dart';
import 'package:moodify/src/screens/AuthPage.dart';
import 'package:moodify/src/services/ReportService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/CustomBlock.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage>
{
  bool darkModeOn = false;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  //Data from date picker
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  bool _startDateError = false;
  bool _endDateError = false;

Future<void> _logout() async {
  try {
    await Supabase.instance.client.auth.signOut();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthPage()),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Widget _buildLogoutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        
        if (confirm == true) {
          await _logout();
        }
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.logout, color: Colors.white),
          SizedBox(width: 10),
          Text('Sign Out', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      CustomBlock(
          child: Column(
        children: [
          PageTemplate.buildPageTitle("Settings"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 16),
              const SizedBox(width: 8),
              Text(
                Supabase.instance.client.auth.currentUser?.email ?? 'Not logged in',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.nightlight_outlined),
              const Text(style: TextStyle(fontSize: 20), 'Dark mode'),
              Switch(
                value: darkModeOn,
                onChanged: (value) {
                  setState(() {
                    darkModeOn = value;
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20)),
            onPressed: () {
              showDialog(context: context, builder: (context) => _popUp());
            },
            child: const Text('Export report'),
          ),
          const SizedBox(height: 20),
          _buildLogoutButton(), // Dodany przycisk wylogowania
        ],
      )),
      PageTemplate.buildBottomSpacing(context)
    ]);
  }

  Widget _popUp() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter dialogSetState) {
        return AlertDialog(
        title: Text('Export report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose start and end dates'),
            SizedBox(height:20),
            _datePicker(true),
            SizedBox(height:20),
            _datePicker(false),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {Navigator.pop(context); _resetDialog();},
              child: Text('Cancel')),
          TextButton(
              onPressed: () => _validateDialog(context, dialogSetState),
              child: Text('Export'))
        ],
      );
      });
  }

  void _resetDialog()
  {
    _startDateError = false;
    _endDateError = false;
    _startDateController.text = '';
    _endDateController.text = 'TODAY';
  }


  void _validateDialog(BuildContext context, StateSetter dialogSetState)
  {
    if (_endDate.difference(_startDate).inDays <= 0)
    {
      log("Invalid date");
      // Invalid period entered
      dialogSetState(() {
        _startDateError = true;
      });
      return;
    }
    else if(_endDate.isAfter(DateTime.now()) && _startDate.isAfter(DateTime.now()))
    {
      log("Invalid date");
      // Invalid period entered
      dialogSetState(() {
        _startDateError = true;
        _endDateError = true;
      });
      return;
    }
    else if(_startDate.isAfter(DateTime.now()))
    {
      log("Invalid date");
      // Invalid period entered
      dialogSetState(() {
        _startDateError = true;
      });
      return;
    }

    Navigator.pop(context);
    _exportRaport();
    _resetDialog();
  }

  void _exportRaport() async
  {
    //Snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(days: 1),
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Generating report...'),
          ],
        ))
    );

    // Generate report
    final ReportService reportService = ReportService();
    reportService.init(_startDate, _endDate);

    // Check result
    final bool success = await reportService.saveReport() == 0;

    ScaffoldMessenger.of(context).clearSnackBars();

    // Display success snack bar
    if(success)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 20),
              Text('Report generated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2)
         )
      );
      return;
    }

    // Display success task bar
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(Icons.close, color: Colors.white),
              SizedBox(width: 20),
              Text('Report generation failed!'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2)
         )
      );
  }

  Widget _datePicker(bool start) {
    return   TextField(
      controller: start?_startDateController:_endDateController,
      decoration: InputDecoration(
        errorText: start ? (_startDateError ? 'Invalid date' : null) : (_endDateError ? 'Invalid date' : null),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent)
        ),
        labelText: start?'START DATE':'END DATE',
        filled: true,
        prefixIcon: Icon(Icons.calendar_today_outlined),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      readOnly: true,
      onTap: (){
        _selectDate(start?true:false);
      },
    );
  }

  Future<void> _selectDate(bool start) async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100)
    );
    if(_picked == null){
      return;
    }
    if (start) {
      _startDate = _picked;
      setState(() {
        _startDateController.text = _picked.toString().split(" ")[0];
      });
    } else {
      _endDate = _picked;
      setState(() {
        _endDateController.text = _picked.toString().split(" ")[0];
      });

    }
  }
}