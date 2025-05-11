import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchPage extends StatefulWidget {
  List news;
  final Function timeFun;
  SearchPage({super.key, required this.news, required this.timeFun});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController controller = TextEditingController();
  final List<String> languages = [
    'English',
    'Hindi',
    'French',
    'German',
    'Japanese',
    'Arabic',
    'Chinese',
    'Spanish',
    'Russian'
  ];

  final Map<String, String> langCodeMap = {
    'English': 'en',
    'Hindi': 'hi',
    'French': 'fr',
    'German': 'de',
    'Japanese': 'ja',
    'Arabic': 'ar',
    'Chinese': 'zh',
    'Spanish': 'es',
    'Russian': 'ru',
  };

  DateTime? fromDate;
  DateTime? toDate;
  String? initLanguage = 'English';
  List filteredNews = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        filteredNews = List.from(widget.news);
      });
    });
  }

  Future<void> fetch(String search) async {
    final String languageCode = langCodeMap[initLanguage ?? 'English'] ?? 'en';
    final String from = fromDate != null ? fromDate!.toIso8601String().split('T').first : '';
    final String to = toDate != null ? toDate!.toIso8601String().split('T').first : '';

    String apiUrl = 'https://newsapi.org/v2/everything?q=$search'
        '&language=$languageCode'
        '${from.isNotEmpty ? '&from=$from' : ''}'
        '${to.isNotEmpty ? '&to=$to' : ''}'
        '&sortBy=popularity&apiKey=60dd2429ca784ddaac5934b7a9acbf94';

    final response = await http.get(Uri.parse(apiUrl));
    final data = json.decode(response.body);

    setState(() {
      widget.news = data['articles'] ?? [];
      filteredNews = List.from(widget.news);
    });
  }

  void onSearch() async {
    String userSearch = controller.text.trim();
    if (userSearch.isNotEmpty) {
      await fetch(userSearch);
    }
  }

  void applyFilters({String? query}) {
    setState(() {
      filteredNews = widget.news.where((item) {
        final publishedAt = item['publishedAt'] ?? '';
        DateTime? publishedDate;
        try {
          publishedDate = DateTime.parse(publishedAt);
        } catch (_) {}

        final matchFromDate = fromDate == null ||
            (publishedDate != null &&
                publishedDate.isAfter(fromDate!.subtract(const Duration(days: 1))));
        final matchToDate = toDate == null ||
            (publishedDate != null &&
                publishedDate.isBefore(toDate!.add(const Duration(days: 1))));

        return matchFromDate && matchToDate;
      }).toList();
    });
  }

  Future<void> filterSheet(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              final screenHeight = MediaQuery.of(context).size.height;
              return Container(
                height: screenHeight * 0.9,
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Filter',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text('Select Date',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000, 1),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => fromDate = picked);
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xffebdbfc),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                fromDate == null
                                    ? 'From Date'
                                    : fromDate.toString().split(' ')[0],
                                style: TextStyle(color: Colors.black),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_drop_down_sharp,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000, 1),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() => toDate = picked);
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xffebdbfc),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                toDate == null ? 'To Date' : toDate.toString().split(' ')[0],
                                style: TextStyle(color: Colors.black),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_drop_down_sharp,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Select Language',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: GridView.builder(
                        itemCount: languages.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 3,
                        ),
                        itemBuilder: (context, index) {
                          final newsLan = languages[index];
                          final lanSelect = initLanguage == newsLan;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => initLanguage = newsLan);
                            },
                            child: Card(
                              color: lanSelect ? Color(0xffbf88fb) : Color(0xffebdbfc),
                              child: Center(
                                  child: Text(
                                    newsLan,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300),
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          applyFilters(query: controller.text);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(19),
                          backgroundColor: Color(0xff9c67f4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          "Apply Filter",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w200),
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xffba7bfd),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 28.0,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.arrow_right_alt_rounded,
                            color: Colors.white,
                            size: 32.0,
                          ),
                          onPressed: onSearch,
                        ),
                        hintText: "Search news (e.g. sports, health)...",
                        hintStyle: TextStyle(color: Colors.white70),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff9948ef)),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff9948ef)),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => filterSheet(context),
                    icon: Icon(
                      Icons.menu,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      size: 32.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: MasonryGridView.builder(
                  gridDelegate:
                  const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
                  itemCount: filteredNews.length,
                  itemBuilder: (context, index) {
                    final source = filteredNews[index];
                    return GestureDetector(
                      onTap: () {},
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (source['urlToImage'] != null)
                                Image.network(source['urlToImage']),
                              const SizedBox(height: 10),
                              Text(
                                source['description'] ?? 'No Description',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.timeFun(source['publishedAt'] ?? ''),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
            ],
          ),
        ),
      ),
    );
  }
}


//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//
// class SearchPage extends StatefulWidget {
//   List news;
//   final Function timeFun;
//   SearchPage({super.key, required this.news, required this.timeFun});
//
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> {
//   TextEditingController controller = TextEditingController();
//   final List<String> languages = [
//
//     'English',
//     'Hindi',
//     'French',
//     'German',
//     'Japanese',
//     'Arabic',
//     'Chinese',
//     'Spanish',
//     'Russian'
//   ];
//
//   DateTime? fromDate;
//   DateTime? toDate;
//   String? initLanguage='en';
//   List filteredNews = [];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         filteredNews = List.from(widget.news);
//       });
//     });
//   }
//
//   Future<void> fetch(String search) async {
//     final String apiUrl =
//     'https://newsapi.org/v2/everything?q=$search&lang=en&from=2025-05-10&to=2025-05-10&sortBy=popularity&apiKey=60dd2429ca784ddaac5934b7a9acbf94';
//         // 'https://gnews.io/api/v4/search?q=$search&max=100&lang=en&from=2025-05-11&sortBy=publishedAt&apikey=3aed44bf8f81930ab1d48b6d751c46a2';
//     final response = await http.get(Uri.parse(apiUrl));
//     final data = json.decode(response.body);
//     setState(() {
//       widget.news = data['articles'] ?? [];
//     });
//   }
//
//   void onSearch() async {
//     String userSearch = controller.text.trim();
//     if (userSearch.isNotEmpty) {
//       await fetch(userSearch);
//       await Future.delayed(const Duration(milliseconds: 50));
//
//       await fetch(userSearch);
//     }
//   }
//
//   void applyFilters({String? query}) {
//     final lowerQuery = query?.toLowerCase() ?? '';
//
//     setState(() {
//       filteredNews = widget.news.where((item) {
//         final description = (item['description'] ?? '').toLowerCase();
//         final lang = item['language'] ?? '';
//         final publishedAt = item['publishedAt'] ?? '';
//
//         DateTime? publishedDate;
//         try {
//           publishedDate = DateTime.parse(publishedAt);
//         } catch (_) {}
//
//         final matchQuery =
//             lowerQuery.isEmpty || description.contains(lowerQuery);
//         final matchLang = initLanguage == null || lang == initLanguage;
//         final matchFromDate = fromDate == null ||
//             (publishedDate != null &&
//                 publishedDate
//                     .isAfter(fromDate!.subtract(const Duration(days: 1))));
//         final matchToDate = toDate == null ||
//             (publishedDate != null &&
//                 publishedDate.isBefore(toDate!.add(const Duration(days: 1))));
//
//         return matchQuery && matchLang && matchFromDate && matchToDate;
//       }).toList();
//     });
//   }
//
//   Future<void> filterSheet(BuildContext context) async {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final result = await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//             builder: (BuildContext context, StateSetter setModalState) {
//               final screenHeight = MediaQuery.of(context).size.height;
//               return Container(
//                 height: screenHeight * 0.9,
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.grey[900] : Colors.white,
//                   borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Center(
//                       child: Text(
//                         'Filter',
//                         style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     const Text('Select Date',
//                         style:
//                         TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         TextButton(
//                           onPressed: () async {
//                             final picked = await showDatePicker(
//                               context: context,
//                               firstDate: DateTime(2000, 1),
//                               lastDate: DateTime.now(),
//                             );
//                             if (picked != null) {
//                               setModalState(() => fromDate = picked);
//                             }
//                           },
//                           style: TextButton.styleFrom(
//                             backgroundColor: Color(0xffebdbfc), // Violet background
//                             padding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 fromDate == null
//                                     ? 'From Date'
//                                     : fromDate.toString().split(' ')[0],
//                                 style: TextStyle(color: Colors.black), // White text
//                               ),
//                               const SizedBox(width: 8),
//                               const Icon(
//                                 Icons.arrow_drop_down_sharp,
//                                 color: Colors.black,
//                                 size: 20,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         TextButton(
//                           onPressed: () async {
//                             final picked = await showDatePicker(
//                               context: context,
//                               firstDate: DateTime(2000, 1),
//                               lastDate: DateTime.now(),
//                             );
//                             if (picked != null) {
//                               setModalState(() => toDate = picked);
//                             }
//                           },
//                           style: TextButton.styleFrom(
//                             backgroundColor: Color(0xffebdbfc), // Violet background
//                             padding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 toDate == null
//                                     ? 'To Date'
//                                     : toDate.toString().split(' ')[0],
//                                 style: TextStyle(color: Colors.black), // White text
//                               ),
//                               const SizedBox(width: 8),
//                               const Icon(
//                                 Icons.arrow_drop_down_sharp,
//                                 color: Colors.black,
//                                 size: 20,
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     const Text('Select Language',
//                         style:
//                         TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
//                     const SizedBox(height: 10),
//                     Expanded(
//                       child: GridView.builder(
//                         itemCount: languages.length,
//                         gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                           childAspectRatio: 3,
//                         ),
//                         itemBuilder: (context, index) {
//                           final newsLan = languages[index];
//                           final lanSelect = initLanguage == newsLan;
//                           return GestureDetector(
//                             onTap: () {
//                               setModalState(() => initLanguage = newsLan);
//                             },
//                             child: Card(
//                               color:
//                               lanSelect ? Color(0xffbf88fb) : Color(0xffebdbfc),
//                               child: Center(
//                                   child: Text(
//                                     newsLan,
//                                     style: TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w300),
//                                   )),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           applyFilters(query: controller.text);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.all(19),
//                           backgroundColor: Color(0xff9c67f4), // Violet color
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.circular(50), // Rounded corners
//                           ),
//                         ),
//
//                         child: const Text(
//                           "Apply Filter",
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w200),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               );
//             });
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child:Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: controller,
//                       onChanged: (value) => applyFilters(query: value),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Color(0xffba7bfd),
//                         prefixIcon: Icon(
//                           Icons.search,
//                           color: Colors.white,
//                           size: 28.0,
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             Icons.arrow_right_alt_rounded,
//                             color: Colors.white,
//                             size: 32.0,
//                           ),
//                           onPressed: onSearch,
//                         ),
//                         hintText: "Search news (e.g. sports, health)...",
//                         hintStyle: TextStyle(color: Colors.white70),
//                         contentPadding:
//                         EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Color(0xff9948ef),
//                           ),
//                           borderRadius: BorderRadius.circular(60),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                             color: Color(0xff9948ef),
//                           ),
//                           borderRadius: BorderRadius.circular(40),
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                       style: TextStyle(
//                           color: Colors.white), // text color inside field
//                       cursorColor: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   IconButton(
//                     onPressed: () => filterSheet(context),
//                     icon: Icon(
//                       Icons.menu,
//                       color: Theme.of(context).brightness == Brightness.dark
//                           ? Colors.white
//                           : Colors.black,
//                       size: 32.0,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: MasonryGridView.builder(
//                   gridDelegate:
//                   const SliverSimpleGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 1),
//                   itemCount: filteredNews.length,
//                   itemBuilder: (context, index) {
//                     final source = filteredNews[index];
//                     return GestureDetector(
//                       onTap: () {},
//                       child: Card(
//                         elevation: 4,
//                         margin: const EdgeInsets.symmetric(vertical: 10),
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (source['urlToImage'] != null)
//                                 Image.network(source['urlToImage']),
//                               const SizedBox(height: 10),
//                               Text(
//                                 source['description'] ?? 'No Description',
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 widget.timeFun(source['publishedAt'] ?? ''),
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
