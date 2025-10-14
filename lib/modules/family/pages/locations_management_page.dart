import 'package:merryway/modules/core/theme/redesign_tokens.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';

class LocationsManagementPage extends StatefulWidget {
  final String householdId;

  const LocationsManagementPage({
    super.key,
    required this.householdId,
  });

  @override
  State<LocationsManagementPage> createState() => _LocationsManagementPageState();
}

class _LocationsManagementPageState extends State<LocationsManagementPage> {
  List<Location> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('locations')
          .select()
          .eq('household_id', widget.householdId)
          .order('name', ascending: true);

      _locations = (response as List).map((json) => Location.fromJson(json)).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching locations: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showLocationDialog({Location? locationToEdit}) async {
    final nameController = TextEditingController(text: locationToEdit?.name);
    final addressController = TextEditingController(text: locationToEdit?.address);
    final notesController = TextEditingController(text: locationToEdit?.notes);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locationToEdit == null ? 'Add Location' : 'Edit Location'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g., Home, School, Work',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  hintText: 'Full address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g., Use side entrance, parking info',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  addressController.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'address': addressController.text.trim(),
                'notes': notesController.text.trim(),
              });
            },
            child: Text(locationToEdit == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final supabase = Supabase.instance.client;
        if (locationToEdit == null) {
          await supabase.from('locations').insert({
            'household_id': widget.householdId,
            'name': result['name'],
            'address': result['address'],
            'notes': result['notes'].isNotEmpty ? result['notes'] : null,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${result['name']} added!')),
            );
          }
        } else {
          await supabase.from('locations').update({
            'name': result['name'],
            'address': result['address'],
            'notes': result['notes'].isNotEmpty ? result['notes'] : null,
          }).eq('id', locationToEdit.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${result['name']} updated!')),
            );
          }
        }
        _fetchLocations(); // Refresh list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving location: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteLocation(Location location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete "${location.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: RedesignTokens.dangerColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final supabase = Supabase.instance.client;
        await supabase.from('locations').delete().eq('id', location.id!);
        _fetchLocations(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${location.name} deleted!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting location: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MerryWayTheme.softBg,
      appBar: AppBar(
        title: const Text('Saved Locations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: RedesignTokens.ink),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: RedesignTokens.ink),
            onPressed: _showLocationDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _locations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 64, color: RedesignTokens.slate),
                      const SizedBox(height: 16),
                      Text(
                        'No Locations Yet!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: RedesignTokens.ink,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Save places like "Home", "School", or "Grandma\'s House" to reference in prompts',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: RedesignTokens.slate,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showLocationDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Location'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: RedesignTokens.primary,
                          child: Icon(
                            _getLocationIcon(location.name),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          location.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(location.address),
                            if (location.notes != null && location.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  location.notes!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: RedesignTokens.slate,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: RedesignTokens.primary),
                              onPressed: () => _showLocationDialog(locationToEdit: location),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: RedesignTokens.dangerColor),
                              onPressed: () => _deleteLocation(location),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getLocationIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('home') || nameLower.contains('house')) {
      return Icons.home;
    } else if (nameLower.contains('school')) {
      return Icons.school;
    } else if (nameLower.contains('work') || nameLower.contains('office')) {
      return Icons.work;
    } else if (nameLower.contains('park')) {
      return Icons.park;
    } else if (nameLower.contains('store') || nameLower.contains('shop')) {
      return Icons.shopping_bag;
    }
    return Icons.location_on;
  }
}

