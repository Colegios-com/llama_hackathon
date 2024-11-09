import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// Packages
import 'package:blobs/blobs.dart';
import 'package:google_fonts/google_fonts.dart';

void showAlert(BuildContext context,
    {required String type, required String message}) {
  Color color = Colors.grey;
  if (type == 'error') {
    color = Colors.red;
  } else if (type == 'warning') {
    color = Colors.amber;
  }

  Size dimensions = MediaQuery.of(context).size;

  double bottomMargin =
      dimensions.height - (dimensions.width > 1200 ? 60 : 120);

  SnackBar snackBar = SnackBar(
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
      bottom: bottomMargin,
      left: 10,
      right: 10,
    ),
    content: Text(message, style: GoogleFonts.roboto()),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void copyToClipboard(BuildContext context, String payload) {
  Clipboard.setData(ClipboardData(text: payload));
}

double position(Size dimensions) {
  double max = dimensions.width > 1250
      ? dimensions.longestSide / 2
      : dimensions.longestSide;
  return Random().nextDouble() * max;
}

double size(Size dimensions) {
  double max = dimensions.longestSide / 10;
  return Random().nextDouble() * max + (max);
}

Stack blobs(Size dimensions) {
  List currency = ['💰', '💸', '🦙'];
  return Stack(
    children: List.generate(
      10,
      (index) => Positioned(
        top: position(dimensions),
        left: position(dimensions),
        child: Blob.animatedRandom(
          size: size(dimensions),
          minGrowth: 8,
          styles: BlobStyles(
            color: Colors.yellowAccent,
          ),
          duration: const Duration(seconds: 5),
          loop: true,
          child: Center(
            child: Text(
              currency[Random().nextInt(currency.length)],
              style: TextStyle(
                fontSize: dimensions.height / 20,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

String offerEnd(String targetDateString) {
  DateTime targetDate = DateTime.parse(targetDateString);
  DateTime now = DateTime.now();

  Duration difference = targetDate.difference(now);

  if (difference.inDays >= 365) {
    int years = (difference.inDays / 365).floor();
    return 'Finaliza en $years ${years == 1 ? 'año' : 'años'}';
  } else if (difference.inDays >= 30) {
    int months = (difference.inDays / 30).floor();
    return 'Finaliza en $months ${months == 1 ? 'mes' : 'meses'}';
  } else if (difference.inDays >= 7) {
    int weeks = (difference.inDays / 7).floor();
    return 'Finaliza en $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
  } else if (difference.inDays >= 1) {
    return 'Finaliza en ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
  } else if (difference.inHours >= 1) {
    return 'Finaliza en ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
  } else if (difference.inHours >= 1) {
    return 'Finaliza en ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
  } else {
    return 'Oferta finalizada';
  }
}

String couponExpiration(String targetDateString) {
  DateTime targetDate = DateTime.parse(targetDateString);
  DateTime now = DateTime.now();

  Duration difference = targetDate.difference(now);

  if (difference.inDays >= 365) {
    int years = (difference.inDays / 365).floor();
    return 'Expira en $years ${years == 1 ? 'año' : 'años'}';
  } else if (difference.inDays >= 30) {
    int months = (difference.inDays / 30).floor();
    return 'Expira en $months ${months == 1 ? 'mes' : 'meses'}';
  } else if (difference.inDays >= 7) {
    int weeks = (difference.inDays / 7).floor();
    return 'Expira en $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
  } else if (difference.inDays >= 1) {
    return 'Expira en ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
  } else if (difference.inHours >= 1) {
    return 'Expira en ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
  } else if (difference.inHours >= 1) {
    return 'Expira en ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
  } else {
    return 'Cupón expirado';
  }
}

String formatDate(dynamic dateTime) {
  if (dateTime.runtimeType == String) {
    dateTime = DateTime.parse(dateTime);
  }
  const months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Augosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];
  final day = dateTime.day;
  final month = months[dateTime.month - 1];
  final year = dateTime.year;
  return '$day de $month de $year';
}
