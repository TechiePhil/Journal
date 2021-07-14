import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

// this classes in this file handles all the data persistent activities

// utility class to read from and to persist data on the local device storage
// also for encoding and decoding json strings accordingly.
class DatabaseFileRoutines {
  // get local directory
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    return directory.path;
  }
  
  // retrieve local file from the device
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }
  
  // read all previously saved journal entries
  Future<String> readJournals() async {
    String contents = "";
    try {
      final file = await _localFile;
      // if no file has been created it means no journal entries exist yet.
      // create an empty json file for the journal entries.
      if (!file.existsSync()) {
        print('file does not exists: ${file.absolute}');
        await writeJournals('{"journals": []}');
      }
      
      // read the file
      contents = await file.readAsString();
      return contents;
    }
    catch (error) {
      print('error reading journals: $error');
      return contents;
    }
  }
  
  // persist encoded journal entry as json string.
  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    // write to file
    return file.writeAsString('$json');
  }
}

// read and decode the json journal string from the local storage.
// store all journal entry in a database object for easy access.
Database databaseFromJson(String string) {
  final dataFromJson = jsonDecode(string);
  return Database.fromJson(dataFromJson);
}

// convert the database to a json string
// and make it ready for persistence.
String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  return jsonEncode(dataToJson);
}

// class to represent the database object,
// where all journal entries are stored.
class Database {
  List<Journal> journal;
  Database({this.journal,});
  
  // parse the json string into a list of journal entries.
  factory Database.fromJson(Map<String, dynamic> json) {
    return Database(
      journal: List<Journal>.from(json['journals'].map((value) {
        return Journal.fromJson(value);
      }))
    );
  }

  // convert the journal list into a json string.
  Map<String, dynamic> toJson() {
    return {
      'journals': List<dynamic>.from(journal.map((value) {
          return value.toJson();
        })
      ),
    };
  }
}

// journal object.
class Journal {
  String id;
  String mood;
  String date;
  String note;
  
  Journal({this.id, this.mood, this.date, this.note});
  
  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
    id: json['id'],
    date: json['date'],
    mood: json['mood'],
    note: json['note']
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'mood': mood,
    'note': note
  };
}

// class to determine if a new journal should be add
// or an existing journal should be modified.
// basically an action model.
class JournalEdit {
  String action;
  Journal journal;
  
  JournalEdit({this.action, this.journal});
}