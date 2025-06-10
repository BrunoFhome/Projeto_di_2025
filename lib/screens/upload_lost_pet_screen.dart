import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';


class UploadLostPetScreen extends StatefulWidget {
  @override
  _UploadLostPetScreenState createState() => _UploadLostPetScreenState();
}

class _UploadLostPetScreenState extends State<UploadLostPetScreen> {
  File? _image;
  final picker = ImagePicker();
  final _descriptionController = TextEditingController();
  bool _isUploading = false;
  String _statusMessage = "";

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadData() async {
    if (_image == null) {
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
      final uri = Uri.parse('http://10.0.2.2:5000/upload'); // backend local
      final request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(_image!.path);
      final imageFile = await http.MultipartFile.fromPath(
        'image',
        _image!.path,
        filename: basename(_image!.path),
      );

      request.files.add(imageFile);
      request.fields['description'] = _descriptionController.text;
      request.fields['type'] = 'lost';

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
      appBar: AppBar(title: Text("Perdi meu gato")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _image != null
                  ? Image.file(_image!, height: 200)
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
                  labelText: "Descrição (bairro, cor, etc.)",
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