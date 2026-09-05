class MaterialItem {
  final String id;
  final String category;
  final String? subCategory;
  final String? description;
  final String imageUrl;
  final double approxWeightKg;
  final String condition;
  final double estimatedValueMinInr;
  final double estimatedValueMaxInr;
  final String dataMaturity;

  MaterialItem({
    required this.id,
    required this.category,
    this.subCategory,
    this.description,
    required this.imageUrl,
    required this.approxWeightKg,
    required this.condition,
    required this.estimatedValueMinInr,
    required this.estimatedValueMaxInr,
    required this.dataMaturity,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'PCB',
      subCategory: json['subCategory']?.toString(),
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      approxWeightKg: (json['approxWeightKg'] as num?)?.toDouble() ?? 1.0,
      condition: json['condition']?.toString() ?? 'good',
      estimatedValueMinInr: (json['estimatedValueMinInr'] as num?)?.toDouble() ?? 0.0,
      estimatedValueMaxInr: (json['estimatedValueMaxInr'] as num?)?.toDouble() ?? 0.0,
      dataMaturity: json['dataMaturity']?.toString() ?? 'demo',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'subCategory': subCategory,
        'description': description,
        'imageUrl': imageUrl,
        'approxWeightKg': approxWeightKg,
        'condition': condition,
        'estimatedValueMinInr': estimatedValueMinInr,
        'estimatedValueMaxInr': estimatedValueMaxInr,
        'dataMaturity': dataMaturity,
      };
}

class TimelineEvent {
  final String stage;
  final String timestamp;
  final String? note;
  final String? actorRole;

  TimelineEvent({
    required this.stage,
    required this.timestamp,
    this.note,
    this.actorRole,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      stage: json['stage']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      note: json['note']?.toString(),
      actorRole: json['actorRole']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'stage': stage,
        'timestamp': timestamp,
        'note': note,
        'actorRole': actorRole,
      };
}

class TraceabilityInfo {
  final String lotId;
  final List<String> photos;
  final double weightKg;
  final String handoverReferenceNumber;
  final bool recyclerConfirmation;
  final List<TimelineEvent> timeline;

  TraceabilityInfo({
    required this.lotId,
    required this.photos,
    required this.weightKg,
    required this.handoverReferenceNumber,
    required this.recyclerConfirmation,
    required this.timeline,
  });

  factory TraceabilityInfo.fromJson(Map<String, dynamic> json) {
    var rawTimeline = json['timeline'];
    List<TimelineEvent> timelineList = [];
    if (rawTimeline is List) {
      timelineList = rawTimeline.map((e) => TimelineEvent.fromJson(e)).toList();
    }

    var rawPhotos = json['photos'];
    List<String> photoList = [];
    if (rawPhotos is List) {
      photoList = rawPhotos.map((e) => e.toString()).toList();
    }

    return TraceabilityInfo(
      lotId: json['lotId']?.toString() ?? '',
      photos: photoList,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      handoverReferenceNumber: json['handoverReferenceNumber']?.toString() ?? '',
      recyclerConfirmation: json['recyclerConfirmation'] == true,
      timeline: timelineList,
    );
  }
}

enum SyncState {
  savedOffline,
  syncing,
  synced,
  attentionRequired,
}

class MaterialLot {
  final String id;
  final String collectorId;
  final String? collectorName;
  final MaterialItem material;
  final double weightKg;
  final double quotedPriceInr;
  final double? finalPriceInr;
  final String? recyclerId;
  final String? recyclerName;
  final String? collectionArea;
  final String? handoverArea;
  final String dateTime;
  final String paymentStatus;
  final String? paymentMethod;
  final String transactionStatus;
  final SyncState syncState;
  final String dataMaturity;
  final TraceabilityInfo? traceability;

  MaterialLot({
    required this.id,
    required this.collectorId,
    this.collectorName,
    required this.material,
    required this.weightKg,
    required this.quotedPriceInr,
    this.finalPriceInr,
    this.recyclerId,
    this.recyclerName,
    this.collectionArea,
    this.handoverArea,
    required this.dateTime,
    required this.paymentStatus,
    this.paymentMethod,
    required this.transactionStatus,
    this.syncState = SyncState.synced,
    required this.dataMaturity,
    this.traceability,
  });

  factory MaterialLot.fromJson(Map<String, dynamic> json) {
    return MaterialLot(
      id: json['id']?.toString() ?? '',
      collectorId: json['collectorId']?.toString() ?? '',
      collectorName: json['collectorName']?.toString(),
      material: MaterialItem.fromJson(json['material'] ?? {}),
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      quotedPriceInr: (json['quotedPriceInr'] as num?)?.toDouble() ?? 0.0,
      finalPriceInr: (json['finalPriceInr'] as num?)?.toDouble(),
      recyclerId: json['recyclerId']?.toString(),
      recyclerName: json['recyclerName']?.toString(),
      collectionArea: json['collectionArea']?.toString(),
      handoverArea: json['handoverArea']?.toString(),
      dateTime: json['dateTime']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString(),
      transactionStatus: json['transactionStatus']?.toString() ?? 'draft',
      syncState: json['syncState'] == 'offline_saved'
          ? SyncState.savedOffline
          : json['syncState'] == 'syncing'
              ? SyncState.syncing
              : json['syncState'] == 'attention_required'
                  ? SyncState.attentionRequired
                  : SyncState.synced,
      dataMaturity: json['dataMaturity']?.toString() ?? 'demo',
      traceability: json['traceability'] != null
          ? TraceabilityInfo.fromJson(json['traceability'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'collectorId': collectorId,
        'collectorName': collectorName,
        'material': material.toJson(),
        'weightKg': weightKg,
        'quotedPriceInr': quotedPriceInr,
        'finalPriceInr': finalPriceInr,
        'recyclerId': recyclerId,
        'recyclerName': recyclerName,
        'collectionArea': collectionArea,
        'handoverArea': handoverArea,
        'dateTime': dateTime,
        'paymentStatus': paymentStatus,
        'paymentMethod': paymentMethod,
        'transactionStatus': transactionStatus,
        'syncState': syncState.name,
        'dataMaturity': dataMaturity,
      };
}
