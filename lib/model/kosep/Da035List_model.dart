import 'dart:convert';

import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;

import '../../config/constant.dart';


class Da035List_model{
  late var custcd;
  late var spjangcd;
  late var fdeldate;
  late var fdeldatetext;
  late var fdelnum;
  late var fdelseq;
  late var cltcd;
  late var cltnm;
  late var pcode;
  late var pname;
  late var width;
  late var thick;
  late var color;
  late var deldate;
  late var delnum;
  late var delseq;
  late var grade;
  late var qty;
  late var seqty;
  late var lotno;
  late var psize;
  late var uamt;
  late var samt;
  late var remark;
  late var deldefault;
  late var glotno;
  late var glasslotno;
  late var wrpsnm01;
  late var wrpsnm02;



  Da035List_model({   this.custcd,  this.spjangcd, this.fdeldate, this.fdeldatetext, this.fdelnum, this.fdelseq,
      this.cltcd,   this.cltnm,
      this.pcode,  this.pname,  this.glotno,   this.glasslotno,   this.deldate,  this.delnum,  this.delseq,
      this.grade,   this.qty, this.seqty, this.lotno, this.psize, this.uamt, this.samt, this.remark, this.deldefault, this.wrpsnm01, this.wrpsnm02});
}


List<Da035List_model> da035Data =[];
