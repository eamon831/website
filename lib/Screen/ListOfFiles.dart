import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'PdfViewer.dart';
import 'package:path/path.dart';



class ListOfFiles extends StatefulWidget {
  const ListOfFiles({Key? key}) : super(key: key);

  @override
  State<ListOfFiles> createState() => _ListOfFilesState();
}

class _ListOfFilesState extends State<ListOfFiles> {

  // Make New Function
  String? directory;
  List<io.FileSystemEntity> file = [];

  var _controller;

  int? pages=0;

  bool isReady=false;
  void _listofFiles() async {
    var dir = (await getApplicationDocumentsDirectory());
    setState(() {
      file=dir.listSync(recursive: true, followLinks: false);
      List<int> indexes=[];
      file.forEachIndexed((element, index) {
        if(!element.path.isPdf){
          setState(() {
            indexes.add(index);
            /*print(element.path);
            file.removeAt(index);*/
          });
        }
      });
      file.removeWhere((element){
        return !element.path.isPdf;
      });



     // file = io.File("$directory/").;  //use your folder name insted of resume.
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listofFiles();

  }
  Widget view(String path){
    print(path);
    return SfPdfViewer.file(io.File(path));
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: file.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: (){
            toast("helo");
            view(file[index].path);
            Navigator.push(context, MaterialPageRoute(builder: (context) => PdfViewer(path: file[index].path),));
          },
          child: Container(
            color: Colors.grey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 60,
                    color: Colors.amber[100],
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(child: Text(basename(file[index].path))),
                    ),

                  ),
                ),
                ElevatedButton(onPressed: (){
                  io.File(file[index].path).delete();
                  _listofFiles();
                }, child:Text("Delete"))
              ],
            ),
          ),
        );
      },
    );
  }

}
