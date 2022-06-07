import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:homeapp/model/status.dart';
import 'package:homeapp/view/data_detail.dart';
import 'package:http/http.dart' as http;

class DashboardMain extends StatefulWidget {
  const DashboardMain({Key? key}) : super(key: key);

  @override
  State<DashboardMain> createState() => _DashboardMainState();
}

class _DashboardMainState extends State<DashboardMain> {
  // String host = "http://218.155.13.98:8888/api/homes/1";
  String host = "http://192.168.209.97:3000/api/homes/1";
  // String host = "http://localhost:3000/api/homes/1";
  Status status = Status();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 날씨가 담기는 부분
          Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(150),
                  bottomRight: Radius.circular(150)),
              color: Colors.blue,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<String>(
                      future: _fetchWeather(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!,
                              style: TextStyle(fontSize: 35));
                        } else {
                          return Text("날씨 가져오는 중...",
                              style: TextStyle(fontSize: 35));
                        }
                      }),
                  SizedBox(height: 15),
                  Text("수원시 장안구", style: TextStyle(fontSize: 25)),
                ],
              ),
            ),
          ),
          StreamBuilder<Object>(
              stream: _fetchData(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  status = Status.fromJson(snapshot.data.toString());
                }
                return circularIconDashboard(status, context);
              })
        ],
      ),
    );
  }

  Column circularIconDashboard(Status status, BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 230),
        Text("마지막 업데이트: " + status.timesAgo),
        SizedBox(height: 20),
        // 조도, 가스, 온도, 습도, 미세먼지, 동작감지...
        Container(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DataDetail(data: "gas", host: host))),
                    child: circularIconButton(
                        Colors.lightBlue[200]!,
                        Icons.whatshot,
                        Colors.white,
                        "가스",
                        status.gas.toString()),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DataDetail(data: "temperature", host: host))),
                    child: circularIconButton(
                        Colors.lightBlue[200]!,
                        Icons.thermostat,
                        Colors.white,
                        "온도",
                        status.temperature.toString()),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DataDetail(data: "humidity", host: host))),
                    child: circularIconButton(
                        Colors.lightBlue[200]!,
                        Icons.opacity,
                        Colors.white,
                        "습도",
                        status.humidity.toString()),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text("미세먼지 상세정보"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("PM 1.0: " + status.pm1p0.toString()),
                                  Text("PM 2.5: " + status.pm2p5.toString()),
                                  Text("PM 10: " + status.pm10.toString())
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('확인'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            )),
                    child: circularIconButton(
                        Colors.lightBlue[200]!,
                        Icons.masks,
                        Colors.white,
                        "미세먼지",
                        status.pm2p5.toString()),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text("팬을 강제로 작동할까요?"),
                              actions: [
                                TextButton(
                                  child: const Text('환기'),
                                  onPressed: () async {
                                    http.Response strResponse = await http.put(
                                        Uri.parse(host),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: json.encode({
                                          'home': {
                                            'serial_number': 'abc',
                                            'fan_force': 1
                                          }
                                        }));
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('냉방'),
                                  onPressed: () async {
                                    http.Response strResponse = await http.put(
                                        Uri.parse(host),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: json.encode({
                                          'home': {
                                            'serial_number': 'abc',
                                            'fan_force': -1
                                          }
                                        }));
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('팬 끄기'),
                                  onPressed: () async {
                                    http.Response strResponse = await http.put(
                                        Uri.parse(host),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: json.encode({
                                          'home': {
                                            'serial_number': 'abc',
                                            'fan_force': 0
                                          }
                                        }));
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('자동'),
                                  onPressed: () async {
                                    http.Response strResponse = await http.put(
                                        Uri.parse(host),
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: json.encode({
                                          'home': {
                                            'serial_number': 'abc',
                                            'fan_force': 2
                                          }
                                        }));
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            )),
                    child: circularIconButton(Colors.lightBlue[200]!, Icons.air,
                        Colors.white, "팬 동작", status.fanForceToString()),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                        children: [
                          InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DataDetail(data: 'gas', host: host))),
                              child: Card(
                                  child: ListTile(title: Text("가스 자세히 보기")))),
                          InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DataDetail(
                                          data: 'temperature', host: host))),
                              child: Card(
                                  child: ListTile(title: Text("온도 자세히 보기")))),
                          InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DataDetail(
                                          data: 'humidity', host: host))),
                              child: Card(
                                  child: ListTile(title: Text("습도 자세히 보기")))),
                          InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DataDetail(
                                          data: 'pm2p5', host: host))),
                              child: Card(
                                  child: ListTile(title: Text("미세먼지 자세히 보기")))),
                        ],
                      )),
              child: Container(
                width: MediaQuery.of(context).size.width / 2 - 40,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.lightBlue[100],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.insights,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "데이터 모아보기",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(width: 25),
            InkWell(
              onTap: _callNumber,
              child: Container(
                width: MediaQuery.of(context).size.width / 2 - 40,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(children: [
                  Icon(
                    Icons.local_hospital,
                    size: 50,
                    color: Colors.red,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "비상연락",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ]),
              ),
            ),
          ],
        )
      ],
    );
  }

  Column circularIconButton(Color bgColor, IconData icon, Color iconColor,
      String describe, String data) {
    return Column(
      children: [
        ClipOval(
          child: Container(
            width: 90,
            height: 90,
            color: bgColor,
            child: Icon(
              icon,
              size: 75,
              color: iconColor,
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(describe,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(data),
      ],
    );
  }

  Stream<String> _fetchData() async* {
    while (true) {
      http.Response response = await http.get(Uri.parse(host));
      yield response.body;
      sleep(Duration(seconds: 3));
    }
  }

  Future _callNumber() async {
    const number = '01028276811'; //set the number here
    bool? res = await FlutterPhoneDirectCaller.callNumber(number);
    print(res);
  }

  Future<String> _fetchWeather() async {
    String host =
        "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?";

    String nx = dotenv.env['NX'].toString();
    String ny = dotenv.env['NY'].toString();
    String openApiKey = dotenv.env['API_KEY'].toString();

    DateTime _baseDateTime = DateTime.now().subtract(Duration(hours: 1));

    String thisYear = _baseDateTime.year.toString();
    String thisMonth = _baseDateTime.month.toString();
    String thisDay = _baseDateTime.day.toString();

    String _baseHour = _baseDateTime.hour.toString();
    String baseTime = "0" * (2 - _baseHour.length) + _baseHour + "00";

    host = host +
        'serviceKey=' +
        openApiKey +
        '&pageNo=1' +
        '&numOfRows=100' +
        '&dataType=JSON' +
        '&base_date=' +
        thisYear +
        "0" * (2 - thisMonth.length) +
        thisMonth +
        "0" * (2 - thisDay.length) +
        thisDay +
        '&base_time=' +
        baseTime +
        '&nx=' +
        nx +
        '&ny=' +
        ny;

    http.Response strResponse = await http.get(Uri.parse(host));
    Map response = json.decode(strResponse.body);
    String _weatherReport = "";
    String _temperature = "";
    String _amount = "";
    response['response']['body']['items']['item'].forEach((e) {
      print(e['category']);

      switch (e['category']) {
        case "PTY": // 강수형태
          // 없음(0), 비(1), 비/눈(2), 눈(3), 빗방울(5), 빗방울눈날림(6), 눈날림(7)
          switch (e['obsrValue']) {
            case "0":
              _weatherReport = "맑음 ☀️";
              break;
            case "1":
              _weatherReport = "비 🌧️";
              break;
            case "2":
              _weatherReport = "비 또는 눈 ☂️";
              break;
            case "3":
              _weatherReport = "눈 🌨️";
              break;
            case "5":
              _weatherReport = "빗방울💦";
              break;
            case "6":
              _weatherReport = "진눈깨비 ☂️";
              break;
            case "7":
              _weatherReport = "눈날림 ❄️";
              break;
            default:
              _weatherReport = "날씨 정보 수신 실패";
          }
          break;
        case "REH": // 습도
          print(e['obsrValue']);
          break;
        case "RN1": // 1시간 강수량
          _amount = e['obsrValue'] + "mm";
          print(e['obsrValue']);
          break;
        case "T1H": // 기온
          _temperature = e['obsrValue'] + "℃, ";
          break;
        case "UUU": // 동서바람성분
          print(e['obsrValue']);
          break;
        case "VEC": // 풍향
          print(e['obsrValue']);
          break;
        case "VVV": // 남북바람성분
          print(e['obsrValue']);
          break;
        case "WSD": // 풍속
          print(e['obsrValue']);
          break;
        default:
          print("카테고리: " + e['category']);
          print("값: " + e['obsrValue']);
          break;
      }
    });

    return _weatherReport + "\n" + _temperature + _amount;
  }
}
