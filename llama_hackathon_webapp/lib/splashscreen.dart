import 'package:flutter/material.dart';

// Packages
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// State
import 'app_provider.dart';
import 'models.dart';

// Utilities
import 'utilities.dart';

// Routes
import 'package:llama_hackathon_webapp/detail.dart';
import 'package:llama_hackathon_webapp/cnb.dart';
import 'package:llama_hackathon_webapp/editor.dart';

class SplashScreen extends StatefulWidget {
  final String hostname;
  final String pathname;

  const SplashScreen({
    required this.hostname,
    required this.pathname,
    super.key,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ScrollController controller = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadData());
  }

  Future<void> loadData() async {
    await Future.delayed(const Duration(seconds: 2));

    List<String> pathnameComponents = widget.pathname.split('/')
      ..removeWhere((item) => item.isEmpty);

    if (pathnameComponents.contains('workspace')) {
      print('Workspace Page');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size dimensions = MediaQuery.of(context).size;
    Map organizedData = organizeData();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          '🦙 Llamar',
          style: GoogleFonts.robotoMono(
            height: 1,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      drawer: Drawer(
        width: 400,
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemBuilder: (context, gradeIndex) {
            var grade = organizedData.values.elementAt(gradeIndex);
            var subjects = grade['subjects'];
            return ExpansionTile(
              initiallyExpanded: gradeIndex == 0 ? true : false,
              shape: const Border(),
              title: Text(
                '${grade['grade']} Grado',
                style: GoogleFonts.robotoMono(
                  height: 1,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              children: List.generate(
                subjects.length,
                (subjectIndex) {
                  var subject = subjects[subjectIndex];
                  return ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Detail(
                          grade: grade['grade'],
                          data: subject,
                        ),
                      ),
                    ),
                    title: Text(subject['subject']),
                  );
                },
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 20);
          },
          itemCount: organizedData.length,
        ),
      ),
      body: ListView(
        controller: controller,
        children: [
          SizedBox(
            height: dimensions.height - 60,
            width: dimensions.width,
            child: Stack(
              children: [
                blobs(dimensions),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: dimensions.width / 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Planifica tu clase',
                              style: GoogleFonts.roboto(
                                height: 1,
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Builder(builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: Text(
                                  'o explora el catálogo',
                                  style: GoogleFonts.robotoMono(
                                    height: 1,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        TextField(
                          decoration: const InputDecoration(
                            prefix: Text('Genérame una plan de clase que '),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (String value) {
                            controller.animateTo(
                              dimensions.height,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeIn,
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🖍️ Una experiencia simplificada',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Icon(Icons.arrow_forward),
                            Expanded(
                              child: Text(
                                'Navega el CNB de forma rápida y eficiente',
                                style: GoogleFonts.robotoMono(),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🤖 Asistente pedagógico 24/7',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Icon(Icons.arrow_forward),
                            Expanded(
                              child: Text(
                                'Obtén ayuda experta para planificar tus clases',
                                style: GoogleFonts.robotoMono(),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📱 Acceso sin conexión',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Icon(Icons.arrow_forward),
                            Expanded(
                              child: Text(
                                'Consulta el contenido aunque no tengas internet',
                                style: GoogleFonts.robotoMono(),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📚 Recursos educativos',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Icon(Icons.arrow_forward),
                            Expanded(
                              child: Text(
                                'Genera material didáctico personalizado para tus estudiantes',
                                style: GoogleFonts.robotoMono(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(
                vertical: 100,
                horizontal: dimensions.width / 4,
              ),
              child: Editor(document: DocumentModel.empty())),
        ],
      ),
    );
  }
}