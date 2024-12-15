import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/random_user_list_res.dart';
import '../services/http_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List<RandomUser> userList = [];
  ScrollController scrollController = ScrollController();
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    loadRandomUserList();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent <= scrollController.offset) {
        loadRandomUserList();
      }
    });
  }

  loadRandomUserList() async {
    setState(() {
      isLoading = true;
    });

    var response = await Network.GET(Network.API_RANDOM_USER_LIST, Network.paramsRandomUserList(currentPage));
    var randomUserListRes = Network.parseRandomUserList(response!);
    currentPage = randomUserListRes.info.page + 1;

    setState(() {
      userList.addAll(randomUserListRes.results);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(232, 232, 232, 1),
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Random User - SetState"),
        ),
        body: Stack(
          children: [
            ListView.builder(
              controller: scrollController,
              itemCount: userList.length,
              itemBuilder: (ctx, index) {
                return _itemOfRandomUser(userList[index], index);
              },
            ),
            isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : const SizedBox.shrink(),
          ],
        ));
  }

  Widget _itemOfRandomUser(RandomUser randomUser, int index) {
    return Container(
        color: Colors.white,
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CachedNetworkImage(
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              imageUrl: randomUser.picture.medium,
              placeholder: (context, url) => Container(
                height: 80,
                width: 80,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: 80,
                width: 80,
                color: Colors.grey,
                child: const Icon(Icons.error),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${index} - ${randomUser.name.first} ${randomUser.name.last}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    randomUser.email,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                  Text(
                    randomUser.cell,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}