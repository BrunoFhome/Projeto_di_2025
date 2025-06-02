import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
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

    final uri = Uri.parse('http://192.168.68.108:5000/upload_lost_pet'); // Replace with your backend URL
    final request = http.MultipartRequest('POST', uri);

    final mimeType = lookupMimeType(_image!.path);
    final imageFile = await http.MultipartFile.fromPath(
      'image',
      _image!.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      filename: basename(_image!.path),
    );

    request.files.add(imageFile);
    request.fields['description'] = _descriptionController.text;
    request.fields['type'] = 'lost';

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "Upload realizado com sucesso!";
        });
      } else {
        setState(() {
          _statusMessage = "Erro ao enviar. Tente novamente.";
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perdi meu gato")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Placeholder(fallbackHeight: 200),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text("Câmera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo),
                  label: Text("Galeria"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Descrição (bairro, cor, etc.)"),
            ),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadData,
                    child: Text("Enviar"),
                  ),
            SizedBox(height: 10),
            Text(
              _statusMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
// Note: Replace <SEU_BACKEND> with the actual backend address or IP where your Flask app is running.
// Ensure your backend is running and accessible from the device/emulator where this app is running.