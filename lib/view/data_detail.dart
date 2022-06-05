import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataDetail extends StatefulWidget {
  const DataDetail({Key? key, required this.data, required this.host})
      : super(key: key);
  final String data;
  final String host;

  @override
  State<DataDetail> createState() => _DataDetailState();
}

class _DataDetailState extends State<DataDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<String>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data!);
          } else {
            return Text(snapshot.error.toString());
          }
        },
      ),
    );
  }

  Future<String> _fetchData() async {
    String host = widget.host + "?detail=" + widget.data;

    http.Response response = await http.get(Uri.parse(host));
    return response.body;
  }
}
