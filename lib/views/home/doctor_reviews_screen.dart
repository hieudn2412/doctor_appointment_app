import 'package:doctor_appointment_app/views/appointment/data/appointment_booking_store.dart';
import 'package:doctor_appointment_app/views/appointment/models/doctor_review.dart';
import 'package:flutter/material.dart';

class DoctorReviewsScreen extends StatefulWidget {
  const DoctorReviewsScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  final String doctorId;
  final String doctorName;

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  List<DoctorReview> _reviews = [];
  DoctorReview? _myReview;
  bool _isLoading = true;

  // Review mẫu cố định
  static const _staticReviews = <Map<String, dynamic>>[
    {
      'name': 'Phạm Thị D',
      'rating': 5,
      'text': 'Bác sĩ A là một chuyên gia thực thụ, luôn thật sự quan tâm đến bệnh nhân.',
    },
    {
      'name': 'Nguyễn Văn B',
      'rating': 5,
      'text': 'Bác sĩ A là một chuyên gia thực thụ, luôn thật sự quan tâm đến bệnh nhân.',
    },
    {
      'name': 'Trần Thị C',
      'rating': 4,
      'text': 'Bác sĩ A là một chuyên gia thực thụ, luôn thật sự quan tâm đến bệnh nhân.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews =
        await AppointmentBookingStore.instance.getReviewsForDoctor(widget.doctorId);
    final myReview =
        await AppointmentBookingStore.instance.getMyReviewForDoctor(widget.doctorId);

    if (!mounted) return;
    setState(() {
      _reviews = reviews;
      _myReview = myReview;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final otherReviews = _myReview == null
        ? _reviews
        : _reviews.where((r) => r.id != _myReview!.id).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF374151)),
                  ),
                  const Expanded(
                    child: Text(
                      'Nhận xét',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A37),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: ListView(
                    children: [
                      for (final r in _staticReviews) ...[
                        _ReviewItem(
                          customerName: r['name'] as String,
                          rating: r['rating'] as int,
                          reviewText: r['text'] as String,
                          isUserReview: false,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_myReview != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Nhận xét của bạn',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Color(0xFFD1D5DB))),
                            ],
                          ),
                        ),
                        _ReviewItem(
                          customerName: _myReview!.userName,
                          rating: _myReview!.rating,
                          reviewText: _myReview!.content,
                          isUserReview: true,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (otherReviews.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Nhận xét người dùng',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        for (final review in otherReviews) ...[
                          _ReviewItem(
                            customerName: review.userName,
                            rating: review.rating,
                            reviewText: review.content,
                            isUserReview: false,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.customerName,
    required this.rating,
    required this.reviewText,
    required this.isUserReview,
  });

  final String customerName;
  final int rating;
  final String reviewText;
  final bool isUserReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isUserReview
          ? BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(41),
                child: SizedBox(
                  width: 57,
                  height: 57,
                  child: isUserReview
                      ? Container(
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(Icons.person, size: 28, color: Color(0xFF6B7280)),
                        )
                      : Image.asset(
                          'assets/images/customer.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const ColoredBox(
                            color: Color(0xFFE5E7EB),
                            child: Icon(Icons.person, size: 28, color: Color(0xFF6B7280)),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151),
                          ),
                        ),
                        if (isUserReview) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2A3A),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Bạn',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(width: 4),
                        ...List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 12,
                            color: i < rating
                                ? const Color(0xFFFEB052)
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reviewText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
