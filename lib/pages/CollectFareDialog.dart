
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Assistant/assistantmethods.dart';
import '../main.dart';

class CollectFareDialog extends StatelessWidget
{
  final String? paymentMethod;
  final int? fareAmount;

  CollectFareDialog({this.paymentMethod, this.fareAmount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 22.0,),

         Text("Job Amount",  style: TextStyle(fontSize: 16.0,
             fontWeight: FontWeight.bold,
             fontFamily: "Brand Bold"),),

            SizedBox(height: 22.0,),

            Divider(thickness: 4.0,),

            SizedBox(height: 16.0,),

            Text("\ GH¢$fareAmount", style: TextStyle(fontSize: 55.0, fontFamily: "Brand Bold"),),

            SizedBox(height: 16.0,),SizedBox(height: 16.0,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("This is the total job amount, it has been charged to the Client.", textAlign: TextAlign.center,),
            ),

            SizedBox(height: 30.0,),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      side:
                      const BorderSide(color: Colors.white)),
                ),

                onPressed: () async
                {
                  TextEditingController _commentController = TextEditingController();

                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return AlertDialog(
                  //       title: Text('Comment Session'),
                  //       content: TextField(
                  //         controller: _commentController,
                  //         decoration: InputDecoration(
                  //           hintText: 'Write your comment here...',
                  //         ),
                  //       ),
                  //       actions: <Widget>[
                  //         TextButton(
                  //           onPressed: () {
                  //             Navigator.of(context).pop();
                  //           },
                  //           child: Text('Cancel'),
                  //         ),
                  //         ElevatedButton(
                  //           onPressed: () {
                  //             final String _firebaseAuth = FirebaseAuth.instance.currentUser!.uid;
                  //             TextEditingController _commentController = TextEditingController();
                  //
                  //             // Submit the comment to the current user
                  //             String comment = _commentController.text.toString();
                  //             clients.child(_firebaseAuth).update({"Comments":_commentController});
                  //             print('Submitted comment: $comment');
                  //             _commentController.clear(); // Clear the input field after submission
                  //             Navigator.of(context).pop(); // Close the dialog after submission
                  //             Navigator.of(context).pop(); // Close the dialog after submission
                  //           },
                  //           child: Text('Submit'),
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // );
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);





                  AssistantMethod.enableHomeTabLiveLocationUpdates();
                },
                //color: Colors.deepPurpleAccent,
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Collect Cash", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),),
                      Icon(Icons.attach_money, color: Colors.black, size: 26.0,),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.0,),
          ],
        ),
      ),
    );
  }
}
class CommentDialog extends StatefulWidget {
  @override
  _CommentDialogState createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Comment Session'),
      content: TextField(
        controller: _commentController,
        decoration: InputDecoration(
          hintText: 'Write your comment here...',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

            // Submit the comment to the current user
            String comment = _commentController.text;
            clients.child(_firebaseAuth.currentUser!.uid).update({"Comments":_commentController});
            print('Submitted comment: $comment');
            _commentController.clear(); // Clear the input field after submission
            Navigator.of(context).pop(); // Close the dialog after submission
          },
          child: Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}