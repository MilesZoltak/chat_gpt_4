import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String user;
  const ChatPage(this.user, {super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _gpt = const types.User(id: '82093378-a48d-4a59-aed5-a25bf8ddf34c', imageUrl: "https://static.vecteezy.com/system/resources/previews/018/764/128/original/chatgpt-logo-open-ai-icon-with-chatbot-artificial-intelligence-openai-chatbot-icon-chatgpt-openai-icon-artificial-intelligence-smart-ai-virtual-smart-assistant-bot-free-vector.jpg");

  int promptTokens = 0;
  int completionTokens = 0;

  List<String> systemUtterances = ["Hi there!  I'm GPT-4.  You can use this tool to query me.  Here are some things to know:\n\t- I think I'll work, but I don't really know.\n\t- Also, when you refresh this page, our conversation will not be saved.  But within sessions the context of our discussion will persist.  So you should be able to reference things we talked about earlier within a session.\n\t- I think that's all for now.  Happy chatting!"];
  List<String> userUtterances = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Scaffold(
      appBar: AppBar(
        title: const Text("GPT-4"),
        actions: [
          TextButton(onPressed: null, child: Text("Conversation Cost: \$${(0.03 * promptTokens / 1000 + 0.06 * completionTokens / 1000).toStringAsFixed(2)}", style: const TextStyle(color: Colors.white),))
        ],
      ),
      body: Chat(
        messages: _messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
      ),
    ),
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _loadMessages() async {
    final gptIntroduction = types.TextMessage(
        author: _gpt,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: systemUtterances[0]
    );
    _addMessage(gptIntroduction);
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
    userUtterances.add(message.text);

    String resp = await useGPT();
    final gptResponse = types.TextMessage(
        author: _gpt,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: resp
    );
    _addMessage(gptResponse);
    systemUtterances.add(resp);
  }

  Future<String> useGPT() async {
    const url = "https://function-1-2zrwdvhj3q-uc.a.run.app";
    Uri uri = Uri.parse(url);
    print("requesting...");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({"systemUtterances": systemUtterances, "userUtterances": userUtterances});
    print("body: $body");
    String output = "";
    try {
      final response = await http.post(uri, headers: headers, body: body);
      var bod = jsonDecode(response.body);
      output = bod["response"];
      setState(() {
        promptTokens += int.parse(bod["promptTokens"].toString());
        completionTokens += int.parse(bod["completionTokens"].toString());
      });
      print("prompt tokens: ${bod["promptTokens"].toString()} and completion tokens: ${bod["completionTokens"].toString()}");
    } catch (e) {
      output = "Error: $e";
      var snackBar = SnackBar(
        content: Text('Body: $body.'),
        duration: const Duration(seconds: 15),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return output;
  }
}