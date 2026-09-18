import 'package:easy_deal/core/utils/currency_formatter.dart';
import 'package:easy_deal/core/utils/validators.dart';
import 'package:easy_deal/features/auth/data/models/user_model.dart';
import 'package:easy_deal/features/property/data/models/property_model.dart';
import 'package:easy_deal/features/vehicle/data/models/vehicle_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyHelper Tests', () {
    test('formats Indian currency numbers correctly', () {
      expect(CurrencyHelper.format(8500000), contains('85,00,000'));
      expect(CurrencyHelper.format(1450000), contains('14,50,000'));
      expect(CurrencyHelper.format(null), 'Price on Request');
    });

    test('compact formatting produces correct units', () {
      expect(CurrencyHelper.formatCompact(8500000), '₹85 Lakh');
      expect(CurrencyHelper.formatCompact(15000000), '₹1.50 Cr');
      expect(CurrencyHelper.formatCompact(null), 'Price on Request');
    });

    test('converts amounts to live verbal words', () {
      expect(CurrencyHelper.toWords(8500000), '₹ 85.00 Lakhs');
      expect(CurrencyHelper.toWords(15000000), '₹ 1.50 Crores');
    });
  });

  group('Validators Tests', () {
    test('validates email addresses', () {
      expect(Validators.email('test@example.com'), isNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('validates 10-digit phone numbers', () {
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone(''), isNotNull);
    });

    test('validates password length', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });
  });

  group('Model Serialization Tests', () {
    test('UserModel serializes and deserializes', () {
      final user = UserModel.fromJson({
        'id': 'usr_1',
        'name': 'Abhishek',
        'email': 'abhishek@example.com',
        'phone': '9876543210',
        'is_premium': true,
        'role': 'premium',
      });
      expect(user.name, 'Abhishek');
      expect(user.isPremium, isTrue);
      expect(user.toJson()['email'], 'abhishek@example.com');
    });

    test('PropertyModel deserializes correctly', () {
      final property = PropertyModel.fromJson({
        'id': 'prop_1',
        'title': 'Prestige Ozone',
        'property_type': 'Flat',
        'location': 'Whitefield, Bangalore',
        'price': 8500000,
        'images': ['https://example.com/1.jpg'],
      });
      expect(property.title, 'Prestige Ozone');
      expect(property.images.length, 1);
      expect(property.price, 8500000);
    });

    test('VehicleModel deserializes correctly', () {
      final vehicle = VehicleModel.fromJson({
        'id': 'veh_1',
        'title': 'Hyundai Creta',
        'brand': 'Hyundai',
        'model': 'Creta',
        'year': '2022',
        'expectedPrice': 1450000,
        'location': 'Koramangala, Bangalore',
      });
      expect(vehicle.brand, 'Hyundai');
      expect(vehicle.expectedPrice, 1450000);
    });
  });
}
