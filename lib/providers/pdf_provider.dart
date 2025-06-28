import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

final pdfControllerProvider = StateProvider<PdfController?>((ref) => null);
final pdfLoadingProvider = StateProvider<bool>((ref) => true);
