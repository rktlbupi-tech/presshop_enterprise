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
import '../bloc/documents_bloc.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DocumentsBloc>()..add(const FetchDocuments()),
      child: const _DocumentsView(),
    );
  }
}

class _DocumentsView extends StatelessWidget {
  const _DocumentsView();

  Color _typeColor(String type) => switch (type.toLowerCase()) {
        'pdf' => AppColors.error,
        'doc' || 'docx' => AppColors.info,
        'xls' || 'xlsx' => AppColors.success,
        _ => AppColors.accent,
      };

  IconData _typeIcon(String type) => switch (type.toLowerCase()) {
        'pdf' => Icons.picture_as_pdf_outlined,
        'doc' || 'docx' => Icons.description_outlined,
        'xls' || 'xlsx' => Icons.table_chart_outlined,
        _ => Icons.insert_drive_file_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'My Documents',
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.textOnPrimary, size: 22.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<DocumentsBloc, DocumentsState>(
        builder: (context, state) {
          if (state is DocumentsLoading) return const LoadingWidget();
          if (state is DocumentsError) {
            return EmptyState(
              icon: Icons.error_outline, title: state.message,
              buttonLabel: 'Retry',
              onButtonTap: () => context.read<DocumentsBloc>().add(const FetchDocuments()),
            );
          }
          if (state is DocumentsLoaded) {
            if (state.documents.isEmpty) {
              return const EmptyState(
                icon: Icons.folder_open_outlined,
                title: 'No documents',
                subtitle: 'Your documents will appear here.',
              );
            }
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => context.read<DocumentsBloc>().add(const FetchDocuments()),
              child: ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: state.documents.length,
                separatorBuilder: (ctx, i) => SizedBox(height: 10.h),
                itemBuilder: (_, i) {
                  final doc = state.documents[i];
                  final rawType = doc.type;
                  final color = _typeColor(rawType);
                  return Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Row(children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(_typeIcon(rawType), color: color, size: 22.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(doc.name, style: AppTextStyles.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 3.h),
                        Row(children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4.r)),
                            child: Text(rawType.toUpperCase(), style: AppTextStyles.overline.copyWith(color: color)),
                          ),
                          if (doc.size != null) ...[
                            SizedBox(width: 8.w),
                            Text(doc.size!, style: AppTextStyles.caption),
                          ],
                          if (doc.uploadedAt != null) ...[
                            SizedBox(width: 8.w),
                            Text('· ${DateFormat('dd MMM yyyy').format(doc.uploadedAt!)}', style: AppTextStyles.caption),
                          ],
                        ]),
                      ])),
                      IconButton(
                        icon: Icon(Icons.download_outlined, color: AppColors.textSecondary, size: 20.sp),
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading ${doc.name}...'),
                              backgroundColor: AppColors.primary, duration: const Duration(seconds: 2)),
                        ),
                      ),
                    ]),
                  );
                },
              ),
            );
          }
          return const EmptyState(icon: Icons.folder_open_outlined, title: 'No documents');
        },
      ),
    );
  }
}
