import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../translator/translation_provider.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var translationProvider = Provider.of<TranslationProvider>(context);

    return FutureBuilder(
      future: Future.wait([
        translationProvider.translate("Donate Food"),
        translationProvider.translate("Share excess food with NGOs."),
        translationProvider.translate("Explore Recipes"),
        translationProvider.translate("Discover recipes for your leftovers."),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var translatedText = snapshot.data as List<String>;

        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.orange),
              title: Text(translatedText[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(translatedText[1]),
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.purple),
              title: Text(translatedText[2], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(translatedText[3]),
            ),
          ],
        );
      },
    );
  }
}
