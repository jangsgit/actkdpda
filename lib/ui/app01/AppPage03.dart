
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pointmobile_scanner/pointmobile_scanner.dart';

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/kosep/Da035List_model.dart';

class AppPage03 extends StatefulWidget {
  const AppPage03({Key? key}) : super(key: key);

  @override
  _AppPage03State createState() => _AppPage03State();
}

class _AppPage03State extends State<AppPage03>   {

  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();
  List<Da035List_model> itemDataList = da035Data;
  String arrBarcode = "";
  String arrBarcode_G = "";
  final List<String> arrBarcodeText = <String>[];
  final List<String> arrBarcodeText_G  = <String>[];
  final List<int> colorCodes = <int>[500, 600, 100];
  String _perid = '';
  String _lsItemcd = '';
  String _userid = "";
  String _username = "";
  String? _decodeResult = "Unknown";
  TextEditingController _etBarcode = TextEditingController();


  @override
  void initState() {
    sessionData();
    super.initState();
    arrBarcode = "";
    arrBarcodeText.clear();
    arrBarcode_G  = "";
    arrBarcodeText_G .clear();
    PointmobileScanner.channel.setMethodCallHandler(_onBarcodeScannerHandler);
    PointmobileScanner.initScanner();
    PointmobileScanner.enableScanner();
    PointmobileScanner.enableBeep();
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_CODE128);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_EAN13);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_QR);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_UPCA);
  }

  @override
  void dispose() {
    _etBarcode.dispose();
    da035Data.clear();
    super.dispose();
  }

  String getToday(){
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMdd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }
  Future<void> sessionData() async{
    _userid   = (await SessionManager().get("userid")).toString();
    _username = (await SessionManager().get("username")).toString();
    _perid    = (await SessionManager().get("perid")).toString();
    print(_perid);
  }


  Future da035list_getdata() async {
    var uritxt = CLOUD_URL + '/kdmes/list04';
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'lotno': _etBarcode.text
      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;

      da035Data.clear();
      for (int i = 0; i < alllist.length; i++) {
        Da035List_model emObject= Da035List_model(
          deldate:alllist[i]['qcdate'],
          qty:alllist[i]['otqty'],
          wrpsnm02:alllist[i]['wrpsnm02'],
          lotno:alllist[i]['lotno'],
          wrpsnm01:alllist[i]['wrpsnm01'],
          seqty:alllist[i]['prod_qty'],
          pname:alllist[i]['pname'],
          psize:alllist[i]['psize'],
        );
        setState(() {
          da035Data.add(emObject);
        });

      }

      return da035Data;
    }else{
      //만약 응답이 ok가 아니면 에러를 던집니다.
      throw Exception('불러오는데 실패했습니다');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: GlobalStyle.appBarIconThemeColor,
        ),
        elevation: GlobalStyle.appBarElevation,
        title: Text(
          '이력조회',
          style: GlobalStyle.appBarTitle,
        ),
        actions: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(onPressed: (){
                  setState(() {
                    _etBarcode.text  ;
                  });
                  String ls_etbarcode = _etBarcode.text  ;
                  if(ls_etbarcode.length == 0){
                    print("바코드를 스캔하세요");
                    return;
                  }
                  da035list_getdata();
                  print(_etBarcode.text );
                }, child: Text('검색하기')),
              ),
            ],
          )
        ],
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,

      ),

      body:
      ListView(
        padding: EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _etBarcode,
                  readOnly: true,
                  onTap: () {
                    showAlertDialog_Clear(context);
                  },
                  maxLines: 1,
                  cursorColor: Colors.grey[600],
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:  EdgeInsets.all(10),
                    suffixIcon: Icon(Icons.add, color: Colors.indigo),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    labelText: '검사로트',
                    labelStyle: TextStyle(color: BLACK_GREY),
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: EdgeInsets.only(top: 15),
              height: 0.638 * MediaQuery.of(context).size.height,
              width: 1100,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 25, dataRowHeight: 40,
                      headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      headingRowColor:
                      MaterialStateColor.resolveWith((states) => SOFT_BLUE),

                      columns: <DataColumn>[
                        DataColumn(label: Text('No.')),
                        DataColumn(label: Text('검사일')),
                        DataColumn(label: Text('검사수량')),
                        DataColumn(label: Text('담당자')),
                        DataColumn(label: Text('사출바코드')),
                        DataColumn(label: Text('사출담당')),
                        DataColumn(label: Text('수량')),
                        DataColumn(label: Text('품목')),
                        DataColumn(label: Text('규격')),
                      ],
                      rows: List<DataRow>.generate(da035Data.length,(index)
                      {
                        final Da035List_model item = da035Data[index];
                        return
                          DataRow(
                              onSelectChanged: (value){
                                //showAlertDialog_chulgoDelete(context, item.glotno, item.deldate, item.delnum, item.delseq);
                              },
                              color: MaterialStateColor.resolveWith((states){
                                if (index % 2 == 0){
                                  return Color(0xB8E5E5E5);
                                }else{
                                  return Color(0x86FFFFFF);
                                }
                              }),
                              cells: [
                                DataCell(
                                    Container(
                                        child: Text('${index+1}',
                                        ))),
                                DataCell(
                                    Container(
                                        child: Text(item.deldate
                                        ))),
                                DataCell(
                                    Container(
                                        child: Text(item.qty.toString()
                                        ))),
                                DataCell(Container(
                                  child: Text(item.wrpsnm02,
                                      overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Container(
                                  child: Text(item.lotno,
                                      overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Container(
                                  child: Text(item.wrpsnm01,
                                      overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Container(
                                  child: Text(item.seqty.toString()),
                                )),
                                DataCell(Container(
                                  child: Text(item.pname),
                                )),
                                DataCell(Container(
                                  child: Text(item.psize),
                                )),
                              ]
                          );
                      }
                      )
                  ),],
              ),
            ),
          ),
        ],
      ),
    );

  }



  Future<void> _onBarcodeScannerHandler(MethodCall call) async {
    try {
      if (call.method == PointmobileScanner.ON_DECODE) {
        _onDecode(call);
      } else if (call.method == PointmobileScanner.ON_ERROR) {
        _onError(call.arguments);
      } else {
        print(call.arguments);
      }
    } catch(e) {
      print(e);
    }
  }

  void _onDecode(MethodCall call) {
    setState(() {
      final List lDecodeResult = call.arguments;
      _decodeResult = "Symbology: ${lDecodeResult[0]}\nValue: ${lDecodeResult[1]}";
      _lsItemcd = lDecodeResult[1];
    });
    if(_lsItemcd == 'READ_FAIL'){
      showAlertDialog(context, "바코드 스캔을 실패했습니다.");
    }else{
      String ls_gchk = "";
      ls_gchk = _lsItemcd.substring(10,11);
      print("ls_gchk--->" + ls_gchk);
      arrBarcodeText_G.clear();
      setState(() {
        arrBarcodeText_G.add(_lsItemcd);
      });

      String ls_arrcode = "";
      arrBarcode = "";
      arrBarcode_G = "";

      //검사바코드값을 TEXT에 넣어준다.
      for(var code in arrBarcodeText_G){
        if(arrBarcode_G.length > 0){
          arrBarcode_G = arrBarcode_G + "|" + code;
        }else{
          arrBarcode_G =  code;
        }
      }
      print("arrBarcode=>" + arrBarcode);
      print("arrBarcode_G=>" + arrBarcode_G);

      //검사바코드  화면표시
      for(var code in arrBarcodeText_G){
        if(ls_arrcode.length > 0){
          ls_arrcode = ls_arrcode + " * " + code;
        }else{
          ls_arrcode =  code;
        }
      }
      _etBarcode = TextEditingController(text: ls_arrcode);
      da035list_getdata();
      // showAlertDialog_chulgoSave(context, _lsItemcd);
    }
  }

  void _onExit() {
    PointmobileScanner.disableScanner();
    // SystemNavigator.pop();
  }

  void _onError(Exception error) {
    setState(() {
      _decodeResult = error.toString();
    });
    print("_onError : " );
    print(_decodeResult );
  }



  void showAlertDialog(BuildContext context, String as_msg) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이력조회'),
          content: Text(as_msg),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context, "확인");
              },
            ),
          ],
        );
      },
    );
  }

  void showAlertDialog_Clear(BuildContext context) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('출고등록'),
          content: Text("스캔한 LotNo를 리셋하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async{
                setState(() {
                  arrBarcode = "";
                  arrBarcodeText.clear();
                  _etBarcode =TextEditingController(text: "");
                });
                Navigator.pop(context, "닫기");
              },
            ),
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context, "닫기");
              },
            ),
          ],
        );
      },
    );
  }


}



