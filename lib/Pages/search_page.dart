import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../Services/photo_service.dart';
import '../model/photo.dart';
import 'Photos/detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final PhotoService _photoService = PhotoService();

  List<Photo> allPhotos = [];
  List<Photo> recentPhotos = [];
  List<Photo> searchResults = [];
  bool loading = true;
  bool searching = false;
  int _currentSlide = 0;


  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPhotos() async {
    setState(() => loading = true);
    try {
      final result = await _photoService.getPhotos();
      setState(() {
        allPhotos = result;
        recentPhotos = result.take(3).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data: $e"),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void searchPhotos(String query) {
    if (query.isEmpty) {
      setState(() {
        searching = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      searching = true;
      searchResults = allPhotos.where((photo) {
        final titleMatch = photo.title.toLowerCase().contains(query.toLowerCase());
        final descMatch = photo.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final userMatch = photo.userName?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return titleMatch || descMatch || userMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C63FF),
                ),
              )
            : Column(
                children: [
                  // Header & Search Bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6C63FF).withOpacity(0.1),
                          const Color(0xFF4834DF).withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Discover",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Explore amazing photos",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1F3A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: searchPhotos,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search photos, users...",
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: Color(0xFF6C63FF),
                                  size: 20,
                                ),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        searchPhotos('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recent Photos Slider
                          if (!searching && recentPhotos.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Latest Uploads",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CarouselSlider.builder(
                              itemCount: recentPhotos.length,
                              options: CarouselOptions(
                                height: 280,
                                viewportFraction: 0.85,
                                enlargeCenterPage: true,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 4),
                                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                onPageChanged: (index, reason) {
                                  setState(() => _currentSlide = index);
                                },
                              ),
                              itemBuilder: (context, index, realIndex) {
                                final photo = recentPhotos[index];
                                final imageUrl = photo.imagePath.startsWith('http')
                                    ? photo.imagePath
                                    : "http://127.0.0.1:8000/${photo.imagePath}";

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PhotoDetailPage(photo: photo),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, progress) {
                                              if (progress == null) return child;
                                              return Container(
                                                color: const Color(0xFF1A1F3A),
                                                child: const Center(
                                                  child: CircularProgressIndicator(
                                                    color: Color(0xFF6C63FF),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: const Color(0xFF1A1F3A),
                                                child: const Icon(
                                                  Icons.broken_image_outlined,
                                                  color: Colors.white54,
                                                  size: 60,
                                                ),
                                              );
                                            },
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.7),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 20,
                                            left: 20,
                                            right: 20,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  photo.title,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (photo.userName != null) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.person,
                                                        color: Colors.white70,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        photo.userName!,
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
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
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: recentPhotos.asMap().entries.map((entry) {
                                return Container(
                                  width: _currentSlide == entry.key ? 24 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: _currentSlide == entry.key
                                        ? const Color(0xFF6C63FF)
                                        : Colors.white.withOpacity(0.3),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Section Title
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  searching
                                      ? "Search Results (${searchResults.length})"
                                      : "All Photos",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Masonry Grid
                          searching && searchResults.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 80,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "No results found",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Try different keywords",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.3),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _buildMasonryGrid(searching ? searchResults : allPhotos),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMasonryGrid(List<Photo> photos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columnCount;
        double screenWidth = MediaQuery.of(context).size.width;

        if (screenWidth >= 900) {
          columnCount = 4;
        } else if (screenWidth >= 600) {
          columnCount = 3;
        } else {
          columnCount = 2;
        }

        // Bagi foto ke dalam kolom
        List<List<Photo>> columns = List.generate(columnCount, (_) => []);
        
        for (int i = 0; i < photos.length; i++) {
          columns[i % columnCount].add(photos[i]);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(columnCount, (columnIndex) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: columnIndex == 0 ? 0 : 4,
                    right: columnIndex == columnCount - 1 ? 0 : 4,
                  ),
                  child: Column(
                    children: columns[columnIndex].map((photo) {
                      final imageUrl = photo.imagePath.startsWith('http')
                          ? photo.imagePath
                          : "http://127.0.0.1:8000/${photo.imagePath}";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PhotoDetailPage(photo: photo),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          color: const Color(0xFF1A1F3A),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF6C63FF),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          color: const Color(0xFF1A1F3A),
                                          child: const Icon(
                                            Icons.broken_image_outlined,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                    child: Text(
                                      photo.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}