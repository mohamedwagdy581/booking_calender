
import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String? id;
  final String? refNumber;
  final DateTime createdAt; // تاريخ إنشاء عرض السعر
  final String title;
  final DateTime date;
  final String clientName;
  final String email;
  final String location;
  final String hallName;
  final double totalAmount;
  final double firstPayment;
  final double lastPayment;
  final int hours;
final String currency;
final bool isCompany;
final String paymentMethod;
  final String artistName;
  final String bankName; // حقل جديد لاسم البنك
  final List<String> images;

  const Booking({
    this.id,
    this.refNumber,
    required this.createdAt,
    required this.title,
    required this.date,
    required this.clientName,
    required this.email,
    required this.location,
    required this.hallName,
    required this.totalAmount,
    required this.firstPayment,
    required this.lastPayment,
    required this.hours, 
    required this.currency, 
    required this.isCompany,
    required this.paymentMethod,
    required this.artistName,
    required this.bankName,
    required this.images, 
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String?,
      refNumber: json['ref_number'] as String?,
      // محاولة قراءة تاريخ الإنشاء، وفي حالة عدم وجوده (للحجوزات القديمة) نستخدم التاريخ الحالي أو تاريخ الحجز
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      title: json['title'] as String? ?? 'Untitled',
      date: DateTime.parse(json['date'] as String),  
      clientName: json['client_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      location: json['location'] as String? ?? '',
      hallName: json['hall_name'] as String? ?? '',
      totalAmount: (json['total_amount'] as num? ?? 0).toDouble(),
      firstPayment: (json['first_payment'] as num? ?? 0).toDouble(),
      lastPayment: (json['last_payment'] as num? ?? 0).toDouble(),
      hours: (json['hours'] as num? ?? 0).toInt(),
      currency: json['currency'] as String? ?? 'SAR',
      isCompany: json['is_company'] as bool? ?? false,
      paymentMethod: json['payment_method'] as String? ?? 'Cash',
      artistName: json['artist_name'] as String? ?? '',
      bankName: json['bank_name'] as String? ?? 'Rajhi', // القيمة الافتراضية
      images: (json['images'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ref_number': refNumber,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'date': date.toIso8601String(),
      'client_name': clientName,
      'email': email,
      'location': location,
      'hall_name': hallName,
      'total_amount': totalAmount,
      'first_payment': firstPayment,
      'last_payment': lastPayment,
      'hours': hours,
      'currency': currency,
      'is_company': isCompany,
      'payment_method': paymentMethod,
      'artist_name': artistName,
      'bank_name': bankName,
      'images': images,
    };
  }

  Map<String, dynamic> toJsonWithoutId() {
    return {
      'ref_number': refNumber,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'date': date.toIso8601String(),
      'client_name': clientName,
      'email': email,
      'location': location,
      'hall_name': hallName,
      'total_amount': totalAmount,
      'first_payment': firstPayment,
      'last_payment': lastPayment,
      'hours': hours,
      'currency': currency,
      'is_company': isCompany,
      'payment_method': paymentMethod,
      'artist_name': artistName,
      'bank_name': bankName,
      'images': images,
    };
  }

  @override
  List<Object?> get props => [
        id,
        refNumber,
        createdAt,
        title,
        date,
        clientName,
        email,
        location,
        hallName,
        totalAmount,
        firstPayment,
        lastPayment,
        hours,
        currency,
        isCompany,
        paymentMethod,
        artistName,
        bankName,
        images,
      ];
}
