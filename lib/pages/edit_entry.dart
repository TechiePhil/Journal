import 'package:flutter/material.dart';
import '../classes/database.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// this page contains the functionality to edit existing journal entries
class EditEntry extends StatefulWidget {
  final bool add;
  final int index;
  final JournalEdit journalEdit;
  
  const EditEntry({
    Key key, this.add, this.index, this.journalEdit}): super(key:key);
  
  @override
  _EditEntryState createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  JournalEdit _journalEdit;
  String _title;
  DateTime _selectedDate;
  // mood text controller
  TextEditingController _moodController = TextEditingController();
  // note text controller
  TextEditingController _noteController = TextEditingController();
  FocusNode _moodFocus = FocusNode();
  FocusNode _noteFocus = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // initialize journal to edit
    _journalEdit = JournalEdit(
      action: 'Cancel',
      journal: widget.journalEdit.journal
    );
    _title = widget.add ? 'Add' : 'Edit';
    _journalEdit.journal = widget.journalEdit.journal;
    
    // if the aciton is to add new entry, create a new journal
    // otherwise, edit the selected journal entry.
    if (widget.add) {
      _selectedDate = DateTime.now();
      _moodController.text = '';
      _noteController.text = '';
    }
    else {
      _selectedDate = DateTime.parse(_journalEdit.journal.date);
      _moodController.text = _journalEdit.journal.mood;
      _noteController.text = _journalEdit.journal.note;
    }
  }
  
  @override
  void dispose() {
    // destroy these object after completed the necessary action
    _moodController.dispose();
    _noteController.dispose();
    _moodFocus.dispose();
    _noteFocus.dispose();
    
    super.dispose();
  }
  
  // date picker
  Future<DateTime> _selectDate(DateTime selectedDate) async {
    DateTime _initialDate = selectedDate;
    final DateTime _pickedDate = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 356))
    );
    
    if (_pickedDate != null) {
      // initialize a data object
      selectedDate = DateTime(
        _pickedDate.year,
        _pickedDate.month,
        _pickedDate.day,
        _pickedDate.hour,
        _pickedDate.minute,
        _pickedDate.second,
        _pickedDate.millisecond,
        _pickedDate.microsecond
      );
    }
    // return data object
    return selectedDate;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('$_title Entry'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextButton(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                      size: 22,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 16),
                    Text(
                      DateFormat.yMMMEd().format(_selectedDate),
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black54,
                    ),
                  ]
                ),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime _pickerDate = await _selectDate(_selectedDate);
                  setState(() {
                    _selectedDate = _pickerDate;
                  });
                }
              ),
              TextField(
                controller: _moodController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                focusNode: _moodFocus,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Mood',
                  icon: Icon(Icons.mood),
                ),
                onSubmitted: (submitted) {
                  FocusScope.of(context).requestFocus(_noteFocus);
                }
              ),
              TextField(
                controller: _noteController,
                autofocus: true,
                textInputAction: TextInputAction.newline,
                focusNode: _noteFocus,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Note',
                  icon: Icon(Icons.subject),
                ),
                maxLines: null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  CancelButtonWidget(journalEdit: _journalEdit),
                  SizedBox(width: 8),
                  SaveButtonWidget(
                    journalEdit: _journalEdit,
                    widget: widget,
                    selectedDate: _selectedDate,
                    moodController: _moodController,
                    noteController: _noteController
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
}

// a save button widget, refactored for the purpose of achieving a
// 'cleaner' code with less widget subtrees.
class SaveButtonWidget extends StatelessWidget {
  const SaveButtonWidget({
    Key key,
    @required JournalEdit journalEdit,
    @required this.widget,
    @required DateTime selectedDate,
    @required TextEditingController moodController,
    @required TextEditingController noteController,
  }) : 
    _journalEdit = journalEdit,
    _selectedDate = selectedDate,
    _moodController = moodController,
    _noteController = noteController,
    super(key: key);

  final JournalEdit _journalEdit;
  final EditEntry widget;
  final DateTime _selectedDate;
  final TextEditingController _moodController;
  final TextEditingController _noteController;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text('Save'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.lightGreen.shade100),
      ),
      onPressed: () {
        _journalEdit.action = 'Save';
        
        String _id = widget.add ? 
          Random().nextInt(99999999).toString()
          : _journalEdit.journal.id;
          
          _journalEdit.journal = Journal(
            id: _id,
            date: _selectedDate.toString(),
            mood: _moodController.text,
            note: _noteController.text,
          );
        Navigator.pop(context, _journalEdit);
      }
    );
  }
}

// cancel button widget refactored
class CancelButtonWidget extends StatelessWidget {
  const CancelButtonWidget({
    Key key,
    @required JournalEdit journalEdit,
  }) : _journalEdit = journalEdit, super(key: key);

  final JournalEdit _journalEdit;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text('Cancel'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey.shade100),
      ),
      onPressed: () {
        _journalEdit.action = 'Cancel';
        Navigator.pop(context, _journalEdit);
      }
    );
  }
}