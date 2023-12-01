
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
  List<Da035List_model> da035Datas = da035Data;
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
    _dbnm     = (await SessionManager().get("dbnm")).toString();
    _userid   = (await SessionManager().get("userid")).toString();
    _username = (await SessionManager().get("username")).toString();
    _perid    = (await SessionManager().get("perid")).toString();
    print(_perid);
  }


  Future da035list_getdata() async {
    String _dbnm = await  SessionManager().get("dbnm");

    var uritxt = CLOUD_URL + '/kosep/list03';
    var encoded = Uri.encodeFull(uritxt);

    Uri uri = Uri.parse(encoded);
    final response = await http.post(
      uri,
      headers: <String, String> {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept' : 'application/json'
      },
      body: <String, String> {
        'dbnm': _dbnm,
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
            fdeldatetext:alllist[i]['fdeldatetext'],
            fdelnum:alllist[i]['fdelnum'],
            fdelseq:alllist[i]['fdelseq'],
            cltcd:alllist[i]['cltcd'],
            cltnm:alllist[i]['cltnm'],
            pcode:alllist[i]['pcode'],
            pname:alllist[i]['pname'],
            width:alllist[i]['width'],
            thick:alllist[i]['thick'],
            color:alllist[i]['color'],
            deldate:alllist[i]['deldate'],
            delnum:alllist[i]['delnum'],
            delseq:alllist[i]['delseq'],
            grade:alllist[i]['grade'],
            qty:alllist[i]['qty'],
            lotno:alllist[i]['lotno']
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
    String _dbnm = await  SessionManager().get("dbnm");

    var uritxt = CLOUD_URL + '/kosep/list03del';
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
        'dbnm': _dbnm,
        'barcode': argcode,
        'deldate': arg1,
        'delnum': arg2,
        'delseq': arg3,
        'perid': _perid
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
          '출고현황(Lot)',
          style: GlobalStyle.appBarTitle,
        ),
        backgroundColor: GlobalStyle.appBarBackgroundColor,
        systemOverlayStyle: GlobalStyle.appBarSystemOverlayStyle,

      ),
      body:
      WillPopScope(
        onWillPop: (){
          Navigator.pop(context);
          return Future.value(true);
        },
        child: Column(
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
                TextButton(
                  onPressed: () {
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
                  },
                  child: Text(
                    '목록조회',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xffcccccc),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            Expanded(child: ListView.builder(itemCount: da035Datas.length,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index){
                return _buildListCard(da035Datas[index]);
              },
            ))
          ],
        ),

      ),


    );

  }



  Widget _buildListCard(Da035List_model da035Data){
    return Card(
        margin: EdgeInsets.only(top: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        elevation: 2,
        color: Colors.white,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            //Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage11view(da035Data: da035Data)));
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              showAlertDialog_chulgoDelete(context, da035Data.lotno, da035Data.fdeldate, da035Data.delnum, da035Data.delseq);
              print(da035Data);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage01_Subpage(da035Data: da035Data)));
            },
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(da035Data.cltnm, style: GlobalStyle.couponName),
                  Text(da035Data.grade, style: GlobalStyle.couponName),
                  Text(da035Data.thick+' ['+da035Data.width+'] '+da035Data.color, style: GlobalStyle.couponName),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GlobalStyle.iconTime,
                          SizedBox(
                            width: 4,
                          ),
                          Text(da035Data.pname , style: GlobalStyle.couponName),
                        ],
                      ),
                      GestureDetector(
                        onTap: (){
                          print(da035Data);
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => AppPage11Detail(da035Data: da035Data)));
                        },
                        child: Text( da035Data.lotno, style: TextStyle(
                            fontSize: 14, color: SOFT_BLUE, fontWeight: FontWeight.bold
                        )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }



  void showAlertDialog_chulgoDelete(BuildContext context, String argcode, String arg1, String arg2, String arg3) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ACTAS 출고등록'),
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
          title: Text('ACTAS 출고등록'),
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



