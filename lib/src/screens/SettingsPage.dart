import 'package:flutter/material.dart';

import '../components/CustomBlock.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage>
{
  bool darkModeOn = false;
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  //Data from date picker
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: CustomBlock(
            child: Column(
              children: [
                SizedBox(height:20),
                Text(style: TextStyle(fontSize: 45),'Settings'),
                SizedBox(height:20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.nightlight_outlined),
                    Text(style: TextStyle(fontSize: 20),'Dark mode'),
                    Switch(
                      value: darkModeOn,
                      onChanged: (value) {
                        setState(() {
                          darkModeOn = value;
                        });
                      },)
                  ],),
                SizedBox(height:20),
                ElevatedButton(
                style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => _popUp());
                },
                child: const Text('Export raport'),
                )
              ],
            )
          )
    )
    );
  }

  Widget _popUp() {
    return AlertDialog(
      title: Text('Export raport'),
      content: Column(
        children: [
          SizedBox(height:20),
          Text('Choose start and end dates'),
          SizedBox(height:20),
          _datePicker(true),
          SizedBox(height:20),
          _datePicker(false),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Export'))
      ],
    );
  }

  Widget _datePicker(bool start) {
    return   TextField(
      controller: start?_startDateController:_endDateController,
      decoration: InputDecoration(
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
    if(_picked != null){
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
}