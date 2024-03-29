import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:sars/Control/Services/database_services.dart';
import 'package:sars/Model/ticket.dart';
import 'package:sars/Model/user.dart';
import 'package:sars/View/BuildWidgetsData/loading.dart';
import 'package:video_player/video_player.dart';
import 'package:sars/View/Containers/view_image_builder.dart';
import 'package:sars/View/Containers/view_video_builder.dart';

class TicketContainer extends StatefulWidget {
  final User currentUser;
  const TicketContainer({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<TicketContainer> createState() => _TicketBuilderPageState();
}

class _TicketBuilderPageState extends State<TicketContainer> {
  bool otherActive = false;
  bool isTherePictures = false;
  bool radioBtn = false;
  static bool chkEverything = false;
  bool isThereVideo = false;
  bool loading = false;
  bool? cameraGetimage;
  bool? cameraGetvideo;
  List<File> images = [];
  XFile? videoFile;
  int selectedPageIndex = 0;
  int currentStep = 0;
  int availableTryPictures = -1;
  static const int numberOfimage = 6;
  String? isPrivacy = 'Private';
  String val = 'Private';
  String? dropMenuValue = 'Plumbing';
  String? errorOther;
  String? genrlError = '';
  String? descriptionError;
  VideoPlayerController? videoPlayerController;
  ImagePicker imagePicker = ImagePicker();
  User? targetUser;
  final filter = ProfanityFilter();

  final List<TextEditingController> myController =
      List.generate(3, (i) => TextEditingController());

  final items = [
    'Improper Surface Grading/Drainage',
    'Improper Electrical Wiring',
    'Roof Damage',
    'Heating or cooling system',
    'Poor Overall Maintenance',
    'Structurally Related Problems',
    'Plumbing',
    'Exteriors',
    'Facilities',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    double newWidth = MediaQuery.of(context).size.width - 50;
    targetUser = widget.currentUser;
    return loading
        ? const Loading()
        : Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Container(
                width: newWidth,
                padding: const EdgeInsets.only(left: 0, right: 0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withOpacity(0.1)),
                child: Column(children: [
                  Theme(
                    data: ThemeData(primarySwatch: Colors.cyan),
                    child: Stepper(
                        type: StepperType.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        controlsBuilder:
                            (BuildContext context, ControlsDetails details) {
                          if (details.stepIndex < 6) {
                            return Row(
                              children: <Widget>[
                                TextButton(
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(10),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.only(
                                            left: 25,
                                            right: 25,
                                            bottom: 10,
                                            top: 10)),
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.cyan),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            side: BorderSide(
                                                color: Colors.black
                                                    .withOpacity(0.5)))),
                                  ),
                                  onPressed: details.onStepContinue,
                                  child: const Text(
                                    'CONTINUE',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                TextButton(
                                  onPressed: details.onStepCancel,
                                  child: const Text(
                                    'CANCEL',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row();
                          }
                        },
                        elevation: 50,
                        steps: [
                          Step(
                              title: const Text('Step 1: Type of Issue*'),
                              content: SingleChildScrollView(
                                child: Column(children: [
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 141, 218, 221),
                                            width: 1)),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        canvasColor: const Color.fromARGB(
                                            200, 85, 200, 205),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: dropMenuValue,
                                          items:
                                              items.map(buildMenuItem).toList(),
                                          onChanged: selectedMenuValue,
                                        ),
                                      ),
                                    ),
                                  ),
                                  otherActive
                                      ? TextFormField(
                                          autocorrect: true,
                                          decoration: InputDecoration(
                                            label: const Text(
                                              'Your Issue*',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            hintText: 'Type your issue',
                                            errorText: errorOther,
                                          ),
                                          minLines: 1,
                                          maxLines: 6,
                                          keyboardType: TextInputType
                                              .multiline, // user keyboard will have a button to move cursor to next line
                                          maxLength: 50,
                                          controller: myController[0],
                                        )
                                      : Container(),
                                ]),
                              )),
                          Step(
                              title: const Text('Step 2: Description*'),
                              content: SingleChildScrollView(
                                child: TextFormField(
                                  autocorrect: true,
                                  decoration: InputDecoration(
                                      label: const Text(
                                        'Description',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      errorText: descriptionError,
                                      hintText: 'Describe your issue'),
                                  minLines: 1,
                                  maxLines: 6,
                                  keyboardType: TextInputType
                                      .multiline, // user keyboard will have a button to move cursor to next line
                                  maxLength: 2000,
                                  controller: myController[1],
                                ),
                              )),
                          Step(
                              title: const Text('Step 3: Location (Optional)'),
                              content: SingleChildScrollView(
                                child: TextFormField(
                                  autocorrect: true,
                                  decoration: const InputDecoration(
                                      label: Text(
                                        'Location',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      hintText: 'Locate your issue'),
                                  minLines: 1,
                                  maxLines: 2,
                                  keyboardType: TextInputType
                                      .multiline, // user keyboard will have a button to move cursor to next line
                                  maxLength: 50,
                                  controller: myController[2],
                                ),
                              )),
                          Step(
                              title: const Text(
                                  'Step 4: Take pictures (Optional)'),
                              content: SingleChildScrollView(
                                child: Column(children: [
                                  isTherePictures
                                      ? Column(children: [
                                          ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: images.length,
                                            itemBuilder: (context, index) {
                                              return viewImage(index);
                                            },
                                          )
                                        ])
                                      : Container(),
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            availableTryPictures >
                                                    numberOfimage - 2
                                                ? Container()
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                        IconButton(
                                                          icon: const Icon(Icons
                                                              .add_a_photo),
                                                          onPressed: () {
                                                            takePictures(0);
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            width: 30),
                                                        IconButton(
                                                          icon: const Icon(Icons
                                                              .photo_library_rounded),
                                                          onPressed: () {
                                                            takePictures(1);
                                                          },
                                                        )
                                                      ]),
                                          ],
                                        ),
                                      ]),
                                ]),
                              )),
                          Step(
                              title: const Text(
                                  'Step 5: Record a video (Optional)'),
                              content: SingleChildScrollView(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      isThereVideo
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 3, top: 3),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color: Colors.black
                                                      .withOpacity(0.1)),
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: const AssetImage(
                                                      'assets/icons/icons8_video_96px.png'),
                                                  radius: 25.0,
                                                  backgroundColor: Colors
                                                      .cyanAccent
                                                      .withOpacity(0.1),
                                                ),
                                                title: const Text('Video'),
                                                subtitle: const Text(
                                                    'Click To view it'),
                                                trailing: IconButton(
                                                  icon: const Icon(
                                                      Icons.delete_rounded),
                                                  onPressed: () {
                                                    deleteVideo();
                                                  },
                                                ),
                                                onTap: () {
                                                  viewVideo();
                                                },
                                              ),
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                  Icons.video_call_rounded),
                                              onPressed: () {
                                                recordVideo();
                                              },
                                            )
                                    ]),
                              )),
                          Step(
                            title: const Text('Step 6: Privacy (Important!)*'),
                            content: SingleChildScrollView(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                        'This option allows others to examine the specifics of your ticket\nBy default it\'s a private.'),
                                    Column(
                                      children: [
                                        Row(children: [
                                          Radio(
                                            value: 'Private',
                                            groupValue: val,
                                            activeColor: radioBtn
                                                ? Colors.black.withOpacity(0.1)
                                                : Colors.black,
                                            onChanged: (vale) {
                                              setState(() {
                                                val = vale as String;
                                                isPrivacy = val;
                                              });
                                            },
                                          ),
                                          const Text('Private'),
                                        ]),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Row(children: [
                                          Radio(
                                            value: 'Public',
                                            groupValue: val,
                                            activeColor: radioBtn
                                                ? Colors.black.withOpacity(0.1)
                                                : Colors.black,
                                            onChanged: (vale) {
                                              setState(() {
                                                val = vale as String;
                                                isPrivacy = val;
                                              });
                                            },
                                          ),
                                          const Text('Public'),
                                        ]),
                                      ],
                                    )
                                  ]),
                            ),
                          ),
                          Step(
                              title: const Text('Step 7: Submission'),
                              content: SingleChildScrollView(
                                child: ElevatedButton(
                                  child: const Text('Submit'),
                                  onPressed: () {
                                    dailog();
                                  },
                                ),
                              )),
                        ],
                        currentStep: currentStep,
                        onStepTapped: onTapped,
                        onStepContinue: onContinue,
                        onStepCancel: onCancel),
                  ),
                  chkEverything
                      ? Text(
                          genrlError!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 15),
                        )
                      : Container(),
                  const SizedBox(height: 15),
                ]),
              ),
              const SizedBox(
                height: 25,
              )
            ],
          );
  }

  DropdownMenuItem buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      );

  onTapped(int newIndex) {
    setState(() {
      currentStep = newIndex;
    });
  }

  onContinue() {
    if (currentStep != 6) {
      setState(() {
        currentStep += 1;
      });
    }
  }

  deleteVideo() {
    setState(() {
      isThereVideo = false;
      videoFile = null;
    });
  }

  onCancel() {
    setState(() {
      if (currentStep == 0) {
        myController[0].clear();
        dropMenuValue = null;
        otherActive = false;
        errorOther = null;
      }
      if (currentStep == 1) {
        myController[1].clear();
      }
      if (currentStep == 2) {
        myController[2].clear();
      }
      if (currentStep == 3) {
        deleteAllPicture();
      }
      if (currentStep == 4) {
        deleteVideo();
      }
      if (currentStep == 5) {
        val = 'Private';
      }
      if (currentStep != 0) {
        currentStep -= 1;
      }
    });
  }

  deleteAllPicture() {
    setState(() {
      availableTryPictures = -1;
      isTherePictures = false;
      for (int i = 0; i < images.length; i++) {
        images.clear();
      }
    });
  }

  recordVideo() async {
    await getVideoFromCamara();
    if (cameraGetvideo == true) {
      setState(() {
        isThereVideo = true;
      });
    }
  }

  selectedMenuValue(value) {
    setState(() {
      dropMenuValue = value;
      if (value == 'Other') {
        otherActive = true;
      } else {
        otherActive = false;
      }
    });
  }

  takePictures(int source) async {
    if (source == 0) {
      await getImageFromCamera();
    } else {
      await getImageFromGallery();
    }

    if (cameraGetimage == true) {
      setState(() {
        availableTryPictures++;
        if (availableTryPictures < 0) {
          isTherePictures = false;
        } else {
          isTherePictures = true;
        }
      });
    }
  }

  viewVideo() async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => DisplayVideoScreen(
                  videoFile: videoFile!,
                )),
      );
    } catch (e) {
      // If an error occurs, log the error to the console.

    }
  }

  viewPicture(int index) async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DisplayPictureScreen(
            imagePath: images.elementAt(index),
            number: index,
          ),
        ),
      );
    } catch (e) {
      // If an error occurs, log the error to the console.

    }
  }

  deletPicture(int index) {
    setState(() {
      images.removeAt(index);
      availableTryPictures--;
      cameraGetimage = false;
    });
  }

  bool valid() {
    bool chk1 = true;
    chkEverything = false;
    genrlError = '';
    errorOther = null;
    descriptionError = null;
    setState(() {
      loading = true;
      if (myController[0].text.isEmpty && dropMenuValue == 'Other') {
        errorOther = 'You can not leave the type of issus empty';
        chk1 = false;
        chkEverything = true;
        currentStep = 0;
      }
      if (dropMenuValue == null) {
        genrlError = 'Must choose your type of issue';
        currentStep = 0;
        chk1 = false;
        chkEverything = true;
      }
      if (myController[1].text.isEmpty) {
        descriptionError = 'Must write your description of issue';
        currentStep = 1;
        chk1 = false;
        chkEverything = true;
      }
      if (chk1) {
        if (!getInitialized()) {
          chkEverything = true;
          chk1 = false;
        }
      }
    });
    return chk1;
  }

  bool getInitialized() {
    String cleanString = filter.censor(myController[1].text);
    String typeOfIssue;
    Ticket _ticket;

    if (myController[0].text.isEmpty) {
      typeOfIssue = dropMenuValue!;
    } else {
      typeOfIssue = myController[0].text;
    }

    if (myController[2].text.isNotEmpty) {
      setState(() {
        targetUser!.address == myController[2].text;
      });
    }
    if (videoFile != null) {
      _ticket = Ticket(
          dateTime: DateTime.now(),
          description: cleanString,
          userId: targetUser!.uid!,
          type: typeOfIssue,
          status: 0,
          location: targetUser!.address!,
          attachmentsImages: images,
          privacy: isPrivacy,
          userName: targetUser!.name,
          attachmentVideo: File(videoFile!.path),
          attachmentsImagesUrlData: []);
    } else {
      _ticket = Ticket(
          dateTime: DateTime.now(),
          description: cleanString,
          userId: targetUser!.uid!,
          type: typeOfIssue,
          status: 0,
          location: targetUser!.address!,
          attachmentsImages: images,
          privacy: isPrivacy,
          userName: targetUser!.name,
          attachmentsImagesUrlData: []);
    }

    try {
      DatabaseFeatures(uidUser: targetUser!.uid).pushNewTicket(_ticket);
    } catch (e) {
      genrlError = e.toString();
      return false;
    }
    return true;
  }

  dailog() {
    if (valid() && !chkEverything) {
      setDefault();
      setState(() {
        loading = false;
      });
      return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Ticket'),
          contentPadding: const EdgeInsets.all(20.0),
          backgroundColor: const Color.fromARGB(255, 85, 200, 205),
          children: [
            const Text(
              'The Ticket has submitted successfully.',
              textAlign: TextAlign.center,
            ),
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              child: TextButton(
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color.fromARGB(255, 18, 49, 85)),
                ),
                onPressed: () => {Navigator.of(context).pop()},
              ),
            )
          ],
        ),
      );
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  setDefault() {
    setState(() {
      otherActive = false;
      isTherePictures = false;
      chkEverything = false;
      isThereVideo = false;
      cameraGetimage = false;
      cameraGetvideo = false;
      currentStep = 0;
      availableTryPictures = -1;
      dropMenuValue = 'Plumbing';
      errorOther = null;
      genrlError = null;
      descriptionError = null;
      videoFile = null;
      if (imageCache != null) {
        imageCache!.clear();
      }

      for (int i = 0; i < myController.length; i++) {
        myController[i].clear();
      }
      images.clear();
    });
  }

  Future getImageFromCamera() async {
    cameraGetimage = false;
    final image = await (imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 25));
    if (image != null && image.path.isNotEmpty) {
      images.add(File(image.path));
      cameraGetimage = true;
    }
  }

  Future getImageFromGallery() async {
    cameraGetimage = false;
    final image = await (imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 25));
    if (image != null && image.path.isNotEmpty) {
      images.add(File(image.path));
      cameraGetimage = true;
    }
  }

  getVideoFromCamara() async {
    cameraGetvideo = false;
    XFile? video = await imagePicker.pickVideo(
        source: ImageSource.camera, maxDuration: const Duration(seconds: 60));
    if (video != null && video.path.isNotEmpty) {
      videoFile = video;
      cameraGetvideo = true;
    }
  }

  viewImage(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3, top: 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.black.withOpacity(0.1)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: FileImage(images.elementAt(index)),
          radius: 25.0,
          backgroundColor: Colors.cyanAccent.withOpacity(0.5),
        ),
        title: Text('Picture ${index + 1}'),
        subtitle: const Text('Click To view it'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_rounded),
          onPressed: () {
            deletPicture(index);
          },
        ),
        onTap: () {
          viewPicture(index);
        },
      ),
    );
  }
}
