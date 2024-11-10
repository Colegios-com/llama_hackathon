import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

// Packages
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

// Models
import 'package:llama_hackathon_webapp/app_provider.dart';
import 'package:llama_hackathon_webapp/models.dart';

class Chat extends StatefulWidget {
  final Map context;
  const Chat({required this.context, super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController textController = TextEditingController();

  String? fileText;
  bool loading = false;
  bool loadingFile = false;

  Future selectFile() async {
    setState(() {
      loadingFile = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      withData: true,
    );

    if (result != null) {
      // Get the bytes and decode them to string
      final bytes = result.files.first.bytes;
      if (bytes != null) {
        fileText = String.fromCharCodes(bytes);
      }
    }
    setState(() {
      loadingFile = false;
    });
  }

  Future sendMessage() async {
    if (!loading) {
      loading = true;
      await Provider.of<AppProvider>(context, listen: false).sendMessage(
        workspaceId: 'fe38fcb3-2fa7-4395-9096-bf950135f1b7',
        message: textController.text,
        context: widget.context,
        fileText: fileText,
      );
      loading = false;
      textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MessageModel> messages =
        Provider.of<AppProvider>(context).messages.reversed.toList();

    return Container(
      width: 400,
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              reverse: true,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, messageIndex) {
                MessageModel message = messages[messageIndex];
                return Column(
                  children: [
                    Row(
                      children: [
                        if (message.sender == 'User') const SizedBox(width: 50),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: message.sender != 'User'
                                  ? Colors.grey[200]
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment: message.sender != 'User'
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: message.sender != 'User'
                                          ? Colors.black
                                          : Colors.white,
                                      child: Text(
                                        message.sender[0].toUpperCase(),
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          color: message.sender != 'User'
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        message.sender != 'User'
                                            ? 'Llamar'
                                            : 'Usuario',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          color: message.sender != 'User'
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (message.score != null)
                                      Text(
                                        '${message.score! * 10}/10 😛',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message.message,
                                  style: GoogleFonts.roboto(
                                    color: message.sender != 'User'
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (message.sender != 'User') const SizedBox(width: 50),
                      ],
                    ),
                    if (message.followupQuestions.isNotEmpty)
                      const SizedBox(height: 10),
                    if (message.followupQuestions.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, questionIndex) {
                          String question =
                              message.followupQuestions[questionIndex];
                          return GestureDetector(
                            onTap: () async {
                              await Provider.of<AppProvider>(context,
                                      listen: false)
                                  .sendMessage(
                                context: widget.context,
                                workspaceId:
                                    'fe38fcb3-2fa7-4395-9096-bf950135f1b7',
                                message: question,
                              );
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent[200],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      question,
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 10,
                                  color: Colors.grey[800],
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 5);
                        },
                        itemCount: message.followupQuestions.length,
                      ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10);
              },
              itemCount: messages.reversed.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                loading
                    ? Expanded(
                        child: SizedBox(
                        height: 40,
                        child: LinearProgressIndicator(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ))
                    : Expanded(
                        child: KeyboardListener(
                          focusNode: FocusNode(),
                          onKeyEvent: (value) async {
                            if (value.logicalKey == LogicalKeyboardKey.enter) {
                              await sendMessage();
                            }
                          },
                          child: TextField(
                            controller: textController,
                            minLines: 1,
                            maxLines: 3,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              suffix: GestureDetector(
                                onTap: () {
                                  selectFile();
                                },
                                child: const Icon(
                                  Icons.note_add,
                                  size: 15,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                              hintText: 'Escribe un mensaje...',
                            ),
                          ),
                        ),
                      ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () async {
                    await sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
