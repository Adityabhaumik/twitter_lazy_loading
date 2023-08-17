import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:random_x/random_x.dart';
import 'package:twitter_infinite_scroll/providers/app_base_provider.dart';
import 'package:twitter_infinite_scroll/ui_elements/custome_card.dart';

class HomeScreen extends StatefulWidget {
  static const id = "HomeScreen";

  const HomeScreen

  ({
  super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    final appBaseProvider = Provider.of<AppBaseProvider>(context, listen: false);
    appBaseProvider.fetchData();
    super.initState();
    scrollController.addListener(() {
      appBaseProvider.scrollListener(scrollController);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final appBaseProvider = Provider.of<AppBaseProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Twitter Infinite scroll",
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: appBaseProvider.getFetchingStatus
              ? LinearProgressIndicator(
            backgroundColor: Colors.red.withOpacity(0.7),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
          )
              : const SizedBox(),
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == "Ascending") {
                appBaseProvider.sortAscending();
              } else if (value == "Descending") {
                appBaseProvider.sortDescending();
              } else {
                _showRadioPopup(context, appBaseProvider);
              }
            },
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem(
                  value: 'Ascending',
                  child: Text('Sort Ascending'),
                ),
                PopupMenuItem(
                  value: 'Descending',
                  child: Text('Sort Descending'),
                ),
                PopupMenuItem(
                  value: 'Filter',
                  child: Text('Filter'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<String>>(
            stream: appBaseProvider.dataStream,
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  reverse: !appBaseProvider.sortAscendingStatus,
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data![index];
                    if (appBaseProvider.filter == Filter.odd) {
                      if ((index + 1) % 2 != 0) {
                        return TwitterPost(
                          username: RndX.generateName(),
                          content: post,
                          id: (index + 1).toString(),
                        );
                      } else {
                        return const SizedBox();
                      }
                    } else if (appBaseProvider.filter == Filter.even) {
                      if ((index + 1) % 2 == 0) {
                        return TwitterPost(
                          username: RndX.generateName(),
                          content: post,
                          id: (index + 1).toString(),
                        );
                      } else {
                        return const SizedBox();
                      }
                    } else {
                      return TwitterPost(
                        username: RndX.generateName(),
                        content: post,
                        id: (index + 1).toString(),
                      );
                    }
                  },
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error"));
              }
              return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black54,
                  ));
            }),
      ),
    );
  }

  void _showRadioPopup(BuildContext context, AppBaseProvider appBaseProvider) {
    String _selectedOption = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select an Option'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: Text('Even'),
                    value: 'Even',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value ?? "Even";
                      });
                      //appBaseProvider.changeFilterStatus(Filter.even);
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Odd'),
                    value: 'Odd',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value ?? "Odd";
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('None'),
                    value: 'none',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value ?? "None";
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    if (_selectedOption == "Even") {
                      appBaseProvider.changeFilterStatus(Filter.even);
                    } else if (_selectedOption == "Odd") {
                      appBaseProvider.changeFilterStatus(Filter.odd);
                    } else {
                      appBaseProvider.changeFilterStatus(Filter.none);
                    }
                    Navigator.pop(context);
                    print('Selected: $_selectedOption');
                  },
                  child: Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
