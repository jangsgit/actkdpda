
import 'dart:convert';

import 'package:actkdpda/ui/app01/AppPage01_Subpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../config/constant.dart';
import '../../config/global_style.dart';
import '../../model/kosep/Da035List_model.dart';

class AppPage02 extends StatefulWidget {
  const AppPage02({Key? key}) : super(key: key);

  @override
  _AppPage02State createState() => _AppPage02State();
}

class _AppPage02State extends State<AppPage02>   {

  TextEditingController _etDate = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  DateTime _selectedDate = DateTime.now(), initialDate = DateTime.now();
  List<Da035List_model> itemDataList = da035Data;
  String _dbnm = '';
  String _userid = '';
  String _username = '';
  String _perid = '';


  @override
  void initState() {
    sessionData();
    super.initState();
    _etDate.text = getToday();
  }

  @override
  void dispose() {
    _etDate.dispose();
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
    var uritxt = CLOUD_URL + '/kdmes/list03';
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'todate': _etDate.text
      },
    );
    if(response.statusCode == 200){
      List<dynamic> alllist = [];
      alllist =  jsonDecode(utf8.decode(response.bodyBytes))  ;
      da035Data.clear();
      for (int i = 0; i < alllist.length; i++) {
        Da035List_model emObject= Da035List_model(
            custcd:alllist[i]['custcd'],
            spjangcd:alllist[i]['spjangcd'],
            fdeldate:alllist[i]['fdeldate'],
            deldate:alllist[i]['deldate'],
            delnum:alllist[i]['delnum'],
            delseq:alllist[i]['delseq'],
            cltcd:alllist[i]['cltcd'],
            cltnm:alllist[i]['cltnm'],
            pcode:alllist[i]['pcode'],
            pname:alllist[i]['pname'],
            psize:alllist[i]['psize'],
            qty:alllist[i]['qty'],
            seqty:alllist[i]['seqty'],
            glotno:alllist[i]['lotno'],
            glasslotno:alllist[i]['glasslotno'],
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

  Future Del_getdata(argcode, arg1, arg2, arg3) async {
    var uritxt = CLOUD_URL + '/kdmes/list03del';
    var encoded = Uri.encodeFull(uritxt);
    Uri uri = Uri.parse(encoded);
    // print(arrBarcode);
    // print("_lsEtGrade=>" + _lsEtGrade);
    // print("_lsEtThick=>" + _lsEtThick);
    // arrBarcode = 'R1022204246|R1022204246';
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'barcode': argcode,
        'deldate': arg1,
        'delnum': arg2,
        'delseq': arg3
      },
    );
    if(response.statusCode == 200){
      try{
        // var result =  jsonDecode(utf8.decode(response.bodyBytes))  ;
        var result =  utf8.decode(response.bodyBytes);
        if (result == "SUCCESS"){
          showAlertDialog(context, "삭제되었습니다.");
          da035list_getdata();
        }else{
          showAlertDialog(context, result + " : 관리자에게 문의하세요");
        }
        return ;
      }catch(e){
        // print(e.toString());
        showAlertDialog(context, e.toString() + " : 관리자에게 문의하세요");
      }
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
          '출고현황',
          style: GlobalStyle.appBarTitle,
        ),
        actions: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(onPressed: (){
                  setState(() {
                    _etDate.text  ;
                  });
                  String ls_etdate = _etDate.text  ;
                  if(ls_etdate.length == 0){
                    print("일자를 입력하세요");
                    return;
                  }
                  da035list_getdata();
                  print(_etDate.text );
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
                  controller: _etDate,
                  readOnly: true,
                  onTap: () {
                    _selectDateWithMinMaxDate(context);
                  },
                  maxLines: 1,
                  cursorColor: Colors.grey[600],
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:  EdgeInsets.all(10),
                    suffixIcon: Icon(Icons.date_range, color: Colors.indigo),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    labelText: '출고일',
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
                        DataColumn(label: Text('출고일자')),
                        DataColumn(label: Text('번호')),
                        DataColumn(label: Text('거래처')),
                        DataColumn(label: Text('품목')),
                        DataColumn(label: Text('규격')),
                        DataColumn(label: Text('수량')),
                        DataColumn(label: Text('검사로트')),
                        DataColumn(label: Text('외부로트')),
                      ],
                      rows: List<DataRow>.generate(da035Data.length,(index)
                      {
                        final Da035List_model item = da035Data[index];
                        return
                          DataRow(
                              onSelectChanged: (value){
                                showAlertDialog_chulgoDelete(context, item.glotno, item.deldate, item.delnum, item.delseq);
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
                                        child: Text(item.fdeldate
                                        ))),
                                DataCell(
                                    Container(
                                        child: Text(item.delnum
                                        ))),
                                DataCell(Container(
                                  child: Text(item.cltnm,
                                      overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Container(
                                  child: Text(item.pname,
                                      overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Container(
                                  child: Text(item.psize,
                                      overflow: TextOverflow.ellipsis),
                                )),
                                DataCell(Container(
                                  child: Text(item.qty),
                                )),
                                DataCell(Container(
                                  child: Text(item.glotno),
                                )),
                                DataCell(Container(
                                  child: Text(item.glasslotno),
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



  void showAlertDialog_chulgoDelete(BuildContext context, String argcode, String arg1, String arg2, String arg3) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('출고등록'),
          content: Text(argcode + " : 삭제 하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async{
                Navigator.pop(context, "삭제");
                var result = await Del_getdata(argcode, arg1, arg2, arg3);
                if(result){
                  setState(() {
                  });
                  // Navigator.pushReplacement(
                  //     context, MaterialPageRoute(builder: (context) =>
                  //     mpuchase(pernm: widget.pernm, perid: widget.perid, userid: widget.userid)
                  // ));
                  // print("저장성공!");
                }else{
                  // showAlertDialog(context, "출고저장 중 오류가 ");
                  return ;
                }
                print("chulgo_delete result=>" + result.toString());
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


  Future<Null> _selectDateWithMinMaxDate(BuildContext context) async {
    var firstDate = DateTime(initialDate.year, initialDate.month - 6, initialDate.day);
    var lastDate = DateTime(initialDate.year, initialDate.month, initialDate.day + 7);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.indigo,
            colorScheme: ColorScheme.light(primary: Colors.indigo, secondary: Colors.indigo),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;

        _etDate = TextEditingController(
            text: _selectedDate.toLocal().toString().split('-')[0]+_selectedDate.toLocal().toString().split('-')[1]+_selectedDate.toLocal().toString().split('-')[2].substring(0,2));
      });
    }
  }



  void showAlertDialog(BuildContext context, String as_msg) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('출고등록'),
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

}



