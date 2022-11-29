import 'package:flutter/material.dart';
import 'package:pagination_app/post_item.dart';
import 'package:pagination_app/post_model.dart';
import 'package:http/http.dart';
import 'dart:convert';

class PostScreen extends StatefulWidget {
  PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late bool _isLastPage;
  late int _pageNumber;
  late bool _error;
  late bool _loading;
  final int _numberOfPostsPerRequest = 10;
  late List<Post> _posts;
  final int _nextPageTrigger = 3;

  @override
  void initState() {
    super.initState();
    _pageNumber = 0;
    _posts = [];
    _isLastPage = false;
    _loading = true;
    _error = false;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Blog App"),
          centerTitle: true,
        ),
        body: buildPostsView(),
      ),
    );
  }

  Widget buildPostsView() {
    if (_posts.isEmpty) {
      if (_loading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (_error) {
        return Center(
          child: errorDialog(size: 20),
        );
      }
    }
    return ListView.builder(
        itemCount: _posts.length + (_isLastPage ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == _posts.length - _nextPageTrigger) {
            fetchData();
          }
          if (index == _posts.length) {
            if (_error) {
              return Center(
                child: errorDialog(size: 15),
              );
            } else {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }
          final Post post = _posts[index];
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: PostItem(
              title: post.title,
              body: post.body,
            ),
          );
        });
  }

  Widget errorDialog({required double size}) {
    return SizedBox(
        height: 180,
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "An error occured while fetching posts",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = false;
                  fetchData();
                });
              },
              child: const Text(
                "Retry",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.purpleAccent,
                ),
              ),
            ),
          ],
        ));
  }

  Future fetchData() async {
    try {
      final response = await get(Uri.parse(
          "https://jsonplaceholder.typicode.com/posts?_page=$_pageNumber&_limit=$_numberOfPostsPerRequest"));
      List responseList = json.decode(response.body);
      List<Post> postList = responseList
          .map((data) => Post(data['title'], data['body']))
          .toList();
      setState(() {
        _posts.addAll(postList);
        _loading = false;
        _pageNumber++;
        _isLastPage = postList.length < _numberOfPostsPerRequest;
      });
    } catch (e) {
      print("error --> $e");
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }
}
