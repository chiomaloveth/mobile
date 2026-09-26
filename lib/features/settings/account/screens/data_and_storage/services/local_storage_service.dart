import 'package:hive_ce/hive.dart';
part 'local_storage_service.g.dart';

@HiveType(typeId: 30)
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String content;
  @HiveField(2)
  final int timestamp;
  @HiveField(3)
  final int sizeInBytes;

  MessageModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.sizeInBytes,
  });
}

@HiveType(typeId: 31)
class MediaModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String filePath;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final int sizeInBytes;

  MediaModel({
    required this.id,
    required this.filePath,
    required this.type,
    required this.sizeInBytes,
  });
}

@HiveType(typeId: 32)
class DocumentModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String filePath;
  @HiveField(2)
  final int sizeInBytes;

  DocumentModel({
    required this.id,
    required this.filePath,
    required this.sizeInBytes,
  });
}

@HiveType(typeId: 33)
class NetworkStatsModel extends HiveObject {
  @HiveField(0)
  int sentBytes;
  @HiveField(1)
  int receivedBytes;

  NetworkStatsModel({this.sentBytes = 0, this.receivedBytes = 0});
}

class DBService {
  static const String boxMessages = "messages_box";
  static const String boxMedia = "media_box";
  static const String boxDocs = "documents_box";
  static const String boxStats = "stats_box";
  static const String boxSettings = "settings_box";

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(30))
      Hive.registerAdapter(MessageModelAdapter());
    if (!Hive.isAdapterRegistered(31))
      Hive.registerAdapter(MediaModelAdapter());
    if (!Hive.isAdapterRegistered(32))
      Hive.registerAdapter(DocumentModelAdapter());
    if (!Hive.isAdapterRegistered(33))
      Hive.registerAdapter(NetworkStatsModelAdapter());

    await Hive.openBox<MessageModel>(boxMessages);
    await Hive.openBox<MediaModel>(boxMedia);
    await Hive.openBox<DocumentModel>(boxDocs);
    await Hive.openBox<NetworkStatsModel>(boxStats);
    await Hive.openBox(boxSettings);
  }

  static Box<MessageModel> get messages => Hive.box<MessageModel>(boxMessages);
  static Box<MediaModel> get media => Hive.box<MediaModel>(boxMedia);
  static Box<DocumentModel> get docs => Hive.box<DocumentModel>(boxDocs);

  static Box<NetworkStatsModel> get stats {
    final box = Hive.box<NetworkStatsModel>(boxStats);
    if (box.isEmpty) {
      box.put('usage', NetworkStatsModel());
    }
    return box;
  }

  static Box get settings => Hive.box(boxSettings);
}
