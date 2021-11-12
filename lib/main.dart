import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:app/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/firestore.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:app/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthRepository.instance(),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
            body: Center(
                child: Text(snapshot.error.toString(),
                    textDirection: TextDirection.ltr)));
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return MyApp();
      }
      return Center(child: CircularProgressIndicator());
        },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random();
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  FirestoreRepository? firestore;

  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random();
    /*if (Provider.of<AuthRepository>(context, listen: true).status == Status.Authenticated) {
      firestore = FirestoreRepository(userId: Provider.of<AuthRepository>(context, listen: true).user?.uid);
      //firestore?.putSavedWordPairs(_saved);
    }
    if (Provider.of<AuthRepository>(context, listen: true).status == Status.Unauthenticated)
      firestore = null;*/
    firestore = (Provider.of<AuthRepository>(context, listen: true).status == Status.Authenticated) ? FirestoreRepository(userId: Provider.of<AuthRepository>(context, listen: true).user?.uid) : null;
    final sheetController = SnappingSheetController();
    Function snapToPosition = () {
      print("****************");
      if(sheetController.isAttached) {
        print("VOLUNTEASYYYYYYYYYYYYYYYYYYYYY");
        sheetController.snapToPosition(
          SnappingPosition.factor(positionFactor: 0.75),);
      }
    };
    return Consumer<AuthRepository>(builder: (context, auth, child)
    {
      return Scaffold( // Add from here...
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushedSave,
              tooltip: 'Saved Suggestions',
            ),
            IconButton(
              icon: (auth.status == Status.Authenticated) ? const Icon(Icons.exit_to_app) : const Icon(Icons.login),
              onPressed: () {
                if (auth.status == Status.Authenticated) {
                  auth.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully logged out'),));
                  setState(() {_saved.clear();});
                } else {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen(),))
                        .then((value) {
                          setState((){
                            _saved.addAll(value);
                            firestore?.putSavedWordPairs(_saved);
                            _saved.forEach((element) {if (!_suggestions.contains(element)) _suggestions.insert(0, element);});
                          });});
                }
              },
              tooltip: 'Saved Suggestions',
            ),
          ],
        ),
        body: (auth.status == Status.Authenticated) ?
        Stack(children: [_buildSuggestions(), ProfileSheet(user: auth.user!),],) : _buildSuggestions(),
      );
    });
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return Consumer<AuthRepository>(builder: (context, auth, child)
    {
      return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.star : Icons.star_border,
          color: alreadySaved ? Colors.deepPurple : null,
          semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
        ),
        onTap: () {
            if (alreadySaved) {
              firestore?.removeSavedWordPair(pair);
                setState(() {_saved.remove(pair);});
            } else {
              firestore?.putSavedWordPair(pair);
                setState(() {_saved.add(pair);});
            }
        },
      );
    });
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }
/*
  Widget _buildStreamedSuggestions() {
    String? uid;
    if (Provider.of<AuthRepository>(context, listen: true).status == Status.Authenticated) uid = Provider.of<AuthRepository>(context, listen: false).user?.uid;
    print(uid);
    Stream<DocumentSnapshot>? userStream = ((Provider.of<AuthRepository>(context, listen: true).status == Status.Authenticated) && (uid != null)) ?
    FirebaseFirestore.instance.collection('users').doc(uid).snapshots() : null;
    return StreamBuilder<DocumentSnapshot>(
    stream: userStream,
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (Provider.of<AuthRepository>(context, listen: true).status == Status.Authenticated)
            snapshot.data!.get('saved_suggestions').forEach((pair_string) {
              print(pair_string);
              WordPair pair = WordPair(pair_string.split('_')[0], pair_string.split('_')[1]);
              if(!_suggestions.contains(pair)) _suggestions.add(pair);
              if(!_saved.contains(pair)) _saved.add(pair);});
          return _buildSuggestions();}
          );
  }
*/
  void _pushedSave(){
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
                (pair) {
              return Dismissible(
                  key: Key(pair.asPascalCase),
                  child: ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    ),
                  ),
                  confirmDismiss: (DismissDirection direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Delete suggestion"),
                          content: Text("Are you sure you want to delete ${pair.asPascalCase} from your saved suggestions?"),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  firestore?.removeSavedWordPair(pair);
                                  setState(() {_saved.remove(pair);});
                                  Navigator.of(context).pop(true);
                                  },
                                child: const Text("Yes")
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("No"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  background: Container(
                    color: Colors.deepPurple[300],
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          Text('Delete suggestion', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ));
              /*
                        return Slidable(
                          actionPane: SlidableScrollActionPane(key: Key(pair.asPascalCase)),
                          child: ListTile(
                          title: Text(
                            pair.asPascalCase,
                            style: _biggerFont,
                          ),
                        ),
                          actions: <Widget>[
                          IconSlideAction(
                          caption: 'Delete',
                            color: Colors.deepPurple[200],
                            icon: Icons.delete,
                            onTap: (){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Deletion is not implemented yet'),));
                            }),
                          ]
                        );
                        */
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}
