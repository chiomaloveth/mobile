class Contact {
  final String name;
  final String avatarUrl;
  bool isSelected;

  Contact({required this.name, required this.avatarUrl, this.isSelected = false});
}

class GroupData {
  String name = '';
  double amount = 0.0;
  String frequency = 'Monthly';
  int memberCount = 3;
  DateTime startDate = DateTime.now().add(const Duration(days: 30));
  List<Contact> selectedMembers = [];
  List<String> payoutOrder = [];

  double get totalPool => amount * memberCount;
}

final List<Contact> dummyContacts = [
  Contact(name: 'Abigail', avatarUrl: 'https://i.pravatar.cc/150?u=1'),
  Contact(name: 'Adedayo', avatarUrl: 'https://i.pravatar.cc/150?u=2'),
  Contact(name: 'Adejare', avatarUrl: 'https://i.pravatar.cc/150?u=3'),
  Contact(name: 'Ajayi', avatarUrl: 'https://i.pravatar.cc/150?u=4'),
  Contact(name: 'Anothonia ❣', avatarUrl: 'https://i.pravatar.cc/150?u=5'),
  Contact(name: 'Anothony', avatarUrl: 'https://i.pravatar.cc/150?u=6'),
  Contact(name: 'Bayo', avatarUrl: 'https://i.pravatar.cc/150?u=7'),
  Contact(name: 'Barakat', avatarUrl: 'https://i.pravatar.cc/150?u=8'),
  Contact(name: 'Brandie', avatarUrl: 'https://i.pravatar.cc/150?u=9'),
  Contact(name: 'Cooper', avatarUrl: 'https://i.pravatar.cc/150?u=10'),
];

final List<Contact> freqContacts = [
  Contact(name: 'Blessing', avatarUrl: 'https://i.pravatar.cc/150?u=11'),
  Contact(name: 'Daniel', avatarUrl: 'https://i.pravatar.cc/150?u=12'),
  Contact(name: 'Michael', avatarUrl: 'https://i.pravatar.cc/150?u=13'),
  Contact(name: 'Jumoke', avatarUrl: 'https://i.pravatar.cc/150?u=14'),
];