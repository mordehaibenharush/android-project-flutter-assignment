import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSheet extends StatelessWidget {
  ProfileSheet({Key? key, required this.user}) : super(key: key);
  User user;
  final sheetController = SnappingSheetController();

  @override
  Widget build(BuildContext context) {
    return SnappingSheet(
      controller: sheetController,
      lockOverflowDrag: true,
      snappingPositions: [
        SnappingPosition.factor(
          positionFactor: 0.0,
          snappingCurve: Curves.easeOutExpo,
          snappingDuration: Duration(seconds: 1),
          grabbingContentOffset: GrabbingContentOffset.top,
        ),
        SnappingPosition.factor(
          snappingCurve: Curves.elasticOut,
          snappingDuration: Duration(milliseconds: 1750),
          positionFactor: 0.25,
        ),
        SnappingPosition.factor(
          grabbingContentOffset: GrabbingContentOffset.bottom,
          snappingCurve: Curves.easeInExpo,
          snappingDuration: Duration(seconds: 1),
          positionFactor: 1,
        ),
      ],
      grabbing: GestureDetector(
        onTap: () {
          if (sheetController.isAttached) {
            sheetController.snapToPosition(
              SnappingPosition.factor(positionFactor: 0.75),
            );
          }
        },
        child: GrabbingWidget(
          user: user,
          onTapFunc: () {},
        ),
      ),
      grabbingHeight: 50,
      sheetBelow: SnappingSheetContent(
        draggable: true,
        child: Container(
          color: Colors.white,
          child: Avatar(user: user),
          )//CircleAvatar(child: Avatar(user: user), maxRadius: 1)
        ),
      );
    }
}

class Avatar extends StatefulWidget {
  Avatar({Key? key, required this.user}) : super(key: key);
  User user;

  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  final picker = ImagePicker();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            Padding(padding: EdgeInsets.all(10),
              child: CircleAvatar(maxRadius: 50, backgroundColor: Colors.deepPurple ,
                child: CircleAvatar(maxRadius: 45, backgroundColor: Colors.grey,)),),
            Padding(padding: EdgeInsets.all(10),
              child: ElevatedButton(child: Text("upload"),
              onPressed: () async {
                await pickImage().then((value) => uploadImageToFirebase('users'));
              }),
            ),
      ]);
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  UploadTask? uploadImage(String destination, File image) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(image);
    } on FirebaseException catch (_) {
      return null;
    }
  }

  Future uploadImageToFirebase(String destination) async {
    String fileName = widget.user.uid;
    final firebaseStorageRef =
    FirebaseStorage.instance.ref().child('$destination/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile!);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
    );
  }
}

class GrabbingWidget extends StatelessWidget {
  final User? user;
  final Function onTapFunc;

  GrabbingWidget({required this.user, required this.onTapFunc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text("Welcome back ${user?.email}", style: TextStyle(color: Colors.deepPurple, fontSize: 16,),),
          ),),
          Expanded(
            flex: 1,
            child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, color: Colors.deepPurple, size: 30),
            onPressed: onTapFunc(),
            tooltip: 'Profile display',
          ),),
        ],
      ),
    );
  }
}
