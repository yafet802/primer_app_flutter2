import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier{
  var current = WordPair.random();

  var favoritos = <WordPair> [];

  var historial = <WordPair> [];

  GlobalKey? histotialListKey;

  void getSiguiente () {
    historial.insert(0, current);
    current = WordPair.random();
    var animatedList = histotialListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    notifyListeners();
  } 

  void toggleFavorito(WordPair? idea){
    idea = idea?? current;
    if(favoritos.contains(idea)){
      favoritos.remove(idea);
    } else {
      favoritos.add(idea);
    }
    notifyListeners();
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;
  
  @override
  Widget build(BuildContext context){
    
    Widget page;

    switch (selectedIndex) {
      case 0: page = GeneratorPage(); break;
      case 1: page = FavoritosPage(); break;    
      default:
        throw UnimplementedError('No hay un widget para: $selectedIndex');
    }  

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Inicio')
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favoritos')
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                )
              )
            ],
          )
        );
      }
    );
  }
}


class BigCard extends StatelessWidget {
  final WordPair idea;
  const BigCard({
    super.key,
    required this.idea
  });


  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textStyle = tema.textTheme.displayMedium!.copyWith(color:  tema.colorScheme.onPrimary);


    return Card(
      color: tema.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          idea.asLowerCase,
          style: textStyle,
          semanticsLabel: "${idea.first} ${idea.second}", //se leera la palabra
        ),


      ),
    );
  }
}


class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});


  @override
  Widget build(BuildContext context) {
   
    var appState = context.watch<MyAppState>();
    var idea = appState.current;
    IconData icon;


     if(appState.favoritos.contains(idea)){
        icon = Icons.favorite;  
     } else {
        icon = Icons.favorite_border_outlined;
     }
   
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 3, child: HistotialListView()),
            SizedBox(height: 20),
            BigCard(idea: appState.current),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(onPressed: () {
                  appState.toggleFavorito(idea);
                },
                icon: Icon(icon),
                label: Text('Me Gusta'),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(onPressed: () {
                  appState.getSiguiente();
                },
                child: Text('Siguiente'),
                ),
              ],
            ),
            Spacer(flex: 2)
          ],
        ),
      );
  }
}

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    if (appState.favoritos.isEmpty){
      return Center(child: Text('Aun no hay fa0voritos'));
    }

    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Se han elegido ${appState.favoritos.length} favoritos'),
        ),

        for (var name in appState.favoritos)
        ListTile(
            leading: Icon(Icons.favorite),
            title: Text(name.asLowerCase),
        ),
      ],
    );
  }
}

class HistotialListView extends StatefulWidget {
  const HistotialListView({Key? key}) : super(key: key);

  @override
  State<HistotialListView> createState() => _HistotialListViewState();
}

class _HistotialListViewState extends State<HistotialListView> {

  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {

    final appState = context .watch<MyAppState>();
    appState.histotialListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100.0),
        initialItemCount: appState.historial.length,
        itemBuilder: (context, index, animation) {
          final idea = appState.historial[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorito(idea);
                },
                icon: appState.favoritos.contains(idea) ? Icon(Icons.favorite, size: 12.0) : SizedBox(), 
                label: Text(
                  idea.asLowerCase,
                  semanticsLabel: idea.asPascalCase
                ),
              ),
            ), 
          );
        }
      ),
    );
  }
}


