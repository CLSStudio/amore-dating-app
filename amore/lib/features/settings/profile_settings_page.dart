import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/user_model.dart';

class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _occupationController = TextEditingController();
  final _educationController = TextEditingController();
  final _locationController = TextEditingController();

  List<String> _selectedInterests = [];
  List<String> _photos = [];
  String? _selectedGender;
  DateTime? _selectedBirthDate;

  final List<String> _availableInterests = [
    '旅行', '美食', '運動', '音樂', '電影', '讀書', '攝影', '購物',
    '烹飪', '藝術', '遊戲', '瑜伽', '健身', '咖啡', '紅酒', '寵物',
    '戶外活動', '舞蹈', '登山', '游泳', '唱歌', '繪畫', '寫作', '科技'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // TODO: 載入用戶資料
    _nameController.text = 'Sarah Chen';
    _bioController.text = '熱愛生活，喜歡探索新事物的香港女生 ✨';
    _occupationController.text = '市場策劃';
    _educationController.text = '香港大學';
    _locationController.text = '香港島';
    _selectedGender = '女性';
    _selectedBirthDate = DateTime(1995, 3, 15);
    _selectedInterests = ['旅行', '美食', '攝影', '瑜伽'];
    _photos = [
      'https://example.com/photo1.jpg',
      'https://example.com/photo2.jpg',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '個人檔案設定',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE91E63),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              '保存',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 照片管理區塊
              _buildSectionCard(
                title: '照片管理',
                icon: Icons.photo_camera,
                child: _buildPhotoManagement(),
              ),

              const SizedBox(height: 16),

              // 基本信息區塊
              _buildSectionCard(
                title: '基本信息',
                icon: Icons.person,
                child: _buildBasicInfo(),
              ),

              const SizedBox(height: 16),

              // 個人介紹區塊
              _buildSectionCard(
                title: '個人介紹',
                icon: Icons.description,
                child: _buildBioSection(),
              ),

              const SizedBox(height: 16),

              // 興趣愛好區塊
              _buildSectionCard(
                title: '興趣愛好',
                icon: Icons.favorite,
                child: _buildInterestsSection(),
              ),

              const SizedBox(height: 16),

              // 工作與教育區塊
              _buildSectionCard(
                title: '工作與教育',
                icon: Icons.work,
                child: _buildWorkEducationSection(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFE91E63), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最多可上傳 6 張照片，建議包含清晰的面部照片',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) {
              if (index < _photos.length) {
                return _buildPhotoCard(_photos[index], index);
              } else {
                return _buildAddPhotoCard();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String photoUrl, int index) {
    return Container(
      width: 90,
      height: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
                 image: DecorationImage(
           image: const NetworkImage('https://via.placeholder.com/90x120'),
           fit: BoxFit.cover,
         ),
      ),
      child: Stack(
        children: [
          if (index == 0)
            const Positioned(
              bottom: 6,
              left: 6,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFE91E63),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Text(
                  '主要',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _deletePhoto(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        width: 90,
        height: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: Color(0xFF718096),
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              '添加照片',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: '姓名',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入姓名';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: '性別',
          icon: Icons.wc,
          value: _selectedGender,
          items: ['男性', '女性', '其他'],
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: '生日',
          icon: Icons.cake,
          value: _selectedBirthDate,
          onTap: _selectBirthDate,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _locationController,
          label: '所在地',
          icon: Icons.location_on,
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _bioController,
          label: '個人介紹',
          icon: Icons.description,
          maxLines: 4,
          hint: '寫一些關於自己的有趣信息...',
        ),
        const SizedBox(height: 8),
        Text(
          '${_bioController.text.length}/300',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '選擇最多 8 個興趣',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () => _toggleInterest(interest),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4A5568),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWorkEducationSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _occupationController,
          label: '職業',
          icon: Icons.work,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _educationController,
          label: '教育背景',
          icon: Icons.school,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFE91E63)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE91E63)),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFE91E63)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE91E63)),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE91E63)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value != null 
                        ? '${value.year}年${value.month}月${value.day}日'
                        : '選擇生日',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPhoto() async {
    if (_photos.length >= 6) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }

  void _deletePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 8) {
        _selectedInterests.add(interest);
      }
    });
  }

  void _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: 保存用戶資料到後端
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('檔案已保存'),
          backgroundColor: Color(0xFF38A169),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    _locationController.dispose();
    super.dispose();
  }
} 