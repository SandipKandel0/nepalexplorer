class BookingRequestEntity {
  final String requestId;
  final String guideId;
  final String userId;
  final String userName;
  final String userEmail;
  final String destinationName;
  final String startDate;
  final String endDate;
  final int numberOfPeople;
  final String notes;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  BookingRequestEntity({
    required this.requestId,
    required this.guideId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.destinationName,
    required this.startDate,
    required this.endDate,
    required this.numberOfPeople,
    required this.notes,
    required this.status,
    required this.createdAt,
  });
}
