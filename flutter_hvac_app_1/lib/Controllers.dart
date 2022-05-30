import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlugController extends GetxController {
  var _pluglist = [].obs;

  var dataset_index = 0.obs;
  String sensor_dataset_Url = "http://222.108.71.247:51213/mean_data";
  RxList get pluglist => _pluglist;
  String pub_ip = '222.108.71.247:51213';

  add_plug(String user_id, String ip, String name, String sensornum,
      String typeagent, String ruleset) async {
    // SmartPlug plug = SmartPlug();
    // plug.name = name;
    // plug.sensornum = sensornum;
    String addUrl =
        "http://222.108.71.247:51213/add_plug?ip=${ip}&user_id=${user_id}&plug_name=${name}&sensornum=${sensornum}&type_agent=${typeagent}&ruleset=${ruleset}";
    print(addUrl);
    await http.get(Uri.parse(addUrl),
        headers: {"Access-Control_Allow_Origin": "*"}).then((Response) {
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
        "http://222.108.71.247:51213/remove_plug?ip=${ip}&user_id=${user_id}&plug_name=${name}";
    await http.get(Uri.parse(removeUrl),
        headers: {"Access-Control_Allow_Origin": "*"}).then((Response) {
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
        "http://222.108.71.247:51213/road_plug?user_id=${user_id}";

    await http.get(
      Uri.parse(plug_list_Url),
      headers: {"Access-Control_Allow_Origin": "*"},
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
            if (plug.rulebasestate.value == 0) {
              _pluglist.add(plug);
            } else {
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
          }
        }
      }
    });
  }

  load_data() async {
    await http.get(Uri.parse(sensor_dataset_Url),
        headers: {"Access-Control_Allow_Origin": "*"}).then((Response) {
      Response.statusCode == 200 ? dataset_index.value = 1 : null;
      print('okokok');
      print(jsonDecode(Response.body));
    });
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

  turn_on(String user_id) async {
    String onUrl = "http://222.108.71.247:51213/on?ip=${ip}&user_id=${user_id}";
    await http.get(Uri.parse(onUrl),
        headers: {"Access-Control_Allow_Origin": "*"}).then((Response) {
      Response.statusCode == 200 ? onoffstate.value = true : null;
    });
  }

  turn_off(String user_id) async {
    String offUrl =
        "http://222.108.71.247:51213/off?ip=${ip}&user_id=${user_id}";
    await http.get(Uri.parse(offUrl),
        headers: {"Access-Control_Allow_Origin": "*"}).then((Response) {
      Response.statusCode == 200 ? onoffstate.value = false : null;
    });
  }

  rule_base_on(String user_id) async {
    String rulebaseonUrl =
        "http://222.108.71.247:51213/rule_base_on?ip=${ip}&user_id=${user_id}";
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
  } // # http://222.108.71.247:51213/rule_base_on?ip=192.168.0.118&user_id=ehrnc

  rule_base_off(String user_id) async {
    String rulebaseonUrl =
        "http://222.108.71.247:51213/rule_base_off?ip=${ip}&user_id=${user_id}";
    await http.get(Uri.parse(rulebaseonUrl),
        headers: {"Access-Control_Allow_Origin": "*"}).then((Response) {
      Response.statusCode == 200 ? rulebasestate.value = 0 : null;
    });

    // http://222.108.71.247:51213/rule_base_off?ip=192.168.0.118&user_id=ehrnc
  }
}
