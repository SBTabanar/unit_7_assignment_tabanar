import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureCharacters;

  @override
  void initState() {
    super.initState();
    futureCharacters = fetchCharacters();
  }

  // setup the URL for your API here
  Future<List<dynamic>> fetchCharacters() async {
    final response =
        await http.get(Uri.parse('https://api.disneyapi.dev/character'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load characters');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unit 7 - API Calls"),
        backgroundColor: Color.fromARGB(255, 215, 142, 46),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureCharacters,
        builder: (context, snapshot) {
          // Handle different states of the FutureBuilder

          // Consider 3 cases here
          // when the process is ongoing
          // return CircularProgressIndicator();
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // when the process is completed:

          // successful
          else if (snapshot.hasData) {
            final characters = snapshot.data ?? [];
            final limitedCharacters = characters.take(9).toList();

            return ListView.builder(
              itemCount: limitedCharacters.length,
              itemBuilder: (context, index) {
                final character = limitedCharacters[index];
                // Use the library here
                return ExpandedTile(
                  title: Text(character['name']),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(character['imageUrl'] ?? ''),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Films appeared in: ${character['films']?.isNotEmpty == true ? character['films']?.join(', ') : 'N/A'}',
                          ),
                          Text(
                            'Video Games appeared in: ${character['videoGames']?.isNotEmpty == true ? character['videoGames']?.join(', ') : 'N/A'}',
                          )
                        ]),
                  ),
                  controller: ExpandedTileController(),
                  theme: const ExpandedTileThemeData(
                    headerColor: Colors.white,
                    contentBackgroundColor: Colors.lightBlue,
                  ),
                );
              },
            );
          }

          // error
          else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Default case: no data available
          else {
            return const Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }
}
