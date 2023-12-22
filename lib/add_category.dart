import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

// domain of your server

const String _baseURL = 'https://amrosite.000webhostapp.com';
// used to retrieve the key later
EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  // creates a unique key to be used by the form
  // this key is necessary for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controllerID = TextEditingController();
  TextEditingController _controllerName = TextEditingController();
  // the below variable is used to display the progress bar when retrieving data
    bool _loading = false;


  @override
  void dispose() {
    _controllerID.dispose();
    _controllerName.dispose();
    super.dispose();
  }

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          IconButton(onPressed: () {
            _encryptedData.remove('myKey').then((success) =>
            Navigator.of(context).pop());
          }, icon: const Icon(Icons.logout))
        ],
          title: const Text('Add Category'),
          centerTitle: true,
          // the below line disables the back button on the AppBar
          automaticallyImplyLeading: false,
    ),
        body: Center(child: Form(
      key: _formKey, // key to uniquely identify the form when performing validation
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          SizedBox(width: 200, child: TextFormField(controller: _controllerID,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter ID',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter id';
              }
              return null;
            },
          )),
          const SizedBox(height: 10),
          SizedBox(width: 200, child: TextFormField(controller: _controllerName,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter Name',
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter name';
              }
              return null;
            },
          )),
          const SizedBox(height: 10),
          ElevatedButton(
            // we need to prevent the user from sending another request, while current
            // request is being processed
              onPressed: _loading ? null : () { // disable button while loading
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _loading = true;
                  });
                  saveCategory(update, int.parse(_controllerID.text.toString()), _controllerName.text.toString());
                }
              },
              child: const Text('Submit'),
            ),
          const SizedBox(height: 10),
          Visibility(visible: _loading, child: const CircularProgressIndicator())
        ],
      ),
    )));
  }
}

// below function sends the cid, name and key using http post to the REST service
void saveCategory(Function(String text) update, int cid, String name) async {
  try {
    // we need to first retrieve and decrypt the key
    String myKey = await _encryptedData.getString('myKey');
    // send a JSON object using http post
      final response = await http.post(
          Uri.parse('$_baseURL/rabia/save.php'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          }, // convert the cid, name and key to a JSON object
          body: convert.jsonEncode(<String, String>{
            'cid': '$cid', 'name': name, 'key': myKey
          })).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        // if successful, call the update function
        update(response.body);
      }
  }
  catch(e) {
    update("connection error");
  }
}

