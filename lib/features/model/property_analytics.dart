class PropertyAnalytics {
  final String propertyId;
  int viewCount;
  Duration totalTimeSpent;
  int imageUploadClicks;
  int contactAgentClicks;

  PropertyAnalytics({
    required this.propertyId,
    this.viewCount = 0,
    this.totalTimeSpent = Duration.zero,
    this.imageUploadClicks = 0,
    this.contactAgentClicks = 0,
  });

  Map<String, dynamic> toJson() => {
    'propertyId': propertyId,
    'viewCount': viewCount,
    'totalTimeSpent': totalTimeSpent.inSeconds,
    'imageUploadClicks': imageUploadClicks,
    'contactAgentClicks': contactAgentClicks,
  };
}
