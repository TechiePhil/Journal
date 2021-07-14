import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    return directory.path;
  }
  
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/local_persistence.json');
  }
  
  Future<String> readJournals() async {
    String contents = "";
    try {
      final file = await _localFile;
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
  
  Future<File> writeJournals(String json) async {
    final file = await _localFile;
    // write to file
    return file.writeAsString('$json');
  }
}

Database databaseFromJson(String string) {
  final dataFromJson = jsonDecode(string);
  return Database.fromJson(dataFromJson);
}

String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  return jsonEncode(dataToJson);
}

class Database {
  List<Journal> journal;
  Database({this.journal,});
  
  factory Database.fromJson(Map<String, dynamic> json) {
    return Database(
      journal: List<Journal>.from(json['journals'].map((value) {
        return Journal.fromJson(value);
      }))
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'journals': List<dynamic>.from(journal.map((value) {
          return value.toJson();
        })
      ),
    };
  }
}

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

class JournalEdit {
  String action;
  Journal journal;
  
  JournalEdit({this.action, this.journal});
}