import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/providers/destination_provider.dart';
import '../widgets/featured_destination_card.dart';

class FeaturedDestinationsSection extends StatelessWidget {
  const FeaturedDestinationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Destinations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to see all featured destinations
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<DestinationProvider>(
          builder: (context, destinationProvider, child) {
            if (destinationProvider.isLoading) {
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 280,
                      margin: EdgeInsets.only(
                        right: index < 2 ? 16 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  },
                ),
              );
            }
            
            final featuredDestinations = destinationProvider.featuredDestinations;
            
            if (featuredDestinations.isEmpty) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No featured destinations available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredDestinations.length,
                itemBuilder: (context, index) {
                  final destination = featuredDestinations[index];
                  return Container(
                    width: 280,
                    margin: EdgeInsets.only(
                      right: index < featuredDestinations.length - 1 ? 16 : 0,
                    ),
                    child: FeaturedDestinationCard(
                      destination: destination,
                      onTap: () {
                        // Navigate to destination details
                      },
                    ).animate().slideX(
                      delay: Duration(milliseconds: index * 100),
                      duration: 600.ms,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
