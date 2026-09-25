import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../services/contact_sync_service.dart';

// State class to hold all contact sync data
class ContactSyncState {
  final List<RegisteredUser> registeredUsers;
  final List<String> nonRegisteredUsers;
  final List<Contact> allContacts;
  final String searchQuery;
  final List<Contact> filteredContacts;
  final bool isSyncing;
  final bool hasSynced;
  final String? errorMessage;

  ContactSyncState({
    this.registeredUsers = const [],
    this.nonRegisteredUsers = const [],
    this.allContacts = const [],
    this.searchQuery = '',
    this.filteredContacts = const [],
    this.isSyncing = false,
    this.hasSynced = false,
    this.errorMessage,
  });

  ContactSyncState copyWith({
    List<RegisteredUser>? registeredUsers,
    List<String>? nonRegisteredUsers,
    List<Contact>? allContacts,
    String? searchQuery,
    List<Contact>? filteredContacts,
    bool? isSyncing,
    bool? hasSynced,
    String? errorMessage,
  }) {
    return ContactSyncState(
      registeredUsers: registeredUsers ?? this.registeredUsers,
      nonRegisteredUsers: nonRegisteredUsers ?? this.nonRegisteredUsers,
      allContacts: allContacts ?? this.allContacts,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      isSyncing: isSyncing ?? this.isSyncing,
      hasSynced: hasSynced ?? this.hasSynced,
      errorMessage: errorMessage,
    );
  }
}

// StateNotifier for managing contact sync logic
class ContactSyncNotifier extends StateNotifier<ContactSyncState> {
  final ContactSyncService _contactSyncService;

  ContactSyncNotifier(this._contactSyncService) : super(ContactSyncState());

  /// Set all contacts (called from ContactsListScreen)
  void setAllContacts(List<Contact> contacts) {
    final sortedContacts = _sortContactsByRegistrationStatus(contacts);
    state = state.copyWith(
      allContacts: sortedContacts,
      filteredContacts: sortedContacts,
    );
  }

  /// Sort contacts so registered users appear first
  List<Contact> _sortContactsByRegistrationStatus(List<Contact> contacts) {
    Set<String> registeredPhones = state.registeredUsers
        .map((user) => user.phone)
        .toSet();

    List<Contact> registeredContacts = [];
    List<Contact> nonRegisteredContacts = [];

    for (var contact in contacts) {
      bool isRegistered = false;

      if (contact.phones.isNotEmpty) {
        for (var phone in contact.phones) {
          String standardized = _contactSyncService.standardizePhoneNumber(
            phone.number,
          );
          if (registeredPhones.contains(standardized)) {
            isRegistered = true;
            break;
          }
        }
      }

      if (isRegistered) {
        registeredContacts.add(contact);
      } else {
        nonRegisteredContacts.add(contact);
      }
    }

    registeredContacts.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    nonRegisteredContacts.sort(
      (a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );

    return [...registeredContacts, ...nonRegisteredContacts];
  }

  /// Update search query and filter contacts
  void updateSearchQuery(String query) {
    final searchQuery = query.toLowerCase();

    if (searchQuery.isEmpty) {
      state = state.copyWith(
        searchQuery: searchQuery,
        filteredContacts: state.allContacts,
      );
    } else {
      final filtered = state.allContacts.where((contact) {
        final name = contact.displayName.toLowerCase();
        final phoneMatches = contact.phones.any(
          (phone) => phone.number
              .replaceAll(RegExp(r'[^\d+]'), '')
              .contains(searchQuery),
        );
        return name.contains(searchQuery) || phoneMatches;
      }).toList();

      state = state.copyWith(
        searchQuery: searchQuery,
        filteredContacts: filtered,
      );
    }
  }

  /// Clear search
  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      filteredContacts: state.allContacts,
    );
  }

  /// Perform contact sync
  Future<void> syncContacts() async {
    debugPrint('🔄 ContactSyncNotifier: Starting sync...');
    // Don't reset errorMessage if we have cached users — avoids flash of error
    state = state.copyWith(isSyncing: true, errorMessage: null);

    try {
      print('🔄 ContactSyncNotifier: Calling performFullContactSync...');
      ContactSyncResponse response = await _contactSyncService
          .performFullContactSync();

      print('🔄 ContactSyncNotifier: Got response');
      print(
        '🔄 ContactSyncNotifier: Registered users count: ${response.registeredUsers.length}',
      );
      print(
        '🔄 ContactSyncNotifier: Non-registered users count: ${response.nonRegisteredUsers.length}',
      );

      final sortedContacts = _sortContactsByRegistrationStatus(
        state.allContacts,
      );

      final filteredContacts = state.searchQuery.isEmpty
          ? sortedContacts
          : sortedContacts.where((contact) {
              final name = contact.displayName.toLowerCase();
              final phoneMatches = contact.phones.any(
                (phone) => phone.number
                    .replaceAll(RegExp(r'[^\d+]'), '')
                    .contains(state.searchQuery),
              );
              return name.contains(state.searchQuery) || phoneMatches;
            }).toList();

      state = state.copyWith(
        registeredUsers: response.registeredUsers,
        nonRegisteredUsers: response.nonRegisteredUsers,
        hasSynced: true,
        errorMessage: null,
        isSyncing: false,
        allContacts: sortedContacts,
        filteredContacts: filteredContacts,
      );

      print('✅ ContactSyncNotifier: Sync completed successfully');
      print('✅ Stored ${state.registeredUsers.length} registered users');
      print('✅ Stored ${state.nonRegisteredUsers.length} non-registered users');
    } catch (e, stackTrace) {
      debugPrint('❌ Contact sync error in notifier: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      // ✅ Keep existing users — don't wipe cached data on network failure
      // This means if user had contacts before, they still show while offline
      state = state.copyWith(
        errorMessage: state.registeredUsers.isEmpty ? e.toString() : null,
        hasSynced: false,
        isSyncing: false,
      );
    }
  }

  /// Inject cached registered users so screen renders instantly without network.
  /// Called before syncContacts() so the UI is populated from cache first.
  void injectCachedUsers(List<RegisteredUser> users) {
    if (users.isEmpty) return;
    final sortedContacts = _sortContactsByRegistrationStatus(state.allContacts);
    state = state.copyWith(
      registeredUsers: users,
      allContacts: sortedContacts,
      filteredContacts: sortedContacts,
      hasSynced: false, // still needs a real sync
    );
    debugPrint('✅ injectCachedUsers: injected ${users.length} users');
  }

  /// Clear sync data
  void clearSyncData() {
    debugPrint('🗑️ ContactSyncNotifier: Clearing sync data');
    state = state.copyWith(
      registeredUsers: [],
      nonRegisteredUsers: [],
      hasSynced: false,
      errorMessage: null,
    );
  }
}

// Provider for ContactSyncService
final contactSyncServiceProvider = Provider<ContactSyncService>((ref) {
  return ContactSyncService();
});

// Provider for ContactSyncNotifier
final contactSyncProvider =
    StateNotifierProvider<ContactSyncNotifier, ContactSyncState>((ref) {
      final service = ref.watch(contactSyncServiceProvider);
      return ContactSyncNotifier(service);
    });
