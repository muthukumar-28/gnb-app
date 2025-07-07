// ignore_for_file: use_build_context_synchronously

import 'package:Gnb_Property/features/properties/properties_bloc.dart';
import 'package:Gnb_Property/features/properties/property_detail.dart';
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
  String? _currentFilterType;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _sortedProperties = List<Map<String, dynamic>>.from(widget.properties);
  }

  void handleSort(String sortType) {
    setState(() {
      _currentSortType = sortType;
      _applyFiltersAndSorting();
    });
  }

  void _applyFiltersAndSorting() {
    final blocState = context.read<ListPropertyBloc>().state;
    if (blocState is ListPropertyLoaded) {
      _sortedProperties = List<Map<String, dynamic>>.from(blocState.properties);

      if (_currentSortType != null) {
        switch (_currentSortType) {
          case 'property':
            _sortedProperties.sort(
              (a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0),
            );
            break;
          case 'price_asc':
            _sortedProperties.sort(
              (a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0),
            );
            break;
          case 'price_desc':
            _sortedProperties.sort(
              (a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0),
            );
            break;
          case 'area':
            _sortedProperties.sort(
              (a, b) => (b['areaSqFt'] ?? 0).compareTo(a['areaSqFt'] ?? 0),
            );
            break;
        }
      }

      if (_searchText.isNotEmpty) {
        _sortedProperties =
            _sortedProperties.where((property) {
              final title = (property['title'] ?? '').toString().toLowerCase();
              return title.contains(_searchText);
            }).toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SafeArea(
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
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountScreen(),
                              ),
                            ),
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
                        _applyFiltersAndSorting();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<ListPropertyBloc, ListPropertyState>(
                builder: (context, state) {
                  if (state is ListPropertyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ListPropertyError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is ListPropertyLoaded) {
                    _applyFiltersAndSorting();
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Properties',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                'Total: ${_sortedProperties.length} Properties',
                                style: const TextStyle(fontSize: 18),
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
                                      itemBuilder:
                                          (context, index) => buildPropertyCard(
                                            _sortedProperties[index],
                                          ),
                                    )
                                    : const Center(
                                      child: Text('No Properties Found'),
                                    ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.sort),
                label: const Text('SORT'),
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
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.filter_list),
                label: const Text('FILTER'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => FilterOptionsSheet(
                          currentFilterType: _currentFilterType,
                          onFilterSelected: (type) {
                            setState(() => _currentFilterType = type);
                          },
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPropertyCard(Map<String, dynamic> property) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailPage(property: property),
            ),
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
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
    super.key,
    required this.onSortSelected,
    this.currentSortType,
  });

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
  final String? currentFilterType;
  final Function(String filterType) onFilterSelected;

  const FilterOptionsSheet({
    super.key,
    this.currentFilterType,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ListPropertyBloc>().add(FetchProperties());
                  onFilterSelected('');
                },
                child: const Text('Clear Filter'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListTile(
          title: Text(
            'Property: Available',
            style: TextStyle(
              color:
                  currentFilterType == 'Available' ? Colors.blue : Colors.black,
              fontWeight:
                  currentFilterType == 'Available'
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            onFilterSelected('Available');
            context.read<ListPropertyBloc>().add(
              FetchProperties(status: 'Available'),
            );
          },
        ),
        ListTile(
          title: Text(
            'Price: 100,000 <= 200,000',
            style: TextStyle(
              color:
                  currentFilterType == 'price_range'
                      ? Colors.blue
                      : Colors.black,
              fontWeight:
                  currentFilterType == 'price_range'
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            onFilterSelected('price_range');
            context.read<ListPropertyBloc>().add(
              FetchProperties(minPrice: 100000, maxPrice: 200000),
            );
          },
        ),
        ListTile(
          title: Text(
            'City: Cityville',
            style: TextStyle(
              color: currentFilterType == 'city' ? Colors.blue : Colors.black,
              fontWeight:
                  currentFilterType == 'city'
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            onFilterSelected('city');
            context.read<ListPropertyBloc>().add(
              FetchProperties(location: 'Cityville'),
            );
          },
        ),
        ListTile(
          title: Text(
            'Tags: New & Furnished',
            style: TextStyle(
              color: currentFilterType == 'tags' ? Colors.blue : Colors.black,
              fontWeight:
                  currentFilterType == 'tags'
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            onFilterSelected('tags');
            context.read<ListPropertyBloc>().add(
              FetchProperties(tags: ['New', 'Furnished']),
            );
          },
        ),
      ],
    );
  }
}
