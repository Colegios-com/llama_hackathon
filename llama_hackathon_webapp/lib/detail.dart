import 'package:flutter/material.dart';

// Packages
import 'package:google_fonts/google_fonts.dart';

// Routes

import 'package:llama_hackathon_webapp/chat.dart';

class Detail extends StatefulWidget {
  final String grade;
  final Map data;
  const Detail({required this.grade, required this.data, super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    var grade = widget.data['grade'];
    var subject = widget.data['subject'];
    var skills = widget.data['skills'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          '🦙 Llamar',
          style: GoogleFonts.robotoMono(
            height: 1,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [Container()],
      ),
      endDrawer: Chat(context: widget.data),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 200),
        children: [
          Text(
            'Para cumplir con los estándares de aprendizaje de $subject, un estudiante de $grade Grado debe ser capaz de:',
            style: GoogleFonts.roboto(
              height: 1,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 50),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, skillIndex) {
              var skill = skills[skillIndex];
              var learningObjectives = skill['learning_objectives'];
              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: skillIndex == 0 ? true : false,
                shape: const Border(),
                title: Text(
                  skill['skill'],
                  style: GoogleFonts.robotoMono(
                    height: 1,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                children: List.generate(
                  learningObjectives.length,
                  (learningObjectiveIndex) {
                    var learningObjective =
                        learningObjectives[learningObjectiveIndex];
                    var contents = learningObjective['contents'];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          learningObjective['learning_objective'],
                          style: GoogleFonts.robotoMono(
                            height: 1,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(left: 20),
                          itemBuilder: (context, contentIndex) {
                            var content = contents[contentIndex];
                            return Text(
                              content['content'],
                              style: GoogleFonts.robotoMono(
                                color: Colors.grey[800],
                                height: 1,
                                fontSize: 15,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 20);
                          },
                          itemCount: contents.length,
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 20);
            },
            itemCount: skills.length,
          ),
        ],
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: const Icon(
            Icons.chat_bubble,
            color: Colors.white,
          ),
        );
      }),
    );
  }
}
