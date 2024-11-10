import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '🦙 Llamar',
          style: GoogleFonts.robotoMono(
            height: 1,
            fontSize: 150,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
