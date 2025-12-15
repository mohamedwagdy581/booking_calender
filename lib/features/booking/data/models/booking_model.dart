
import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String? id;
  final String title;
  final DateTime date;
  final String familyName;
  final String email;
  final String location;
  final String hallName;
  final double totalAmount;
  final double firstPayment;
  final double cashPayment;
  final double artistPayment;
  final String artistName;
  final List<String> images;

  const Booking({
    this.id,
    required this.title,
    required this.date,
    required this.familyName,
    required this.email,
    required this.location,
    required this.hallName,
    required this.totalAmount,
    required this.firstPayment,
    required this.cashPayment,
    required this.artistPayment,
    required this.artistName,
    required this.images,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'Untitled',
      date: DateTime.parse(json['date'] as String),
      familyName: json['family_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      location: json['location'] as String? ?? '',
      hallName: json['hall_name'] as String? ?? '',
      totalAmount: (json['total_amount'] as num? ?? 0).toDouble(),
      firstPayment: (json['first_payment'] as num? ?? 0).toDouble(),
      cashPayment: (json['cash_payment'] as num? ?? 0).toDouble(),
      artistPayment: (json['artist_payment'] as num? ?? 0).toDouble(),
      artistName: json['artist_name'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'family_name': familyName,
      'email': email,
      'location': location,
      'hall_name': hallName,
      'total_amount': totalAmount,
      'first_payment': firstPayment,
      'cash_payment': cashPayment,
      'artist_payment': artistPayment,
      'artist_name': artistName,
      'images': images,
    };
  }

  Map<String, dynamic> toJsonWithoutId() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'family_name': familyName,
      'email': email,
      'location': location,
      'hall_name': hallName,
      'total_amount': totalAmount,
      'first_payment': firstPayment,
      'cash_payment': cashPayment,
      'artist_payment': artistPayment,
      'artist_name': artistName,
      'images': images,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        familyName,
        email,
        location,
        hallName,
        totalAmount,
        firstPayment,
        cashPayment,
        artistPayment,
        artistName,
        images,
      ];
}
