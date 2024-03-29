import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:reviews_slider/reviews_slider.dart';
import 'package:sars/Control/Services/database_services.dart';
import 'package:sars/Model/ticket.dart';
import 'package:sars/View/Containers/view_image_builder.dart';
import 'package:sars/View/Containers/view_video_builder.dart';

class TicketViewBuilder extends StatefulWidget {
  final Ticket ticket;
  final String? traget;
  const TicketViewBuilder({
    Key? key,
    required this.ticket,
    this.traget,
  }) : super(key: key);

  @override
  State<TicketViewBuilder> createState() => _TicketBuilderState();
}

class _TicketBuilderState extends State<TicketViewBuilder> {
  final DatabaseFeatures _databaseFeatures = DatabaseFeatures();
  Ticket? ticket;
  TextEditingController cancelTicketField = TextEditingController();
  TextEditingController feedbackField = TextEditingController();
  final filter = ProfanityFilter();
  bool radioBtn = false;
  String isPrivacy = 'Private';
  String val = 'Private';
  String? errorCancel;
  int selectedValueRate = 3;
  final String videoIcon =
      'https://firebasestorage.googleapis.com/v0/b/sars-e6e88.appspot.com/o/resident%2Fprofile%2Ficons8_video_96px.png?alt=media&token=2e82595a-2f9b-4339-94fb-26c7f00c06d3';

  @override
  Widget build(BuildContext context) {
    ticket = widget.ticket;
    String isHome = widget.traget!;
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      padding: const EdgeInsets.all(5),
      decoration: targetColorIssue(ticket!.status),
      child: SingleChildScrollView(
          child: Container(
        margin: const EdgeInsets.all(10),
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              isHome == 'Home'
                  ? SingleChildScrollView(
                      child: Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(10),
                          child: Text(ticket!.userName!)))
                  : Container(),
              SingleChildScrollView(
                  child: Container(
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                          DateFormat.yMMMMEEEEd()
                              .add_jm()
                              .format(ticket!.dateTime),
                          style: const TextStyle(
                            fontSize: 18,
                          )))),
              SingleChildScrollView(
                child: getContainerForAll(Text(
                  'Ticket Status: ${targetStatus(ticket!.status)}',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                )),
              ),
              getContainerForAll(Text(
                'Ticket Issue: ${ticket!.type}',
                style: const TextStyle(
                  fontSize: 20,
                ),
              )),
              getContainerForAll(Text(
                'Ticket Description: ${ticket!.description}',
                style: const TextStyle(
                  fontSize: 20,
                ),
              )),
              ticket!.location.isNotEmpty
                  ? getContainerForAll(
                      Text('Ticket Location: ${ticket!.location}',
                          style: const TextStyle(
                            fontSize: 20,
                          )))
                  : Container(),
              ticket!.remark != null && ticket!.remark!.isNotEmpty
                  ? getContainerForAll(Text('Remark: ${ticket!.remark}',
                      style: const TextStyle(
                        fontSize: 20,
                      )))
                  : Container(),
              ticket!.attachmentsImagesUrlData.isNotEmpty ||
                      ticket!.videoURL!.isNotEmpty
                  ? SingleChildScrollView(
                      child: Column(children: [
                      Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'Attachments:',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )),
                      ticket!.attachmentsImagesUrlData.isNotEmpty
                          ? getContainerForAll(Container(
                              //if there Is images
                              alignment: Alignment.topCenter,
                              margin: const EdgeInsets.only(
                                  bottom: 4, left: 4, right: 4, top: 0),
                              padding: const EdgeInsets.all(10),
                              child: SingleChildScrollView(
                                child: Column(children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.all(10),
                                      child: const Text('Images',
                                          style: TextStyle(fontSize: 20))),
                                  ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount:
                                        ticket!.attachmentsImagesUrlData.length,
                                    itemBuilder: (context, index) {
                                      return viewImageORVideo(index, 0);
                                    },
                                  )
                                ]),
                              )))
                          : Container(),
                      ticket!.videoURL!.isNotEmpty
                          ? getContainerForAll(Column(children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.all(10),
                                  child: const Text('Video',
                                      style: TextStyle(fontSize: 20))),
                              viewImageORVideo(0, 1)
                            ]))
                          : Container()
                    ]))
                  : Container(),
              (ticket!.status == 2 && isHome == 'Histroy') &&
                      (ticket!.rate == null &&
                          (ticket!.feeddback == null ||
                              ticket!.feeddback!.isEmpty))
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.all(10),
                              child: const Text(
                                'Rate & Feedback',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color:
                                      const Color.fromARGB(120, 169, 225, 228)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'How was the help you received?',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ReviewSlider(
                                    circleDiameter: 47,
                                    onChange: onChangeRate,
                                  ),
                                  // const SizedBox(height: 10),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: TextFormField(
                                      style:
                                          const TextStyle(color: Colors.black),
                                      autocorrect: true,
                                      decoration: const InputDecoration(
                                          hintText: 'What\'s Your Feedback'),
                                      minLines: 1,
                                      maxLines: 5,
                                      keyboardType: TextInputType
                                          .multiline, // user keyboard will have a button to move cursor to next line
                                      maxLength: 250,
                                      controller: feedbackField,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    child: const Text('Submit'),
                                    onPressed: () async {
                                      String cleanString = filter
                                          .censor(feedbackField.text.trim());
                                      _databaseFeatures.updateRateAndFeedback(
                                          idTicket: ticket!.ticketID,
                                          feedback: cleanString,
                                          rate: selectedValueRate);
                                    },
                                  ),
                                  const SizedBox(height: 5)
                                ],
                              )),
                        ],
                      ),
                    )
                  : Container(),
              ticket!.rate != null ||
                      (ticket!.feeddback != null &&
                          ticket!.feeddback!.isNotEmpty)
                  ? Column(children: [
                      Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'Rate & Feedback',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )),
                      getContainerForAll(drowStarsAndFeedback(
                          stars: ticket!.rate, feedback: ticket!.feeddback))
                    ])
                  : Container(),
              isHome == 'Home'
                  ? Container()
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(
                        alignment: Alignment.bottomRight,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 40,
                        ),
                        onPressed: () {
                          showBottomBox(0, context);
                        },
                      ),
                      ticket!.status == 0
                          ? IconButton(
                              alignment: Alignment.bottomRight,
                              icon: const Icon(
                                Icons.cancel_rounded,
                                color: Colors.red,
                                size: 40,
                              ),
                              onPressed: () {
                                showBottomBox(1, context);
                              },
                            )
                          : const SizedBox(),
                    ]),
            ])),
      )),
    );
  }

  Future showBottomBox(int option, BuildContext context) async {
    cancelTicketField.clear();
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.5),
      elevation: 10,
      builder: (
        context,
      ) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(150, 0, 117, 122),
                    Color.fromARGB(120, 219, 232, 233),
                  ],
                )),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                    child: option == 1
                        ? SingleChildScrollView(
                            child: Container(
                            margin: const EdgeInsets.all(15),
                            padding: const EdgeInsets.all(15),
                            child: getContainerForAll(
                              Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextFormField(
                                      autocorrect: true,
                                      decoration: InputDecoration(
                                          errorText: errorCancel,
                                          hintText:
                                              'Why do you want to cancel the ticket?'),
                                      minLines: 1,
                                      maxLines: 5,
                                      keyboardType: TextInputType
                                          .multiline, // user keyboard will have a button to move cursor to next line
                                      maxLength: 250,
                                      controller: cancelTicketField,
                                    ),
                                    ElevatedButton(
                                      child: const Text('Submit'),
                                      onPressed: () async {
                                        if (chkCancel()) {
                                          String cleanString = filter.censor(
                                              cancelTicketField.text.trim());
                                          _databaseFeatures.cancelTicket(
                                              ticket!.ticketID!, cleanString);
                                          Navigator.of(context).pop();
                                        } else {
                                          setState(
                                            () {
                                              errorCancel =
                                                  'Please tell us your reason';
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ]),
                            ),
                          ))
                        : SingleChildScrollView(
                            child: Container(
                            margin: const EdgeInsets.all(15),
                            padding: const EdgeInsets.all(15),
                            child: getContainerForAll(
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Edit privacy',
                                        style: TextStyle(fontSize: 25)),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.all(10),
                                      child: const Text(
                                        'This option allows others to examine the specifics of your ticket',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
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
                                              setState(
                                                () {
                                                  val = vale as String;
                                                  isPrivacy = val;
                                                },
                                              );
                                            },
                                          ),
                                          const Text('Private'),
                                        ])
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
                                              setState(
                                                () {
                                                  val = vale as String;
                                                  isPrivacy = val;
                                                },
                                              );
                                            },
                                          ),
                                          const Text('Public'),
                                        ]),
                                      ],
                                    ),
                                    ElevatedButton(
                                      child: const Text('Update'),
                                      onPressed: () async {
                                        await _databaseFeatures
                                            .editTicketPrivacy(
                                                ticket!.ticketID!, isPrivacy);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ]),
                            ),
                          ))));
          },
        );
      },
    );
  }

  targetColorIssue(int status) {
    Color? start;
    Color? end;
    Color? mid;

    switch (status) {
      case 0:
        start = Colors.grey.withOpacity(0.4);
        mid = Colors.grey.withOpacity(0.7);
        end = Colors.grey.withOpacity(0.3);
        break;
      case 1:
        start = Colors.blue.withOpacity(0.4);
        mid = Colors.blue.withOpacity(0.7);
        end = Colors.blue.withOpacity(0.3);
        break;
      case 2:
        start = Colors.green.withOpacity(0.4);
        mid = Colors.green.withOpacity(0.7);
        end = Colors.green.withOpacity(0.3);
        break;
      case 3:
        start = Colors.red.withOpacity(0.4);
        mid = Colors.red.withOpacity(0.7);
        end = Colors.red.withOpacity(0.3);
        break;
      case 4:
        start = Colors.deepOrange.withOpacity(0.4);
        mid = Colors.deepOrange.withOpacity(0.7);
        end = Colors.deepOrange.withOpacity(0.3);
        break;
      default:
        {
          start = Colors.purple.withOpacity(0.4);
          mid = Colors.purple.withOpacity(0.7);
          end = Colors.purple.withOpacity(0.3);
        }
    }

    BoxDecoration statusColor = BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
            colors: [start, mid, end],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight));

    return statusColor;
  }

  Container getContainerForAll(Widget contentContainer) {
    return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(10),
        child: contentContainer,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(120, 169, 225, 228)));
  }

  String targetStatus(int status) {
    List<String> statusText = [
      'Pending',
      'Approved',
      'Complete',
      'Rejected',
      'Canceled',
    ];
    if (status > statusText.length) {
      int gab = status - statusText.length;

      for (int i = 0; i < gab; i++) {
        statusText.add('Unknown status');
      }
    }
    return statusText.elementAt(status);
  }

  Container viewImageORVideo(int index, int option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3, top: 3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.black.withOpacity(0.1)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: option == 0
              ? NetworkImage(ticket!.attachmentsImagesUrlData.elementAt(index))
              : NetworkImage(videoIcon),
          radius: 25.0,
          backgroundColor: Colors.black.withOpacity(0.4),
        ),
        title: option == 0 ? Text('Picture ${index + 1}') : const Text('Video'),
        subtitle: const Text('Click To view it'),
        onTap: () {
          option == 0 ? viewPicture(index) : viewVideo();
        },
      ),
    );
  }

  dynamic viewPicture(int index) async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DisplayPictureScreen(
            url: ticket!.attachmentsImagesUrlData.elementAt(index),
            number: index,
          ),
        ),
      );
    } catch (e) {
      // If an error occurs, log the error to the console.

    }
  }

  dynamic viewVideo() async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => DisplayVideoScreen(
                  videoURL: ticket!.videoURL,
                )),
      );
    } catch (e) {
      // If an error occurs, log the error to the console.

    }
  }

  dynamic onChangeRate(int value) {
    setState(() {
      selectedValueRate = value;
    });
  }

  bool chkCancel() {
    String val = cancelTicketField.text.trim();
    if (val.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  dynamic drowStarsAndFeedback({int? stars, String? feedback}) {
    List<Widget> starsWidegt = [
      const Text('Rate:         ', style: TextStyle(fontSize: 20))
    ];
    for (int i = 0; i < 5; i++) {
      if (stars != null) {
        if (i <= stars) {
          starsWidegt.add(const Icon(
            Icons.star_outlined,
            color: Color.fromARGB(255, 255, 149, 41),
          ));
        } else {
          starsWidegt.add(const Icon(
            Icons.star_border_rounded,
            color: Color.fromARGB(255, 255, 149, 41),
          ));
        }
      } else {
        starsWidegt.add(const Icon(
          Icons.star_border_rounded,
          color: Color.fromARGB(255, 255, 149, 41),
        ));
      }
    }
    return Column(children: [
      Row(
        children: starsWidegt,
      ),
      const SizedBox(height: 8),
      feedback != null && feedback.isNotEmpty
          ? Row(
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Feedback: ',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )),
                const SizedBox(height: 3),
                Text(feedback, style: const TextStyle(fontSize: 18)),
              ],
            )
          : Container()
    ]);
  }
}
