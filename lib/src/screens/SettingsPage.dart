import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moodify/src/components/PageTemplate.dart';
import 'package:moodify/src/services/ReportService.dart';

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


  @override
  Widget build(BuildContext context) {
    return PageTemplate(children: [
      CustomBlock(
          child: Column(
        children: [
          PageTemplate.buildPageTitle("Settings"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nightlight_outlined),
              Text(style: TextStyle(fontSize: 20), 'Dark mode'),
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
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20)),
            onPressed: () {
              showDialog(context: context, builder: (context) => _popUp());
            },
            child: const Text('Export report'),
          )
        ],
      )),
      PageTemplate.buildBottomSpacing(context)
    ]);
  }

  Widget _popUp() {
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
            onPressed: () => _validateDialog(context),
            child: Text('Export'))
      ],
    );
  }

  void _resetDialog()
  {
    _startDateError = false;
    _endDateError = false;
    _startDateController.text = 'START DATE';
    _endDateController.text = 'END DATE';
  }


  void _validateDialog(BuildContext context)
  {
    if (_endDate.difference(_startDate).inDays <= 0)
    {
      log("Invalid date");
      // Invalid period entered
      setState(() { // TODO: For some weird reason, this doesn't refresh the dialog
        _endDateError = true;
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