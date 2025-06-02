import 'package:flutter/material.dart';
import 'package:encontre_meu_gato/screens/upload_lost_pet_screen.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Encontre Meu Gato')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (_) => UploadLostPetScreen()));
            },
            child: Text('Perdi meu gato'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (_) => UploadFoundPetScreen()));
            },
            child: Text('Encontrei um gato'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (_) => PetGalleryScreen()));
            },
            child: Text('Galeria'),
          ),
        ],
      ),
    );
  }
}
