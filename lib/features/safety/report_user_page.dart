import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 舉報類型枚舉
enum ReportType {
  inappropriateBehavior,
  fakeProfile,
  harassment,
  spam,
  inappropriatePhotos,
  scam,
  underage,
  violence,
  other,
}

// 舉報狀態管理
final reportFormProvider = StateNotifierProvider<ReportFormNotifier, ReportFormState>((ref) {
  return ReportFormNotifier();
});

class ReportFormState {
  final String? reportedUserId;
  final String? reportedUserName;
  final String? reportedUserPhoto;
  final ReportType? selectedType;
  final String description;
  final List<String> selectedEvidence;
  final bool isSubmitting;

  ReportFormState({
    this.reportedUserId,
    this.reportedUserName,
    this.reportedUserPhoto,
    this.selectedType,
    this.description = '',
    this.selectedEvidence = const [],
    this.isSubmitting = false,
  });

  ReportFormState copyWith({
    String? reportedUserId,
    String? reportedUserName,
    String? reportedUserPhoto,
    ReportType? selectedType,
    String? description,
    List<String>? selectedEvidence,
    bool? isSubmitting,
  }) {
    return ReportFormState(
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedUserName: reportedUserName ?? this.reportedUserName,
      reportedUserPhoto: reportedUserPhoto ?? this.reportedUserPhoto,
      selectedType: selectedType ?? this.selectedType,
      description: description ?? this.description,
      selectedEvidence: selectedEvidence ?? this.selectedEvidence,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ReportFormNotifier extends StateNotifier<ReportFormState> {
  ReportFormNotifier() : super(ReportFormState());

  void setReportedUser(String userId, String userName, String? userPhoto) {
    state = state.copyWith(
      reportedUserId: userId,
      reportedUserName: userName,
      reportedUserPhoto: userPhoto,
    );
  }

  void selectReportType(ReportType type) {
    state = state.copyWith(selectedType: type);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void addEvidence(String evidence) {
    final newEvidence = [...state.selectedEvidence, evidence];
    state = state.copyWith(selectedEvidence: newEvidence);
  }

  void removeEvidence(String evidence) {
    final newEvidence = state.selectedEvidence.where((e) => e != evidence).toList();
    state = state.copyWith(selectedEvidence: newEvidence);
  }

  Future<bool> submitReport() async {
    state = state.copyWith(isSubmitting: true);
    
    try {
      // 模擬提交舉報
      await Future.delayed(const Duration(seconds: 2));
      
      // 重置表單
      state = ReportFormState();
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

class ReportUserPage extends ConsumerStatefulWidget {
  final String? userId;
  final String? userName;
  final String? userPhoto;

  const ReportUserPage({
    super.key,
    this.userId,
    this.userName,
    this.userPhoto,
  });

  @override
  ConsumerState<ReportUserPage> createState() => _ReportUserPageState();
}

class _ReportUserPageState extends ConsumerState<ReportUserPage> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(reportFormProvider.notifier).setReportedUser(
          widget.userId!,
          widget.userName ?? '未知用戶',
          widget.userPhoto,
        );
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportFormProvider);
    final notifier = ref.read(reportFormProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('舉報用戶'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 被舉報用戶信息
              if (reportState.reportedUserId != null)
                _buildReportedUserCard(reportState),
              
              const SizedBox(height: 24),
              
              // 舉報類型選擇
              _buildReportTypeSection(reportState, notifier),
              
              const SizedBox(height: 24),
              
              // 詳細描述
              _buildDescriptionSection(reportState, notifier),
              
              const SizedBox(height: 24),
              
              // 證據上傳
              _buildEvidenceSection(reportState, notifier),
              
              const SizedBox(height: 24),
              
              // 重要提醒
              _buildImportantNotice(),
              
              const SizedBox(height: 32),
              
              // 提交按鈕
              _buildSubmitButton(reportState, notifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportedUserCard(ReportFormState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: state.reportedUserPhoto != null
                ? NetworkImage(state.reportedUserPhoto!)
                : null,
            child: state.reportedUserPhoto == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '舉報用戶',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.reportedUserName ?? '未知用戶',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '舉報',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeSection(ReportFormState state, ReportFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '舉報原因',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '請選擇最符合的舉報原因',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        
        // 舉報類型選項
        ...ReportType.values.map((type) => _buildReportTypeOption(
          type,
          state.selectedType == type,
          () => notifier.selectReportType(type),
        )),
      ],
    );
  }

  Widget _buildReportTypeOption(ReportType type, bool isSelected, VoidCallback onTap) {
    final typeInfo = _getReportTypeInfo(type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeInfo['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  typeInfo['icon'],
                  color: typeInfo['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeInfo['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFFE91E63) : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      typeInfo['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFE91E63),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ReportFormState state, ReportFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '詳細描述',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '請詳細描述發生的情況，這將幫助我們更好地處理你的舉報',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: '請描述具體發生了什麼...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE91E63)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: notifier.updateDescription,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '請提供詳細描述';
            }
            if (value.trim().length < 10) {
              return '描述至少需要10個字符';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEvidenceSection(ReportFormState state, ReportFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '證據上傳（可選）',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '如果你有相關的截圖或其他證據，可以上傳以支持你的舉報',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        
        // 上傳按鈕
        InkWell(
          onTap: () => _showEvidenceUploadDialog(notifier),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  '點擊上傳證據',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '支援圖片、截圖等格式',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 已上傳的證據
        if (state.selectedEvidence.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.selectedEvidence.map((evidence) => 
              _buildEvidenceChip(evidence, () => notifier.removeEvidence(evidence))
            ).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEvidenceChip(String evidence, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image,
            size: 16,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            evidence,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.amber.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '重要提醒',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• 我們會認真審核每一個舉報\n'
            '• 虛假舉報可能導致你的帳戶受到限制\n'
            '• 舉報處理通常需要1-3個工作日\n'
            '• 我們會保護你的隱私，不會透露舉報者身份',
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ReportFormState state, ReportFormNotifier notifier) {
    final canSubmit = state.selectedType != null && 
                     state.description.trim().length >= 10 && 
                     !state.isSubmitting;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _submitReport(notifier) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: state.isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '提交舉報',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Map<String, dynamic> _getReportTypeInfo(ReportType type) {
    switch (type) {
      case ReportType.inappropriateBehavior:
        return {
          'title': '不當行為',
          'description': '騷擾、威脅或其他不當行為',
          'icon': Icons.warning,
          'color': Colors.red,
        };
      case ReportType.fakeProfile:
        return {
          'title': '虛假檔案',
          'description': '使用他人照片或虛假信息',
          'icon': Icons.person_off,
          'color': Colors.orange,
        };
      case ReportType.harassment:
        return {
          'title': '騷擾',
          'description': '持續的不受歡迎的聯繫',
          'icon': Icons.block,
          'color': Colors.red,
        };
      case ReportType.spam:
        return {
          'title': '垃圾信息',
          'description': '發送廣告或垃圾消息',
          'icon': Icons.mark_email_unread,
          'color': Colors.purple,
        };
      case ReportType.inappropriatePhotos:
        return {
          'title': '不當照片',
          'description': '裸體、色情或其他不當圖片',
          'icon': Icons.photo_camera,
          'color': Colors.red,
        };
      case ReportType.scam:
        return {
          'title': '詐騙',
          'description': '金錢詐騙或其他欺詐行為',
          'icon': Icons.money_off,
          'color': Colors.red,
        };
      case ReportType.underage:
        return {
          'title': '未成年',
          'description': '用戶可能未滿18歲',
          'icon': Icons.child_care,
          'color': Colors.orange,
        };
      case ReportType.violence:
        return {
          'title': '暴力威脅',
          'description': '威脅暴力或自殘',
          'icon': Icons.dangerous,
          'color': Colors.red,
        };
      case ReportType.other:
        return {
          'title': '其他',
          'description': '其他不符合社區準則的行為',
          'icon': Icons.more_horiz,
          'color': Colors.grey,
        };
    }
  }

  void _showEvidenceUploadDialog(ReportFormNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('上傳證據'),
        content: const Text('在實際應用中，這裡會打開文件選擇器來上傳圖片或其他證據文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 模擬添加證據
              notifier.addEvidence('screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg');
            },
            child: const Text('模擬上傳'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(ReportFormNotifier notifier) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await notifier.submitReport();
    
    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('舉報已提交'),
          content: const Text(
            '感謝你的舉報。我們會在1-3個工作日內審核並採取適當行動。'
            '\n\n我們會保護你的隱私，不會透露舉報者身份。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 關閉對話框
                Navigator.pop(context); // 返回上一頁
              },
              child: const Text('確定'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('提交失敗，請稍後再試'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 