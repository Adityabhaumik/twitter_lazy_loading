import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

enum Filter { odd, even, none }

class AppBaseProvider extends ChangeNotifier {
  final _dataController = StreamController<List<String>>();

  Stream<List<String>> get dataStream => _dataController.stream;
  final List<String> _posts = [];
  bool _sortAscending = true;
  bool _isFetching = false;
  Filter _filter = Filter.none;

  Filter get filter => _filter;

  bool get sortAscendingStatus => _sortAscending;

  bool get getFetchingStatus => _isFetching;

  void _changeIsFetchingState(bool state) {
    _isFetching = state;
    notifyListeners();
  }

  void scrollListener(ScrollController scrollController) async {
    if (scrollController.position.maxScrollExtent == scrollController.position.pixels && _isFetching == false) {
      _changeIsFetchingState(true);
      await fetchData();
      _changeIsFetchingState(false);
    }
  }

  Future<void> fetchData() async {
    try {
      const url = 'https://baconipsum.com/api/?type=meat-and-filler';
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        _posts.addAll(jsonData.cast<String>());
        _dataController.add(_posts);
      }
    } catch (e) {
      _dataController.addError('Failed to fetch Data.');
    }
  }

  void sortAscending() {
    _sortAscending = true;
    notifyListeners();
  }

  void sortDescending() {
    _sortAscending = false;
    notifyListeners();
  }

  void changeFilterStatus(Filter type) {
    _filter = type;
    //print("called notify listners ${_filter}");
    notifyListeners();
  }
}
