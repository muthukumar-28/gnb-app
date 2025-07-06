import 'package:Gnb_Property/features/properties/properties_bloc.dart';
import 'package:Gnb_Property/features/properties/property_detail.dart';
import 'package:Gnb_Property/session_storage/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:Gnb_Property/utils/colors.dart';
import 'package:Gnb_Property/features/account/account.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PropertyScreen extends StatefulWidget {
  final List properties;
  const PropertyScreen({Key? key, required this.properties}) : super(key: key);

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  List<Map<String, dynamic>> _sortedProperties = [];
  String? _currentSortType;
  String _searchText = '';
  @override
  void initState() {
    super.initState();
    _sortedProperties = List<Map<String, dynamic>>.from(widget.properties);
  }

  void handleSort(String sortType) {
    setState(() {
      _currentSortType = sortType;

      if (sortType == 'property') {
        _sortedProperties.sort(
          (a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0),
        );
      } else if (sortType == 'price_asc') {
        _sortedProperties.sort(
          (a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0),
        );
      } else if (sortType == 'price_desc') {
        _sortedProperties.sort(
          (a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0),
        );
      } else if (sortType == 'area') {
        _sortedProperties.sort(
          (a, b) => (b['areaSqFt'] ?? 0).compareTo(a['areaSqFt'] ?? 0),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/home_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "User Name",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF222326),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            SessionStorage.getUserData();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountScreen(),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                              'assets/images/avatar.png',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        hintText: 'Search',
                        suffixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value.trim().toLowerCase();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Property list
              Expanded(
                child: BlocBuilder<ListPropertyBloc, ListPropertyState>(
                  builder: (context, state) {
                    if (state is ListPropertyLoaded) {
                      final properties = state.properties;
                      print(
                        "object ${_sortedProperties.isEmpty} ${_sortedProperties.length != properties.length} $_currentSortType",
                      );
                      _sortedProperties = List<Map<String, dynamic>>.from(
                        properties,
                      );
                      if (_currentSortType != null) {
                        final sortType = _currentSortType;
                        if (sortType == 'property') {
                          _sortedProperties.sort(
                            (a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0),
                          );
                        } else if (sortType == 'price_asc') {
                          _sortedProperties.sort(
                            (a, b) =>
                                (a['price'] ?? 0).compareTo(b['price'] ?? 0),
                          );
                        } else if (sortType == 'price_desc') {
                          _sortedProperties.sort(
                            (a, b) =>
                                (b['price'] ?? 0).compareTo(a['price'] ?? 0),
                          );
                        } else if (sortType == 'area') {
                          _sortedProperties.sort(
                            (a, b) => (b['areaSqFt'] ?? 0).compareTo(
                              a['areaSqFt'] ?? 0,
                            ),
                          );
                        }
                      }

                      if (_searchText != '') {
                        _sortedProperties =
                            _sortedProperties.where((property) {
                              final title =
                                  (property['title'] ?? '')
                                      .toString()
                                      .toLowerCase();
                              return title.contains(_searchText);
                            }).toList();
                      }

                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Properties',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.primaryTextColor,
                                  ),
                                ),
                                Text(
                                  'Total: ${_sortedProperties.length} Properties',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child:
                                  _sortedProperties.isNotEmpty
                                      ? ListView.builder(
                                        itemCount: _sortedProperties.length,
                                        padding: const EdgeInsets.only(
                                          bottom: 80,
                                        ),
                                        itemBuilder: (context, index) {
                                          final property =
                                              _sortedProperties[index];
                                          return buildPropertyCard(property);
                                        },
                                      )
                                      : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/mail_box.png',
                                              height: 130,
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No Properties Found',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    AppColor.primaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is ListPropertyLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ListPropertyError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Floating Buttons
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: 'sortBtn',
            backgroundColor: Colors.white,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder:
                    (context) => SortOptionsSheet(
                      currentSortType: _currentSortType,
                      onSortSelected: handleSort,
                    ),
              );
            },
            icon: const Icon(Icons.sort, color: Colors.black),
            label: const Text('Sort', style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'filterBtn',
            backgroundColor: Colors.white,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const FilterOptionsSheet(),
              );
            },
            icon: const Icon(Icons.filter_list, color: Colors.black),
            label: const Text('Filter', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget buildPropertyCard(Map<String, dynamic> property) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PropertyDetailPage(
                  property: property, // Pass the map directly
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (property['images'] != null && property['images'].isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  property['images'][0],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    property['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C33D2),
                    ),
                  ),
                ),
                Text(
                  '\$${property['price'] ?? '---'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              property['location']?['address'] ?? 'Unknown Address',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconLabel(Icons.bed, '${property['bedrooms']} Beds'),
                _iconLabel(Icons.bathtub, '${property['bathrooms']} Baths'),
                _iconLabel(Icons.square_foot, '${property['areaSqFt']} sqft'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  property['agent']?['name'] ?? 'Agent',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF393939),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  property['agent']?['contact'] ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        property['status'] == 'Available'
                            ? Colors.green[50]
                            : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          property['status'] == 'Available'
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  child: Text(
                    property['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          property['status'] == 'Available'
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ...?property['tags']?.map<Widget>(
                  (tag) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.blue[50],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class SortOptionsSheet extends StatelessWidget {
  final String? currentSortType;
  final Function(String sortType) onSortSelected;

  const SortOptionsSheet({
    Key? key,
    required this.onSortSelected,
    this.currentSortType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        _buildTile(context, 'Sort by Property Id', 'property'),
        _buildTile(context, 'Sort by Price: Low - High', 'price_asc'),
        _buildTile(context, 'Sort by Price: High - Low', 'price_desc'),
        _buildTile(context, 'Sort by Area', 'area'),
      ],
    );
  }

  ListTile _buildTile(BuildContext context, String title, String type) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              currentSortType == type ? FontWeight.bold : FontWeight.normal,
          color: currentSortType == type ? Colors.blue : null,
        ),
      ),
      onTap: () {
        onSortSelected(type);
        Navigator.pop(context);
      },
    );
  }
}

class FilterOptionsSheet extends StatelessWidget {
  const FilterOptionsSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ListTile(
          title: const Text('Property: Available'),
          onTap: () {
            Navigator.pop(context);
            context.read<ListPropertyBloc>().add(
              FetchProperties(status: 'Available'),
            );
          },
        ),
        ListTile(
          title: const Text('Price: 100,000 <= 200,000'),
          onTap: () {
            Navigator.pop(context);
            context.read<ListPropertyBloc>().add(
              FetchProperties(minPrice: 100000, maxPrice: 200000),
            );
          },
        ),
        ListTile(
          title: const Text('City: Cityville'),
          onTap: () {
            Navigator.pop(context);
            context.read<ListPropertyBloc>().add(
              FetchProperties(location: 'Cityville'),
            );
          },
        ),
        ListTile(
          title: const Text('Tags: New & Furnished'),
          onTap: () {
            Navigator.pop(context);
            context.read<ListPropertyBloc>().add(
              FetchProperties(tags: ['New', 'Furnished']),
            );
          },
        ),
      ],
    );
  }
}
