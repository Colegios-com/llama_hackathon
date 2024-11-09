import 'package:flutter/material.dart';

// Packages
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

MarkdownStyleSheet stylesheet = MarkdownStyleSheet(
  h1: GoogleFonts.roboto(
    fontSize: 35,
    fontWeight: FontWeight.bold,
  ),
  h2: GoogleFonts.roboto(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  ),
  h3: GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
  h4: GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  ),
  p: GoogleFonts.roboto(
    fontSize: 15,
  ),
);
