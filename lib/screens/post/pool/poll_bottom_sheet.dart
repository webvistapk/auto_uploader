import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile/common/app_text_styles.dart';
import 'package:mobile/common/message_toast.dart';
import 'package:mobile/models/UserProfile/post_model.dart';

import 'package:http/http.dart' as http;
import 'package:mobile/prefrences/prefrences.dart';

postVote(int postId, String authToken, context) async {
  // debugger();
  final url = 'http://147.79.117.253:8001/api/posts/vote/new/$postId/';
  final headers = {
    'Authorization': 'Bearer $authToken',
  };

  try {
    final response = await http.post(Uri.parse(url), headers: headers);
    // debugger();
    if (response.statusCode == 201) {
      print('Vote posted successfully');
      return true;
    } else {
      //ToastNotifier.showErrorToast(
      // context, 'Failed to post vote: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    //ToastNotifier.showErrorToast(context, 'Error posting vote: $e');
    return false;
  }
}

Poll? selectedPollOption;
bool isLoadingPoll = false;
int calculateTotalVotes(List<Poll> polls) {
  return polls.fold(0, (sum, poll) => sum + poll.voteCount);
}

void showPollModal(BuildContext context, List<Poll> pollPost, String pollTitle,
    String pollDescription) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.brown.shade300,
                ),
                child: Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pollTitle,
                          style: AppTextStyles.poppinsBold(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pollDescription,
                          textAlign: TextAlign.center,
                          style:
                              AppTextStyles.poppinsRegular(color: Colors.white),
                        ),
                      ]),
                ),
              ),
              const SizedBox(height: 20),
              ...pollPost.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPollOption = option;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedPollOption == option
                            ? Colors.blueAccent
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          if (selectedPollOption == option)
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          option.poll,
                          style: TextStyle(
                            color: selectedPollOption == option
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: selectedPollOption != null
                      ? () async {
                          setState(() {
                            isLoadingPoll = true;
                          });
                          final authToken = await Prefrences.getAuthToken();
                          final response = await postVote(
                              selectedPollOption!.id, authToken, context);

                          if (response) {
                            setState(() {
                              isLoadingPoll = false;
                            });
                            Navigator.pop(context);

                            showPercentageResult(context, pollPost, true,pollTitle,pollDescription);
                          }
                          setState(() {
                            isLoadingPoll = false;
                          });
                        }
                      : null,
                  child: isLoadingPoll
                      ? Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : Text("Next",
                          style: selectedPollOption == null
                              ? null
                              : AppTextStyles.poppinsBold(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      );
    },
  );
}

void showPercentageResult(
    BuildContext context, List<Poll> pollData, bool isAdd,String pollTitle, pollDescription) {
  // Update the vote count if `isAdd` is true
  if (isAdd && selectedPollOption != null) {
    final selectedOptionIndex =
        pollData.indexWhere((poll) => poll.id == selectedPollOption!.id);

    if (selectedOptionIndex != -1) {
      pollData[selectedOptionIndex] = Poll(
        id: selectedPollOption!.id,
        poll: selectedPollOption!.poll,
        voteCount: selectedPollOption!.voteCount + 1,
        isVoted: true,
      );
    }
  }

  // Calculate the total votes after updating the selected poll option
  final totalVotes = calculateTotalVotes(pollData);
  log("Poll Calculate Vote: $totalVotes");

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.brown.shade300,
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pollTitle,
                    style: AppTextStyles.poppinsBold(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    pollDescription,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.poppinsRegular(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...pollData.map((option) {
            final double percentage =
                totalVotes > 0 ? (option.voteCount / totalVotes) : 0.0;
            log("Percentage: $percentage");

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 50,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option.poll,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${(percentage * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                  color: percentage > 0.0
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: AppTextStyles.poppinsBold(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}
