import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

//create a new instance of our Firestore Database as final (not going to change the value)
//putting outside of the class so we can access it from anywhere in this file
final _firestore = Firestore.instance;

//the currently logged in user (moved to top to access everywhere in the file)
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  //static so it can be accessed without building the Welcome Screen object
  //const so it can't accidentally be changed somewhere else
  static const String id = 'ChatScreen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //create new authentication instance as final (not going to change it)
  //using _ to keep it private so other classes can't mess with this variable
  final _auth = FirebaseAuth.instance;

  String messageText;

  //controller for editing the message text field (next to the send button)
  final messageTextController = TextEditingController();

  //setup init for when the state is initialized
  @override
  void initState() {
    super.initState();
    //trigger the getCurrentUser Method
    getCurrentUser();
  }

  //Method for getting the user from Firebase
  void getCurrentUser() async {
    //try-catch because this can fail for many reasons
    try {
      //get the current user info from the FirebaseAuth instance
      final user = await _auth.currentUser();
      //if we get a user back from the server successfully...
      if (user != null) {
        //assign the user to a FirebaseUser variable
        loggedInUser = user;
        //print(loggedInUser.email);
      }
    } catch (e) {
      //print the exception
      print(e);
    }
  }

  //Method to get messages from Firestore (for pulling data which isn't efficient)
//  void getMessages() async {
//    //get collection data from the firestore database
//    final messages = await _firestore.collection('messages').getDocuments();
//  }

  //Method for subscribing to a stream from the collection in the database

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //Streambuilder allows the snapshot and widgets in the app to use setState to rebuild each time new data is recieved
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      //our message text editor controller object we
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //use the message text editor object to clear the text field of characters
                      messageTextController.clear();
                      //Implement send functionality.
                      //adding a map of the fields to the collection
                      //make sure all the strings match whats in your database
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'name': loggedInUser.email,
                        //timestamp for ordering the chat text
                        'time': DateTime.now(),
                      });
                      //messageStream();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      //designate the stream we are subscribing to
      stream: _firestore
          .collection('messages')
          .orderBy('time', descending: false)
          .snapshots(),

      //build the Query with the context and the snapshot
      builder: (context, snapshot) {
        //if there is no data in the snapshot...
        if (!snapshot.hasData) {
          //return a spinning progress indicator
          print('lightblue accent');
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        //variable to hold the document data list from the snapshot
        // .revered changes the way that the documents are added to the List
        final messages = snapshot.data.documents;

        //List variable to hold the list of widgets we will put in the column(chat area)
        List<MessageBubble> messageBubbles = [];

        for (var message in messages) {
          //assign the text and name data to a variable
          final messageText = message.data['text'];
          final messageSender = message.data['name'];
          //timestamp for ordering the chat text
          final messageTime = message.data['time'] as Timestamp;

          //variable for holding the current user's username
          final currentUser = loggedInUser.email;

          //use the variables in the widget
          final messageBubble = MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: currentUser == messageSender,
            //timestamp for ordering the chat text
            time: messageTime,
          );

          //add the widgets to the list of widgets
          messageBubbles.add(messageBubble);
          messageBubbles.sort((a, b) => b.time.compareTo(a.time));
        }
        //return the list of widgets as a ListView (no longer a Column) of widgets that hold all our data
        //wrapped with Expanded Widget so the ListView Widget doesn't take over the whole screen
        return Expanded(
          //changed from Column to ListView because ListView is scrollable
          child: ListView(
            //makes adding widgets to the List start at the bottom
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender, this.isMe, this.time});
  final String text;
  final String sender;
  final bool isMe;
  //timestamp for ordering the chat text
  final Timestamp time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Text(
            time.toDate().toString().split(' ')[0],
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Text(
            time.toDate().toString().split(' ')[1].split('.')[0],
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            //rounded edges light a bubble (typical chat app)
            //borderRadius: BorderRadius.circular(30.0),
            //rounded edge with pointy part by the username
            borderRadius: BorderRadius.only(
              topLeft: isMe ? Radius.circular(30.0) : Radius.circular(0.0),
              topRight: isMe ? Radius.circular(0.0) : Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            //shadow effects
            elevation: 10.0,
            color: isMe ? Colors.lightBlueAccent : Colors.deepOrangeAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
