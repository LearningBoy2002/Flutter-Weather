import 'dart:async';
import 'dart:convert';
import 'package:f2/data/models/city_model.dart';
import 'package:f2/data/models/data_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final String cityName;
  const HomeScreen({Key? key, required this.cityName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? cityName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getdata();
    /* Timer(Duration(seconds: 5), () {
      print("Timer ends");
      _isLoading = false;
      setState(() {});
    }); */
  }

  DataModel? dataFromAPI;
  cityModel? cityDataFromAPI;

  _getdata() async {
    String url =
        "https://geocoding-api.open-meteo.com/v1/search?name=widget.cityName";
    http.Response res = await http.get(Uri.parse(url));
    cityDataFromAPI = cityModel.fromJson(json.decode(res.body));

    double latitude = cityDataFromAPI!.results![0].latitude!.toDouble();
    double longitude = cityDataFromAPI!.results![0].longitude!.toDouble();

    url =
        "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m";
    res = await http.get(Uri.parse(url));
    dataFromAPI = DataModel.fromJson(json.decode(res.body));
    //debugPrint(dataFromAPI.hourlyUnits!.temperature2m);
    _isLoading = false;
    setState(() {});
  }

  //final List _newList = ['Brazil', 'Russia', 'India', 'China', 'South Africa'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
      ),
      //  body: Center(
      //  child: _isLoading
      //   ? const CircularProgressIndicator()
      //   : Center(
      //   child: Image.network(
      //      "https://images.unsplash.com/photo-1551281306-0d52288970ad?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
      //     ),

      // body: ListView.builder(
      //   scrollDirection: Axis.horizontal,
      //   itemBuilder: (context, index) => Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Text(
      //       _newList[index],
      //     ),
      //   ),
      //   itemCount: _newList.length,
      // ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                DateTime temp =
                    DateTime.parse(dataFromAPI!.hourly!.time![index]);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Text(DateFormat('dd-MM-yyyy HH:mm a').format(temp)),
                    const Spacer(),
                    Text(dataFromAPI!.hourly!.temperature2m![index].toString())
                  ]),
                );
              },
              itemCount: dataFromAPI!.hourly!.time!.length,
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Button is Pressed");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
