

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final Function(List) newsCallback;
  final Function timeFun;
  const HomePage(
      {super.key, required this.newsCallback, required this.timeFun});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List news = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    const apiUrl =
    'https://newsapi.org/v2/everything?q=all&lang=en&from=2025-05-09&sortBy=publishedAt&apiKey=60dd2429ca784ddaac5934b7a9acbf94';
    //     'https://gnews.io/api/v4/search?q=example&max=100&lang=all&from=2025-05-11&sortBy=publishedAt&apikey=3aed44bf8f81930ab1d48b6d751c46a2';
    final response = await http.get(Uri.parse(apiUrl));
    final data = json.decode(response.body);
    setState(() => news = data['articles'] ?? []);
    widget.newsCallback(news);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffba7bfd),
        toolbarHeight: 80,
        centerTitle: true,
        shape:
        ContinuousRectangleBorder(borderRadius: BorderRadius.circular(150)),
        title: const

           Text(' Around you', style: TextStyle(color: Colors.white)),

      ),
      body: news.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: news.length,
          itemBuilder: (context, index) {
            final article = news[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: article['urlToImage'] != null
                            ? Image.network(article['urlToImage'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover)
                            : Container(
                          width: 100,
                          height: 100,
                          color: const Color(0xffcec9e4),
                          child:
                          const Icon(Icons.image_not_supported),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['title'] ?? 'No Title',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.timeFun(article['publishedAt']),
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xff68647c)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
