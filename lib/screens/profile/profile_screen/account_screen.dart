import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

final _db = FirebaseFirestore.instance;

class _AccountScreenState extends State<AccountScreen> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController birthdayController = TextEditingController();
  TextEditingController homeAddressController = TextEditingController();
  File? imageFile;

  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('client_user');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  Future<Map<String, dynamic>> getUserData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await users
        .where('email', isEqualTo: user.email)
        .get() as QuerySnapshot<Map<String, dynamic>>;

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs[0].data();
    } else {
      return {}; // Return an empty map if no matching user is found
    }
  }

  Future<void> uploadImage() async {
    if (imageFile == null) return;

    final Reference storageReference =
        FirebaseStorage.instance.ref().child('profile_images').child(user.uid);

    final UploadTask uploadTask = storageReference.putFile(imageFile!);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    final String imageUrl = await taskSnapshot.ref.getDownloadURL();

    // Update the user document with the image URL
    await _db
        .collection("client_user")
        .where("email", isEqualTo: user.email)
        .get()
        .then(
      (querySnapshot) {
        querySnapshot.docs.forEach(
          (doc) {
            doc.reference.update({'profile_image': imageUrl});
          },
        );
      },
    );
  }

  Future<void> updateUser() async {
    setState(() {
      isLoading = true;
    });

    await uploadImage(); // Upload the image before updating other user data

    final Map<String, dynamic> newData = {
      'firstname': firstnameController.text,
      'lastname': lastnameController.text,
      'age': int.tryParse(ageController.text) ?? 0,
      'contactNumber': contactNumberController.text,
      'address': homeAddressController.text,
      'birthday': birthdayController.text,
    };
    await _db
        .collection("client_user")
        .where("email", isEqualTo: user.email)
        .get()
        .then(
      (querySnapshot) {
        querySnapshot.docs.forEach(
          (doc) {
            doc.reference.update(newData);
          },
        );
      },
    );

    // Reload the data after saving changes
    getUserData().then((data) {
      setState(() {
        firstnameController.text = data['firstname'] ?? '';
        lastnameController.text = data['lastname'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        contactNumberController.text = data['contactNumber'] ?? '';
        homeAddressController.text = data['address'] ?? '';
        birthdayController.text = data['birthday'] ?? '';
        isLoading = false;
      });
    });

    // Refresh the whole screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AccountScreen()),
    );
  }

  Future<void> showImagePicker() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking an image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((data) {
      setState(() {
        firstnameController.text = data['firstname'] ?? '';
        lastnameController.text = data['lastname'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        contactNumberController.text = data['contactNumber'] ?? '';
        homeAddressController.text = data['address'] ?? '';
        birthdayController.text = data['birthday'] ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF33c072),
          title: const Text(
            "My Account",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            // Handle refresh logic here (e.g., refetch data)
            await getUserData();
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.3, -0.3),
                end: Alignment.bottomRight,
                colors: [Colors.white, Color.fromARGB(255, 191, 228, 192)],
              ),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: GestureDetector(
                        onTap: showImagePicker,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              child: ClipOval(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.white,
                                  child: _buildProfileImage(),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF33c072),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    buildListTile(
                      "First Name",
                      firstnameController,
                      FontAwesomeIcons.user,
                      subtext: firstnameController.text,
                    ),
                    buildListTile(
                      "Last Name",
                      lastnameController,
                      FontAwesomeIcons.user,
                      subtext: lastnameController.text,
                    ),
                    buildListTile(
                      "Birthday",
                      birthdayController,
                      FontAwesomeIcons.birthdayCake,
                      showEditButton: false,
                      subtext: birthdayController.text,
                    ),
                    buildListTile(
                      "Age",
                      ageController,
                      FontAwesomeIcons.user,
                      showEditButton: false,
                      subtext: ageController.text,
                    ),
                    buildListTile(
                      "Contact Number",
                      contactNumberController,
                      FontAwesomeIcons.phone,
                      subtext: contactNumberController.text,
                    ),
                    buildListTile(
                      "Home Address",
                      homeAddressController,
                      FontAwesomeIcons.home,
                      subtext: homeAddressController.text,
                    ),
                    buildListTile(
                      "Email Address",
                      emailAddressController,
                      FontAwesomeIcons.envelope,
                      showEditButton: false,
                      subtext: user.email,
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await updateUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF33c072),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  ListTile buildListTile(
    String title,
    TextEditingController controller,
    IconData iconData, {
    bool showEditButton = true,
    String? subtext,
  }) {
    return ListTile(
      leading: FaIcon(iconData),
      title: Text(title),
      subtitle: subtext != null ? Text(subtext) : null,
      trailing: showEditButton
          ? IconButton(
              icon: const FaIcon(FontAwesomeIcons.edit),
              onPressed: () {
                showEditDialog(title, controller);
              },
            )
          : null,
    );
  }

  Widget _buildProfileImage() {
    if (imageFile != null) {
      return ClipOval(
        child: Image.file(
          imageFile!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Icon(
              Icons.error_outline,
              color: Colors.red,
            );
          } else {
            String? profileImageUrl = snapshot.data?['profile_image'];
            return profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      profileImageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                : const CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 50.0,
                      color: Colors.white,
                    ),
                  );
          }
        },
      );
    }
  }

  void showEditDialog(String fieldName, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $fieldName"),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: fieldName),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }
}
