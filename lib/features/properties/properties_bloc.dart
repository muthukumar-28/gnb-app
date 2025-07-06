import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';

/// BLoC Definition
class ListPropertyBloc extends Bloc<ListPropertyEvent, ListPropertyState> {
  ListPropertyBloc() : super(ListPropertyInitial()) {
    on<FetchProperties>(_onFetchProperties);
  }

  /// Fetch Properties
  Future<void> _onFetchProperties(
    FetchProperties event,
    Emitter<ListPropertyState> emit,
  ) async {
    emit(ListPropertyLoading());

    try {
      // Build query string manually
      final query = <String>[];

      query.add('page=${event.page}');
      query.add('page_size=${event.pageSize}');

      if (event.minPrice != null) query.add('min_price=${event.minPrice}');
      if (event.maxPrice != null) query.add('max_price=${event.maxPrice}');
      if (event.location != null && event.location!.isNotEmpty) {
        query.add('location=${Uri.encodeComponent(event.location!)}');
      }
      if (event.status != null && event.status!.isNotEmpty) {
        query.add('status=${Uri.encodeComponent(event.status!)}');
      }
      if (event.tags != null && event.tags!.isNotEmpty) {
        for (final tag in event.tags!) {
          query.add('tags=${Uri.encodeComponent(tag)}');
        }
      }

      final uri = Uri.parse('${AppConstants.properties}?${query.join('&')}');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['properties'] is List) {
          emit(ListPropertyLoaded(data['properties']));
        } else {
          emit(
            ListPropertyError(
              'Invalid response format or no properties found.',
            ),
          );
        }
      } else {
        emit(
          ListPropertyError(
            'Failed to fetch properties. Status: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      emit(ListPropertyError('Unexpected error: ${e.toString()}'));
    }
  }
}

abstract class ListPropertyEvent {}

class FetchProperties extends ListPropertyEvent {
  final int page;
  final int pageSize;
  final int? minPrice;
  final int? maxPrice;
  final String? location;
  final List<String>? tags;
  final String? status;

  FetchProperties({
    this.page = 1,
    this.pageSize = 20,
    this.minPrice,
    this.maxPrice,
    this.location,
    this.tags,
    this.status,
  });
}

abstract class ListPropertyState {}

class ListPropertyInitial extends ListPropertyState {}

class ListPropertyLoading extends ListPropertyState {}

class ListPropertyLoaded extends ListPropertyState {
  final List properties;
  ListPropertyLoaded(this.properties);
}

class ListPropertyError extends ListPropertyState {
  final String message;
  ListPropertyError(this.message);
}
