import 'package:flutter/material.dart';

enum BroadcastStatus { sent, scheduled, draft }

enum BroadcastAudience { allUsers, premiumMembers, communityMembers }

class BroadcastList {
  final String id;
  final String name;
  final List<BroadcastMember> members;
  final String? latestMessage;
  final DateTime updatedAt;
  final BroadcastStatus status;
  final DateTime? scheduledAt;
  final BroadcastAudience audience;
  final int? deliveredCount;
  final int? pendingCount;
  final int? totalRecipients;
  final String? creatorId;
  final String? creatorUsername;

  BroadcastList({
    required this.id,
    required this.name,
    required this.members,
    this.latestMessage,
    required this.updatedAt,
    this.status = BroadcastStatus.draft,
    this.scheduledAt,
    this.audience = BroadcastAudience.allUsers,
    this.deliveredCount,
    this.pendingCount,
    this.totalRecipients,
    this.creatorId,
    this.creatorUsername,
  });

  factory BroadcastList.fromJson(Map<String, dynamic> json) {
    // API returns 'members' (GET broadcast) or 'users' (POST create response)
    final rawUsers = (json['members'] ?? json['users']) as List? ?? [];
    final users = rawUsers
        .where((e) => e is Map)
        .map(
          (e) => BroadcastMember.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    debugPrint(
      '🏗️ BroadcastList.fromJson: ${rawUsers.length} raw users, ${users.length} parsed',
    );

    BroadcastStatus status = BroadcastStatus.draft;
    final rawStatus = json['broadcastStatus']?.toString().toLowerCase();
    if (rawStatus == 'sent') status = BroadcastStatus.sent;
    if (rawStatus == 'scheduled') status = BroadcastStatus.scheduled;

    BroadcastAudience audience = BroadcastAudience.allUsers;
    final rawAudience = json['audience']?.toString().toLowerCase();
    if (rawAudience == 'premium') audience = BroadcastAudience.premiumMembers;
    if (rawAudience == 'community') {
      audience = BroadcastAudience.communityMembers;
    }

    // latestMessage can be:
    //  • null / absent
    //  • a plain String ID (new API) — we can't resolve content without a fetch
    //  • a Map { content: '...' } (old/nested format)
    String? latestMsg;
    final rawLatest = json['latestMessage'];
    if (rawLatest is Map) {
      latestMsg = rawLatest['content']?.toString();
    }
    // If it's a String (just an ID), leave null — no content available without fetch

    return BroadcastList(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: () {
        final raw = (json['chatName'] ?? json['name'] ?? '').toString().trim();
        // Keep custom name, or default to timestamp-based name if truly empty
        if (raw.isNotEmpty) return raw;
        final createdAt = json['createdAt']?.toString() ?? '';
        if (createdAt.isNotEmpty) {
          try {
            final dt = DateTime.parse(createdAt);
            return 'Broadcast ${dt.day}/${dt.month}/${dt.year}';
          } catch (_) {
            return 'Broadcast';
          }
        }
        return 'Broadcast';
      }(),
      members: users,
      latestMessage: latestMsg,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: status,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      audience: audience,
      deliveredCount: json['deliveredCount'] as int?,
      pendingCount: json['pendingCount'] as int?,
      totalRecipients: json['totalRecipients'] as int?,
      creatorId: () {
        final raw = (json['creatorId'] ?? json['creator']?['_id'] ?? '')
            .toString()
            .trim();
        return raw.isNotEmpty ? raw : null;
      }(),
      creatorUsername: () {
        final raw = (json['creator']?['username'] ?? '').toString().trim();
        return raw.isNotEmpty ? raw : null;
      }(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'chatName': name,
    'name': name,
    'isBroadcast': true,
    'updatedAt': updatedAt.toIso8601String(),
    'latestMessage': latestMessage != null ? {'content': latestMessage} : null,
    'broadcastStatus': status.name,
    'scheduledAt': scheduledAt?.toIso8601String(),
    'audience': audience.name,
    'deliveredCount': deliveredCount,
    'pendingCount': pendingCount,
    'totalRecipients': totalRecipients,
    'creatorId': creatorId,
    'creatorUsername': creatorUsername,
    // Write as 'members' so round-trip cache reads correctly
    'members': members
        .where((m) => m.id.isNotEmpty)
        .map(
          (m) => {
            '_id': m.id,
            'username': m.username,
            'profilePicture': m.profilePicture,
            'phone': m.phone,
          },
        )
        .toList(),
  };

  BroadcastList copyWith({
    String? id,
    String? name,
    List<BroadcastMember>? members,
    String? latestMessage,
    DateTime? updatedAt,
    BroadcastStatus? status,
    DateTime? scheduledAt,
    BroadcastAudience? audience,
    int? deliveredCount,
    int? pendingCount,
    int? totalRecipients,
    String? creatorId,
    String? creatorUsername,
  }) {
    return BroadcastList(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      latestMessage: latestMessage ?? this.latestMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      audience: audience ?? this.audience,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      pendingCount: pendingCount ?? this.pendingCount,
      totalRecipients: totalRecipients ?? this.totalRecipients,
      creatorId: creatorId ?? this.creatorId,
      creatorUsername: creatorUsername ?? this.creatorUsername,
    );
  }
}

class BroadcastMember {
  final String id;
  final String username;
  final String profilePicture;
  final String phone;

  BroadcastMember({
    required this.id,
    required this.username,
    required this.profilePicture,
    this.phone = '',
  });

  factory BroadcastMember.fromJson(Map<String, dynamic> json) {
    return BroadcastMember(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'username': username,
    'profilePicture': profilePicture,
    'phone': phone,
  };
}
