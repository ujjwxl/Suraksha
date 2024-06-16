import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trackingapp/providers/language_provider.dart';

class ChangeLanguagePage extends StatelessWidget {
  const ChangeLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.changeLanguageAppBarText,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Text(
            appLocalizations.changeLanguagePreferredLangugage,
            style: GoogleFonts.dmSans(fontSize: 14),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: LanguageProvider.languages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey[300] ?? Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        LanguageProvider.languages[index]['name'],
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      leading: const Icon(
                        Icons.language,
                        color: Colors.black,
                      ),
                      onTap: () {
                        context.read<LanguageProvider>().changeLanguage(
                              LanguageProvider.languages[index]['locale'],
                            );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
