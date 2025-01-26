import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';

final currentTransactionProvider = StateProvider<Transaction?>((ref) => null);
