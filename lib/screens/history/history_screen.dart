import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../features/consultation/consultation_cubit.dart';
import '../../../features/consultation/consultation_state.dart';
import '../../../models/consultation_model.dart';
import '../../../core/constants/consultation_status.dart';
import 'widgets/filter_dropdown.dart';
import '../widgets/screen_header.dart';
import '../widgets/app_bar_logo_title.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterVet = 'all';
  String _filterType = 'all';
  String _sortBy = 'date-desc';
  bool _isListView = true;

  @override
  void initState() {
    super.initState();
    // Load consultations when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationCubit>().loadConsultations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterVet = 'all';
      _filterType = 'all';
      _sortBy = 'date-desc';
    });
    context.read<ConsultationCubit>().setSearchTerm('');
    context.read<ConsultationCubit>().setFilterStatus(null);
  }

  void _handleViewConsultation(
    String consultationId,
    ConsultationModel consultation,
  ) {
    // Navigate to SOAP note view for completed consultations
    AppRouter.pushNamed(
      context,
      AppRoutes.soapNote,
      arguments: SOAPNoteArguments(consultationId: consultationId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppBarLogoTitle(),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<ConsultationCubit, ConsultationState>(
        builder: (context, state) {
          // Get completed consultations
          final completedConsultations = state.completedConsultations;
          final activeConsultations = state.activeConsultations;

          // Get unique veterinarians and types for filters
          final veterinarians =
              completedConsultations
                  .map((c) => c.veterinarianName ?? 'Unknown')
                  .toSet()
                  .toList()
                ..sort();

          final consultationTypes =
              completedConsultations
                  .map((c) => c.symptoms ?? 'General Checkup')
                  .toSet()
                  .toList()
                ..sort();

          // Filter and sort consultations
          final filteredConsultations = _filterAndSortConsultations(
            completedConsultations,
            _searchController.text,
            _filterVet,
            _filterType,
            _sortBy,
          );

          if (state.isLoadingConsultations && completedConsultations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.hasError && completedConsultations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading consultation history',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConsultationCubit>().loadConsultations(
                        refresh: true,
                      );
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Search and Filters Card
                ScreenHeader(
                  title: 'Consultation History',
                  subtitle: '${completedConsultations.length} of ${completedConsultations.length + activeConsultations.length} Consultations',
                ),
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header with view mode toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Search & Filter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontFamily: "Fraunces",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildViewModeButton(
                                'List',
                                Icons.view_list,
                                _isListView,
                              ),
                              const SizedBox(width: 8),
                              _buildViewModeButton(
                                'Grid',
                                Icons.grid_view,
                                !_isListView,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search and filter inputs
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          // Search
                          SizedBox(
                            width: MediaQuery.of(context).size.width > 600
                                ? 300
                                : double.infinity,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search consultations...',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(Icons.search, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                context.read<ConsultationCubit>().setSearchTerm(
                                  value,
                                );
                                setState(() {});
                              },
                            ),
                          ),
                          // Veterinarian, Type, Sort by in one Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: FilterDropdown(
                                  value: _filterVet,
                                  labelText: 'Veterinarian',
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'all',
                                      child: Text(
                                        'All',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    ...veterinarians.map(
                                      (vet) => DropdownMenuItem(
                                        value: vet,
                                        child: Text(
                                          vet,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _filterVet = value ?? 'all';
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilterDropdown(
                                  value: _filterType,
                                  labelText: 'Type',
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'all',
                                      child: Text(
                                        'All',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    ...consultationTypes.map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(
                                          type,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _filterType = value ?? 'all';
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilterDropdown(
                                  value: _sortBy,
                                  labelText: 'Sort by',
                                  contentPadding: const EdgeInsets.only(
                                    left: 8,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'date-desc',
                                      child: Text(
                                        'Newest',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'date-asc',
                                      child: Text(
                                        'Oldest',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'patient-asc',
                                      child: Text(
                                        'A-Z',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'patient-desc',
                                      child: Text(
                                        'Z-A',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _sortBy = value ?? 'date-desc';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 8,
                              children: [
                                Icon(Icons.description_outlined, size: 20),
                                Text(
                                  'Completed Consultations',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.black,
                                    fontFamily: "Fraunces",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${filteredConsultations.length} Consultations',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Results
                Expanded(
                  child: filteredConsultations.isEmpty
                      ? _buildEmptyState()
                      : Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isListView
                                ? AppColors.white
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _isListView
                              ? _buildListView(filteredConsultations)
                              : _buildGridView(filteredConsultations),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewModeButton(String label, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _isListView = label == 'List';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search,
                        size: 32,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No consultations found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: "Fraunces",
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search criteria or filters.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        'Clear Filters',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<ConsultationModel> consultations) {
    return ListView.builder(
      itemCount: consultations.length,
      itemBuilder: (context, index) {
        final consultation = consultations[index];
        return Column(
          children: [
            _buildConsultationCard(consultation, isList: true),
            if (index != consultations.length - 1)
              Divider(color: AppColors.border),
          ],
        );
      },
    );
  }

  Widget _buildGridView(List<ConsultationModel> consultations) {
    return ListView.builder(
      itemCount: consultations.length,
      itemBuilder: (context, index) {
        final consultation = consultations[index];
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: _buildConsultationCard(consultation, isList: false),
            ),
            if (index != consultations.length - 1) SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildConsultationCard(
    ConsultationModel consultation, {
    required bool isList,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('MMM d, h:mm a');

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleViewConsultation(consultation.id, consultation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(
            isList ? 16 : 12,
          ), // Reduced padding in grid mode
          child: isList
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Text(
                                    consultation.patientName ??
                                        'Unknown Patient',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  _buildStatusBadge(consultation.status),
                                ],
                              ),

                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                    side: BorderSide(color: AppColors.primary),
                                  ),
                                ),
                                onPressed: () => _handleViewConsultation(
                                  consultation.id,
                                  consultation,
                                ),
                                icon: const Icon(Icons.visibility_outlined),
                                iconAlignment: IconAlignment.start,
                                label: const Text(
                                  'View',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.person_outline,
                            consultation.veterinarianName ??
                                'Unknown Veterinarian',
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 12,
                            children: [
                              _buildInfoRow(
                                Icons.calendar_today,
                                dateFormat.format(consultation.startTime),
                              ),

                              _buildInfoRow(
                                Icons.description_outlined,
                                consultation.symptoms ?? 'General Checkup',
                              ),
                            ],
                          ),
                          if (consultation.endTime != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.access_time,
                              'Completed: ${timeFormat.format(consultation.endTime!)}',
                              fontSize: 12,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min, // Use min size to prevent overflow
                  children: [
                    // Patient name and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            consultation.patientName ?? 'Unknown Patient',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(consultation.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Date
                    _buildInfoRow(
                      Icons.calendar_today,
                      dateFormat.format(consultation.startTime),
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    // Veterinarian
                    _buildInfoRow(
                      Icons.person_outline,
                      consultation.veterinarianName ?? 'Unknown Veterinarian',
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    // Type/Symptoms
                    _buildInfoRow(
                      Icons.description_outlined,
                      consultation.symptoms ?? 'General Checkup',
                      fontSize: 13,
                    ),
                    // Spacer to push button to bottom
                    const SizedBox(height: 8),
                    // View button - use Flexible to prevent overflow
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleViewConsultation(
                            consultation.id,
                            consultation,
                          ),
                          icon: const Icon(Icons.visibility_outlined, size: 16),
                          label: const Text(
                            'View Details',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            minimumSize: const Size(0, 36),
                            side: BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {double fontSize = 12}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),

        Text(
          text,
          style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ConsultationStatus status) {
    Color badgeColor;
    String label;

    switch (status) {
      case ConsultationStatus.complete:
      case ConsultationStatus.finalComplete:
        badgeColor = AppColors.success;
        label = 'Completed';
        break;
      default:
        badgeColor = AppColors.primary;
        label = status.label;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  List<ConsultationModel> _filterAndSortConsultations(
    List<ConsultationModel> consultations,
    String searchTerm,
    String filterVet,
    String filterType,
    String sortBy,
  ) {
    var filtered = consultations.where((consultation) {
      // Search filter
      final matchesSearch =
          searchTerm.isEmpty ||
          (consultation.patientName?.toLowerCase().contains(
                searchTerm.toLowerCase(),
              ) ??
              false) ||
          (consultation.veterinarianName?.toLowerCase().contains(
                searchTerm.toLowerCase(),
              ) ??
              false) ||
          (consultation.symptoms?.toLowerCase().contains(
                searchTerm.toLowerCase(),
              ) ??
              false);

      // Veterinarian filter
      final matchesVet =
          filterVet == 'all' || (consultation.veterinarianName == filterVet);

      // Type filter
      final matchesType =
          filterType == 'all' || (consultation.symptoms == filterType);

      return matchesSearch && matchesVet && matchesType;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      switch (sortBy) {
        case 'date-desc':
          return b.startTime.compareTo(a.startTime);
        case 'date-asc':
          return a.startTime.compareTo(b.startTime);
        case 'patient-asc':
          return (a.patientName ?? '').compareTo(b.patientName ?? '');
        case 'patient-desc':
          return (b.patientName ?? '').compareTo(a.patientName ?? '');
        default:
          return 0;
      }
    });

    return filtered;
  }
}
