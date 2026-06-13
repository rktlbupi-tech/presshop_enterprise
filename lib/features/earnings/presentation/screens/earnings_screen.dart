import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../presentation/widgets/app_app_bar.dart';
import '../../../../presentation/widgets/empty_state.dart';
import '../../../../presentation/widgets/loading_widget.dart';
import '../bloc/earnings_bloc.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EarningsBloc>()..add(const FetchEarnings()),
      child: const _EarningsView(),
    );
  }
}

class _EarningsView extends StatelessWidget {
  const _EarningsView();

  String _fmt(num v) => '₹${NumberFormat('#,##,###').format(v.toInt())}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: 'Earnings'),
      body: BlocBuilder<EarningsBloc, EarningsState>(
        builder: (context, state) {
          if (state is EarningsLoading) return const LoadingWidget();
          if (state is EarningsError) {
            return EmptyState(
              icon: Icons.error_outline, title: state.message,
              buttonLabel: 'Retry',
              onButtonTap: () => context.read<EarningsBloc>().add(const FetchEarnings()),
            );
          }
          if (state is EarningsLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<EarningsBloc>().add(const FetchEarnings()),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _YTDBanner(ytd: state.ytd, fmt: _fmt)),
                  if (state.earnings.isEmpty)
                    const SliverFillRemaining(
                      child: EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'No earnings records'),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.all(16.r),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _MonthCard(earning: state.earnings[i], fmt: _fmt),
                          childCount: state.earnings.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          return const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'No data');
        },
      ),
    );
  }
}

class _YTDBanner extends StatelessWidget {
  final double ytd;
  final String Function(num) fmt;
  const _YTDBanner({required this.ytd, required this.fmt});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Year to Date Earnings', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
          SizedBox(height: 4.h),
          Text(fmt(ytd), style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary)),
        ])),
        Icon(Icons.trending_up, size: 40.sp, color: Colors.white38),
      ]),
    );
  }
}

class _MonthCard extends StatefulWidget {
  final dynamic earning;
  final String Function(num) fmt;
  const _MonthCard({required this.earning, required this.fmt});
  @override State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.earning;
    final net = (e.netSalary as num);
    final status = (e.paymentStatus as String);
    final statusColor = status.toLowerCase() == 'paid' ? AppColors.success : AppColors.warning;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${e.month} ${e.year}', style: AppTextStyles.labelLarge),
                SizedBox(height: 2.h),
                Text('Net: ${widget.fmt(net)}', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(widget.fmt(net), style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(status, style: AppTextStyles.labelSmall.copyWith(color: statusColor)),
                ),
              ]),
              SizedBox(width: 8.w),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
            ]),
          ),
        ),
        if (_expanded) ...[
          Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(children: [
              _Row('Basic Salary', widget.fmt(e.basicSalary as num)),
              if ((e.hra as num) > 0) _Row('HRA', widget.fmt(e.hra as num)),
              if ((e.allowances as num) > 0) _Row('Allowances', widget.fmt(e.allowances as num)),
              if ((e.deductions as num) > 0)
                _Row('Deductions', '-${widget.fmt(e.deductions as num)}', negative: true),
              SizedBox(height: 8.h),
              Divider(color: AppColors.divider),
              SizedBox(height: 8.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Net Salary', style: AppTextStyles.labelLarge),
                Text(widget.fmt(net), style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  final String l, v; final bool negative;
  const _Row(this.l, this.v, {this.negative = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: AppTextStyles.bodySmall),
      Text(v, style: AppTextStyles.bodySmall.copyWith(color: negative ? AppColors.error : AppColors.textPrimary)),
    ]),
  );
}
