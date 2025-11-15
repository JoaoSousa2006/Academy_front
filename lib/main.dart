import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
} //Informa o flutter para executar o app definido em MyApp

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  //Widgets são base da criação de interfaces no Flutter
  Widget build(BuildContext context) { //Método build descreve como construir a interface
    return ChangeNotifierProvider( //Fornece uma instância de MyAppState para toda a árvore de widgets
      create: (context) => MyAppState(),
      child: MaterialApp(//tema principal previamente definido
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true, //Habilita o Material Design 3, um "css" basico para estilização
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), //Define a paleta de cores do app autoamaticamente baseado em uma cor principal
        ),
        home: MyHomePage(),//Define qual a tela inicial do app
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {//Gerencia mudanças de estado no app e notifica os widgets que dependem desse estado
  var current = WordPair.random();//Gera um par de palavras aleatórias

  void getNext() {
    current = WordPair.random();//Gera um novo par de palavras aleatórias
    notifyListeners();//Notifica todos os ouvintes que o estado mudou, fazendo com que widgets dependentes sejam reconstruídos
  }

  var favorites = <WordPair>[];//Lista para armazenar pares de palavras favoritos

  void toggleFavorite() {//Adiciona ou remove o par de palavras atual da lista de favoritos
    if (favorites.contains(current)) {//Verifica se o par atual já está na lista de favoritos
      favorites.remove(current);//Se estiver, remove-o
    } else {
      favorites.add(current);//Se não estiver, adiciona-o
    }
    notifyListeners();//Notifica os ouvintes sobre a mudança no estado
  }
}

class MyHomePage extends StatefulWidget {  //Widget que representa a tela principal do app
  @override
  State<MyHomePage> createState() => _MyHomePageState();//Cria o estado associado ao MyHomePage
}

class _MyHomePageState extends State<MyHomePage> {//Tela principal do app
  var selectedIndex = 0;//Índice do item atualmente selecionado na barra de navegação

  @override
  Widget build(BuildContext context) {//Método build que descreve como construir a interface do MyHomePage
    Widget page;//Declaração de uma variável para armazenar o widget da página atual
  switch (selectedIndex) {//Seleciona o widget da página com base no índice selecionado
    case 0:
      page = GeneratorPage();
      break;
    case 1:
      page = FavoritesPage();
      break;
    default:
      throw UnimplementedError('no widget for $selectedIndex');
  }


    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(//Widget que fornece uma estrutura básica para a tela, incluindo app bar, corpo, etc.
          body: Row(//Organiza os widgets filhos em uma linha horizontal
            children: [//Lista de widgets filhos do Row
              SafeArea(//Garante que o conteúdo não seja sobreposto por áreas do sistema, como entalhes ou barras de status
                child: NavigationRail(//Barra de navegação lateral para facilitar a navegação entre diferentes seções do app
                  extended: constraints.maxWidth >=600,//Define se a barra de navegação deve ser expandida ou não
                  destinations: [//Lista de destinos na barra de navegação
                    NavigationRailDestination(
                      icon: Icon(Icons.home),//Ícone para o destino "Home"
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),//Ícone para o destino "Favorites"
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,//Índice do destino atualmente selecionado
                  onDestinationSelected: (value) {//Callback quando um destino é selecionado
                    setState(() {//Atualiza o estado do widget
                      selectedIndex = value;//Define o índice selecionado para o valor escolhido
                    });
                  },
                ),
              ),
              Expanded(//Expande o widget filho para preencher o espaço disponível na direção principal (horizontal no caso do Row)
                child: Container(//Container que envolve o widget filho e aplica decoração
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,//Exibe a página atual com base no índice selecionado
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {//Widget que exibe o par de palavras atual e botões para interagir com ele
  @override
  Widget build(BuildContext context) {//Método build que descreve como construir a interface do GeneratorPage
    var appState = context.watch<MyAppState>();//Obtém o estado atual do app usando o Provider para ouvir mudanças
    var pair = appState.current;//Obtém o par de palavras atual do estado do app

    IconData icon;//Declaração de uma variável para armazenar o ícone a ser exibido no botão de favorito
    if (appState.favorites.contains(pair)) {//Verifica se o par atual está na lista de favoritos
      icon = Icons.favorite;//Se estiver, usa o ícone de favorito preenchido
    } else {
      icon = Icons.favorite_border;//Se não estiver, usa o ícone de favorito contornado
    }

    return Center(//Centraliza o conteúdo dentro do widget pai
      child: Column(//Organiza os widgets filhos em uma coluna vertical
        mainAxisAlignment: MainAxisAlignment.center,//Centraliza os widgets filhos verticalmente
        children: [//Lista de widgets filhos do Column
          BigCard(pair: pair),
          SizedBox(height: 10),//Adiciona um espaço vazio entre elementos. Usado pra espaçamento
          Row(//Organiza os widgets filhos em uma linha horizontal
            mainAxisSize: MainAxisSize.min,//Define o tamanho principal do Row como mínimo, ou seja, apenas o suficiente para conter seus filhos
            children: [
              ElevatedButton.icon(//Botão elevado com ícone e texto
                onPressed: () {
                  appState.toggleFavorite();//Chama o método para adicionar ou remover o par atual dos favoritos
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),//Adiciona um espaço vazio entre os botões
              ElevatedButton(
                onPressed: () {
                  appState.getNext();//Chama o método para gerar um novo par de palavras
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {//Widget separado e personalizado que exibira um par de palavras
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;//Declaração de uma variável final que armazenará o par de palavras

  @override
  Widget build(BuildContext context) {//Método build que descreve como construir a interface do BigCard
    final theme = Theme.of(context);//Obtém o tema atual do app para estilização consistente sem ter que alterar tudo um por um
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );//Define o estilo do texto baseado no tema atual, ajustando a cor para garantir contraste com o fundo
    
    return Card(//Widget de cartão que fornece uma aparência elevada e com bordas arredondadas
      color: theme.colorScheme.primary,//Define a cor de fundo do cartão usando a cor primária do tema
      child: Padding(//Adiciona espaçamento ao redor do widget filho
        padding: const EdgeInsets.all(20.0),//Define o padding. all aplica igualmente em todos os lados. 
        //EdgeInsets é uma classe que define espaçamentos. Valores em pixels entre parenteses.
        child: //Define o que é afetado pelo padding.
        Text(pair.asLowerCase, //Exibe o par de palavras em letras minúsculas
        style: style, //Aplica o estilo definido anteriormente ao texto
        semanticsLabel: "${pair.first} ${pair.second}", //Fornece uma descrição acessível do texto para leitores de tela
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {//Widget que exibe a lista de pares de palavras favoritos
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();//Obtém o estado atual do app usando o Provider para ouvir mudanças

    if (appState.favorites.isEmpty) {//Verifica se a lista de favoritos está vazia
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(//Exibe uma lista rolável de widgets
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)//Itera sobre cada par de palavras na lista de favoritos
          ListTile(
            leading: Icon(Icons.favorite),//Ícone de favorito ao lado do texto
            title: Text(pair.asLowerCase),//Exibe o par de palavras em letras minúsculas
          ),
      ],
    );
  }
}