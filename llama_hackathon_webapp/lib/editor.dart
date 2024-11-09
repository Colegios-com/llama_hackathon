import 'package:flutter/material.dart';

// Packages
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

// Utilities
import 'package:llama_hackathon_webapp/stylesheet.dart';
import 'package:llama_hackathon_webapp/utilities.dart';

// Models
import 'package:llama_hackathon_webapp/models.dart';

class Editor extends StatefulWidget {
  final DocumentModel document;

  const Editor({required this.document, super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  Widget compactActions() {
    return StatefulBuilder(builder: (context, setModalState) {
      return Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Acciones',
                  style: GoogleFonts.robotoMono(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.grey,
                ),
                title: const Text(
                  'Editar',
                ),
                subtitle: const Text('Edita tu documento.'),
                onTap: () async {
                  setState(() {
                    widget.document.editing = true;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.copy,
                  color: Colors.grey,
                ),
                title: const Text('Copiar'),
                subtitle: const Text('Copia el contenido al portapapeles.'),
                onTap: () {
                  copyToClipboard(
                    context,
                    widget.document.content ??
                        'Este documento no contiene contenido.',
                  );
                  showAlert(context,
                      type: 'warning',
                      message:
                          'Documento copiado! Listo para compartir y transformar la educación 💫');

                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.link,
                  color: Colors.grey,
                ),
                title: const Text('Compartir'),
                subtitle: const Text('Comparte el documento con tus colegas.'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(
                  widget.document.private ? Icons.lock : Icons.lock_open,
                  color: widget.document.private ? Colors.amber : Colors.grey,
                ),
                title: const Text('Privacidad'),
                subtitle:
                    const Text('Haz que tu documento sea privado o público.'),
                onTap: () async {
                  setModalState(() {
                    widget.document.private = !widget.document.private;
                  });
                },
              ),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {},
                  onLongPress: () async {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Borrar Documento',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ));
    });
  }

  Widget actions() {
    Size dimensions = MediaQuery.of(context).size;
    if (dimensions.width < 600) {
      return IconButton(
        onPressed: () {
          if (widget.document.editing) {
            widget.document.editing = false;
          } else {
            showModalBottomSheet(
              context: context,
              isDismissible: true,
              isScrollControlled: true,
              builder: (context) => compactActions(),
            );
          }
        },
        icon: widget.document.editing
            ? const Icon(Icons.save)
            : const Icon(Icons.menu),
      );
    } else {
      return Row(
        children: [
          if (widget.document.synchronizing)
            IconButton(
              onPressed: () {},
              icon: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: controller.value * 2.0 * 3.14159,
                    child: const Icon(
                      Icons.sync,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          if (!widget.document.synchronizing)
            IconButton(
              onPressed: () async {
                if (widget.document.editing) {
                  setState(() {
                    widget.document.synchronizing = true;
                    widget.document.editing = false;
                  });

                  await Future.delayed(const Duration(seconds: 2), () {
                    setState(() {
                      widget.document.synchronizing = false;
                    });
                  });

                  setState(() {
                    widget.document.synchronizing = false;
                  });
                } else {
                  setState(() {
                    widget.document.editing = true;
                  });
                }
              },
              icon: Icon(
                widget.document.editing ? Icons.save : Icons.edit,
                color: Colors.grey,
              ),
            ),
          IconButton(
            onPressed: () {
              copyToClipboard(
                context,
                widget.document.content ??
                    'Este documento no contiene contenido.',
              );
              showAlert(context,
                  type: 'warning',
                  message:
                      'Documento copiado! Listo para compartir y transformar la educación 💫');
            },
            icon: const Icon(
              Icons.copy,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.link,
              color: Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () async {
              setState(() {
                widget.document.private = !widget.document.private;
              });
            },
            icon: Icon(
              widget.document.private ? Icons.lock : Icons.lock_open,
              color: widget.document.private ? Colors.amber : Colors.grey,
            ),
          ),
          GestureDetector(
            onLongPress: () async {},
            child: IconButton(
              onPressed: () {
                showAlert(context,
                    type: 'warning',
                    message: 'Mantén presionado para borrar el documento.');
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size dimensions = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Editor',
                  style: GoogleFonts.robotoMono(
                    color: Colors.black,
                    fontSize: dimensions.width < 600 ? 30 : 50,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              actions(),
            ],
          ),
          widget.document.editing
              ? TextField(
                  controller:
                      TextEditingController(text: widget.document.content),
                  onChanged: (value) {
                    widget.document.content = value;
                  },
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Escribe aquí...',
                  ),
                )
              : Markdown(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  selectable: true,
                  styleSheet: stylesheet,
                  onTapLink: (text, href, title) async {
                    Uri url = Uri.parse(href!);
                    if (!await launchUrl(url)) {
                      print('Could not launch $url');
                    }
                  },
                  data: widget.document.content ?? '',
                ),
        ],
      ),
    );
  }
}
