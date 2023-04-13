import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'dart:io';

// 192.168.10.30
// 192.168.10.30
class PlugController extends GetxController {
  var _pluglist = [].obs;
  RxList sensor_data = [].obs;
  Map _sensor_map = {};
  var dataset_index = 0.obs;
  // String pub_ip = '192.168.0.108:51213';
  // String pub_ip = '192.168.10.30:51213';
  // 192.168.10.30:51213
  String sensor_dataset_Url = "http://192.168.10.30:51213/mean_data";
  RxList get pluglist => _pluglist;

  Map get sensor_map => _sensor_map;

  add_plug(String user_id, String ip, String name, String sensornum,
      String typeagent, String ruleset) async {
    // SmartPlug plug = SmartPlug();
    // plug.name = name;
    // plug.sensornum = sensornum;
    String addUrl =
        "http://192.168.10.30:51213/add_plug?ip=${ip}&user_id=${user_id}&plug_name=${name}&sensornum=${sensornum}&type_agent=${typeagent}&ruleset=${ruleset}";
    print(addUrl);
    await http.get(Uri.parse(addUrl), headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    }).then((Response) {
      if (Response.statusCode == 200) {
        SmartPlug plug = SmartPlug();
        _pluglist.add(plug);

        set_plug_list(user_id);
      } else {
        Get.dialog(AlertDialog(
          title: const Text('주의'),
          content: const Text('IP 주소가 올바르지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("확인"),
            )
          ],
        ));
      }
    }).catchError((err) => print(err));
    // _pluglist.add(plug);
  }

  remove_plug(String user_id, String ip, String name) async {
    String removeUrl =
        "http://192.168.10.30:51213/remove_plug?ip=${ip}&user_id=${user_id}&plug_name=${name}";
    await http.get(Uri.parse(removeUrl), headers: {
      "Access-Control_Allow_Origin": "*",
      "Access-Control_Allow_Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    }).then((Response) {
      if (Response.statusCode == 200) {
        for (int i = 0; i < _pluglist.length; i++) {
          if (_pluglist[i].ip == ip) {
            _pluglist.removeAt(i);
            break;
          }
        }
        // set_plug_list(user_id);
      } else {
        Get.dialog(AlertDialog(
          title: const Text('주의'),
          content: const Text('IP 주소가 올바르지 않습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("확인"),
            )
          ],
        ));
      }
    });
  }

  set_plug_list(String user_id) async {
    String plug_list_Url =
        "http://192.168.10.30:51213/road_plug?user_id=${user_id}";

    await http.get(
      Uri.parse(plug_list_Url),
      headers: {
        "Access-Control_Allow_Origin": "*",
        "Access-Control_Allow_Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
      },
    ).then((Response) {
      if (Response.statusCode == 200) {
        // _pluglist.clear();
        if (_pluglist.isEmpty) {
          for (int i = 0; i < jsonDecode(Response.body)['ip'].length; i++) {
            SmartPlug plug = SmartPlug();
            // SmartPlug plug = _pluglist[i];
            plug.name = jsonDecode(Response.body)['plug_name']['$i'];
            plug.ip = jsonDecode(Response.body)['ip']['$i'];
            plug.onoffstate.value = jsonDecode(Response.body)['on_state']['$i'];
            plug.rulebasestate.value =
                jsonDecode(Response.body)['rulebase']['$i'];
            plug.ruleset.value = jsonDecode(Response.body)['ruleset']['$i'];
            plug.sensornum = '${jsonDecode(Response.body)['sensornum']['$i']}';
            plug.typeagent = jsonDecode(Response.body)['type_agent']['$i'];
            plug.schedule.value = jsonDecode(Response.body)['schedule']['$i'];
            if (plug.rulebasestate.value == 0) {
              _pluglist.add(plug);
            } else {
              // 기존에 룰베이스 켜져있던 플러그 다시 호출해서 실시간데이터 받기, 서버단에서는 이미 룰베이스 켜져있을경우
              // 조건문처리해서 중복실행 안되도록 설정했음
              plug.rule_base_on(user_id);
              _pluglist.add(plug);
            }
          }
        } else {
          for (int i = 0; i < jsonDecode(Response.body)['ip'].length; i++) {
            // SmartPlug plug = SmartPlug();
            SmartPlug plug = _pluglist[i];
            plug.name = jsonDecode(Response.body)['plug_name']['$i'];
            plug.ip = jsonDecode(Response.body)['ip']['$i'];
            plug.onoffstate.value = jsonDecode(Response.body)['on_state']['$i'];
            plug.rulebasestate.value =
                jsonDecode(Response.body)['rulebase']['$i'];
            plug.ruleset.value = jsonDecode(Response.body)['ruleset']['$i'];
            plug.sensornum = '${jsonDecode(Response.body)['sensornum']['$i']}';
            plug.typeagent = jsonDecode(Response.body)['type_agent']['$i'];
            plug.schedule.value = jsonDecode(Response.body)['schedule']['$i'];
          }
        }
      }
    });
  }

  load_data() async {
    await http.get(Uri.parse(sensor_dataset_Url), headers: {
      "Access-Control_Allow_Origin": "*",
      "Access-Control_Allow_Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    }).then((Response) {
      if (Response.statusCode == 200) {
        sensor_data.add(jsonDecode(Response.body));
        sensor_data.value[0].forEach((k, v) {
          List<double> co2_list = [];
          List<double> pm_list = [];
          List<double> temp_list = [];
          List<DateTime> time_list = [];

          Map r_data = jsonDecode(v);

          for (int i = 0; i < r_data.length; i++) {
            if (r_data[r_data.keys.toList()[i]]['co2'] != null) {
              co2_list.add(double.parse(
                  r_data[r_data.keys.toList()[i]]['co2'].toStringAsFixed(2)));
              pm_list.add(double.parse(
                  r_data[r_data.keys.toList()[i]]['pm'].toStringAsFixed(2)));
              temp_list.add(double.parse(
                  r_data[r_data.keys.toList()[i]]['temp'].toStringAsFixed(2)));
              time_list.add(DateTime.parse(r_data.keys.toList()[i]));
            }
          }
          _sensor_map[k] = {
            'co2': co2_list,
            'pm': pm_list,
            'temp': temp_list,
            'time': time_list,
          };
        });
        dataset_index.value = 1;

        // print(sensor_data.value[0]['거실']);
        // null인 값은 빼고 리스트 만들기
        // sensor_data.value[0].forEach((k, v) {
        //   _sensor_map[k] = {
        //     'co2': jsonDecode(v).entries.map<double>((e) {
        //       // return double.parse(e.value['co2']);
        //       if (e.value['co2'] != null) {
        //         return double.parse(e.value['co2'].toStringAsFixed(2));
        //       } else {
        //         return null;
        //       }
        //     }).toList(),
        //     'pm': jsonDecode(v).entries.map<double>((e) {
        //       if (e.value['pm'] != null) {
        //         return double.parse(e.value['pm'].toStringAsFixed(2));
        //       } else {
        //         return null;
        //       }
        //     }).toList(),
        //     'temp': jsonDecode(v).entries.map<double>((e) {
        //       if (e.value['temp'] != null) {
        //         return double.parse(e.value['temp'].toStringAsFixed(2));
        //       } else {
        //         return null;
        //       }
        //     }).toList(),
        //     'time': jsonDecode(v).entries.map<DateTime>((e) {
        //       return DateTime.parse(e.key);
        //     }).toList(),
        //   };
        // });
        // dataset_index.value = 1;
      } else {}
    });
  }

  set_alarm(
      String user_id, String ip, String start, String end, String state) async {
    // SmartPlug plug = SmartPlug();
    // plug.name = name;
    // plug.sensornum = sensornum;
    String alarmUrl =
        "http://192.168.10.30:51213/rulebase_schedule?ip=${ip}&user_id=${user_id}&start=${start}&end=${end}&state=${state}";
    print(alarmUrl);
    await http.get(Uri.parse(alarmUrl), headers: {
      "Access-Control_Allow_Origin": "*",
      "Access-Control_Allow_Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    }).then((Response) {
      if (Response.statusCode == 200) {
        print('알람ok');
      } else {}
    }).catchError((err) => print(err));
    // _pluglist.add(plug);
  }
}

class SmartPlug extends GetxController {
  String ip = '';
  String name = '';
  RxBool onoffstate = false.obs;
  RxInt rulebasestate = 0.obs;
  RxInt ruleset = 1000.obs;
  String sensornum = '';
  RxString sensorval = ''.obs;
  String typeagent = '';
  RxInt schedule = 0.obs;

  turn_on(String user_id) async {
    String onUrl = "http://192.168.10.30:51213/on?ip=${ip}&user_id=${user_id}";
    await http.get(Uri.parse(onUrl), headers: {
      "Access-Control_Allow_Origin": "*",
      "Access-Control_Allow_Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    }).then((Response) {
      Response.statusCode == 200 ? onoffstate.value = true : null;
    });
  }

  turn_off(String user_id) async {
    String offUrl =
        "http://192.168.10.30:51213/off?ip=${ip}&user_id=${user_id}";
    await http.get(Uri.parse(offUrl), headers: {
      "Access-Control_Allow_Origin": "*",
      "Access-Control_Allow_Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    }).then((Response) {
      Response.statusCode == 200 ? onoffstate.value = false : null;
    });
  }

  rule_base_on(String user_id) async {
    String rulebaseonUrl =
        "http://192.168.10.30:51213/rule_base_on?ip=${ip}&user_id=${user_id}";

    var request = http.Request(
      'GET',
      Uri.parse(rulebaseonUrl),
    );
    var streamedResponse = await request.send();
    var responseString = streamedResponse.stream.listen((Value) {
      sensorval.value = utf8.decode(Value);
      if (sensorval.value.length > 20) {
        rulebasestate.value = 0;
        Get.dialog(AlertDialog(
          title: const Text('주의'),
          content: const Text('최신 데이터 불러오기를 실패했습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("확인"),
            )
          ],
        ));
      }
      ruleset.value < double.parse(sensorval.value)
          ? onoffstate.value = true
          : onoffstate.value = false;
    });
  } // # http://192.168.10.30:51213/rule_base_on?ip=192.168.0.118&user_id=ehrnc

  rule_base_off(String user_id) async {
    String rulebaseonUrl =
        "http://192.168.10.30:51213/rule_base_off?ip=${ip}&user_id=${user_id}";
    await http.get(Uri.parse(rulebaseonUrl), headers: {
      "Access-Control_Allow_Origin": "*",
      "Access-Control_Allow_Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    }).then((Response) {
      Response.statusCode == 200 ? rulebasestate.value = 0 : null;
    });

    // http://192.168.10.30:51213/rule_base_off?ip=192.168.0.118&user_id=ehrnc
  }

  rule_base_on2(String user_id) async {
    String rulebaseonUrl2 =
        "http://192.168.10.30:51213/rule_base_on2?ip=${ip}&user_id=${user_id}";
    await http.get(Uri.parse(rulebaseonUrl2), headers: {
      "Access-Control_Allow_Origin": "*",
      "Access-Control_Allow_Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    }).then((Response) {
      Response.statusCode == 200 ? print('ok루프시작') : null;
    });
  }
}

class LoginController extends GetxController {
  var login_index = 0.obs;
  RxDouble op = 0.001.obs;
  adt_opc() async {
    int i = 0;
    while (i < 100) {
      i++;
      op.value = i / 100;
      // sleep(const Duration(milliseconds: 10));
    }
    login_index.value = 1;
    print(login_index.value);
  }
}
