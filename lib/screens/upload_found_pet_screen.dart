import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';

class UploadFoundPetScreen extends StatefulWidget {
  @override
  _UploadFoundPetScreenState createState() => _UploadFoundPetScreenState();
}

class _UploadFoundPetScreenState extends State<UploadFoundPetScreen> {
  File? _image;
  Uint8List? _imageBytes;
  final picker = ImagePicker();
  final _descriptionController = TextEditingController();
  bool _isUploading = false;
  String _statusMessage = "";

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _image = File(pickedFile.path);
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _uploadData() async {
    if (_image == null && _imageBytes == null) {
      setState(() {
        _statusMessage = "Por favor, selecione uma imagem.";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = "";
    });

    try {
      final uri = Uri.parse('http://localhost:5000/upload'); // Use o IP do seu backend se não estiver no emulador
      final request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(_image?.path ?? '') ?? 'image/jpeg';

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _imageBytes!,
          filename: 'found_pet.jpg',
          contentType: MediaType.parse(mimeType),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType.parse(mimeType),
          filename: basename(_image!.path),
        ));
      }

      request.fields['description'] = _descriptionController.text;
      request.fields['type'] = 'found';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "Upload realizado com sucesso!";
        });
      } else {
        setState(() {
          _statusMessage = "Erro ao enviar: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Erro: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Encontrei um gato")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _image != null
                  ? (kIsWeb
                      ? Image.memory(_imageBytes!, height: 200)
                      : Image.file(_image!, height: 200))
                  : Placeholder(fallbackHeight: 200),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.photo),
                label: Text("Escolher da Galeria"),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Descrição (local onde foi visto, cor, etc.)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadData,
                      child: Text("Enviar"),
                    ),
              const SizedBox(height: 10),
              Text(
                _statusMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}