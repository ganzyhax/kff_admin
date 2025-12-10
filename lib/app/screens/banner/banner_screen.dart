import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kff_super_admin/app/api/api.dart';
import 'package:kff_super_admin/constants/app_constants.dart';

class BannerItem {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final bool showTitle;
  final bool showSubtitle;
  final bool showButton;
  final bool showPremiumBadge;
  final String contentPosition;

  BannerItem({
    this.imageUrl,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onTap,
    this.backgroundColor,
    this.buttonColor,
    this.buttonTextColor,
    this.showTitle = true,
    this.showSubtitle = true,
    this.showButton = true,
    this.showPremiumBadge = true,
    this.contentPosition = 'center',
  });
}

class ArenaBannerCard extends StatelessWidget {
  final List<BannerItem> banners;
  final double height;

  const ArenaBannerCard({Key? key, required this.banners, this.height = 200})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox();

    final banner = banners.first;

    // Debug: Print received colors
    print(
      '🔵 ArenaBannerCard received buttonColor: ${banner.buttonColor?.value.toRadixString(16)} (${banner.buttonColor})',
    );
    print(
      '🔵 ArenaBannerCard received buttonTextColor: ${banner.buttonTextColor?.value.toRadixString(16)} (${banner.buttonTextColor})',
    );
    print(
      '🔵 Button background will be: ${banner.buttonColor ?? Colors.white}',
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: banner.imageUrl == null && banner.backgroundColor == null
            ? const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: banner.imageUrl == null ? banner.backgroundColor : null,
        boxShadow: [
          BoxShadow(
            color: (banner.backgroundColor ?? const Color(0xFF3B82F6))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (banner.imageUrl != null)
              Positioned.fill(
                child: Image.memory(
                  base64Decode(banner.imageUrl!.split(',').last),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.8),
                            const Color(0xFF2563EB).withOpacity(0.8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (banner.imageUrl != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.3),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: banner.contentPosition == 'top'
                    ? MainAxisAlignment.start
                    : (banner.contentPosition == 'bottom'
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.center),
                children: [
                  // Premium Badge
                  if (banner.showPremiumBadge)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.stars_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ПРЕМИУМ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (banner.showPremiumBadge) const SizedBox(height: 12),

                  // Title
                  if (banner.showTitle)
                    Text(
                      banner.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Dynamic spacing after title
                  if (banner.showTitle &&
                      (banner.showSubtitle || banner.showButton))
                    SizedBox(height: banner.showSubtitle ? 6 : 16),

                  // Subtitle
                  if (banner.showSubtitle)
                    Text(
                      banner.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Dynamic spacing after subtitle
                  if (banner.showSubtitle && banner.showButton)
                    const SizedBox(height: 16),

                  // Button
                  if (banner.showButton && banner.buttonText != null)
                    ElevatedButton(
                      onPressed: banner.onTap,
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: banner.buttonColor ?? Colors.white,
                            foregroundColor:
                                banner.buttonTextColor ??
                                const Color(0xFF3B82F6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ).copyWith(
                            // Force backgroundColor to update
                            backgroundColor: MaterialStateProperty.all(
                              banner.buttonColor ?? Colors.white,
                            ),
                          ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            banner.buttonText!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  banner.buttonTextColor ??
                                  const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color:
                                banner.buttonTextColor ??
                                const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerAdminPage extends StatefulWidget {
  const BannerAdminPage({Key? key}) : super(key: key);

  @override
  State<BannerAdminPage> createState() => _BannerAdminPageState();
}

class _BannerAdminPageState extends State<BannerAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _buttonTextController = TextEditingController(
    text: 'Узнать больше',
  );
  final TextEditingController _linkController = TextEditingController(
    text: '#',
  );
  final TextEditingController _orderController = TextEditingController(
    text: '0',
  );

  bool _isPremium = false;
  bool _isLoading = false;
  File? _selectedImage;
  String? _selectedImageBase64;
  String? _editingBannerId;
  List<Map<String, dynamic>> _banners = [];

  // Button colors
  Color _buttonColor = Colors.white;
  Color _buttonTextColor = const Color(0xFF3B82F6);

  // Background color
  Color _backgroundColor = const Color(0xFF3B82F6);

  // Visibility toggles
  bool _showTitle = true;
  bool _showSubtitle = true;
  bool _showButton = true;
  bool _showPremiumBadge = true;

  // Content position
  String _contentPosition = 'center'; // 'top', 'center', 'bottom'

  // Scroll controller for mobile
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBanners();

    _titleController.addListener(_updatePreview);
    _subtitleController.addListener(_updatePreview);
    _buttonTextController.addListener(_updatePreview);
  }

  void _updatePreview() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _buttonTextController.dispose();
    _linkController.dispose();
    _orderController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.get('api/banners');
      print('🟡 Load banners response: $response');

      if (response['success']) {
        // Backend returns: { success: true, count: X, data: [...] }
        final bannersData = response['data']['data'];
        print('🟡 Banners data type: ${bannersData.runtimeType}');
        print(
          '🟡 First banner (if exists): ${bannersData is List && bannersData.isNotEmpty ? bannersData[0] : "No banners"}',
        );

        setState(() {
          _banners = List<Map<String, dynamic>>.from(bannersData);
        });

        print('✅ Loaded ${_banners.length} banners');
      }
    } catch (e) {
      print('❌ Load error: $e');
      _showSnackBar('Ошибка загрузки: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      setState(() {
        _selectedImage = File(image.path);
        _selectedImageBase64 = base64String;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImageBase64 == null && _editingBannerId == null) {
      _showSnackBar('Выберите изображение', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> data = {
        'title': _titleController.text,
        'subtitle': _subtitleController.text,
        'buttonText': _buttonTextController.text,
        'link': _linkController.text,
        'order': int.parse(_orderController.text),
        'isPremium': _isPremium,
        'buttonColor': '#${_buttonColor.value.toRadixString(16).substring(2)}',
        'buttonTextColor':
            '#${_buttonTextColor.value.toRadixString(16).substring(2)}',
        'backgroundColor':
            '#${_backgroundColor.value.toRadixString(16).substring(2)}',
        'showTitle': _showTitle,
        'showSubtitle': _showSubtitle,
        'showButton': _showButton,
        'showPremiumBadge': _showPremiumBadge,
        'contentPosition': _contentPosition,
      };

      if (_selectedImageBase64 != null) {
        data['image'] = _selectedImageBase64!;
        data['fileName'] = _selectedImage?.path.split('/').last ?? 'banner.jpg';
      }

      var response;
      if (_editingBannerId != null) {
        response = await ApiClient.put('api/banners/$_editingBannerId', data);
      } else {
        response = await ApiClient.post('api/banners', data);
      }

      if (response['success']) {
        _showSnackBar(_editingBannerId != null ? 'Обновлено!' : 'Создано!');
        _resetForm();
        _loadBanners();
      } else {
        _showSnackBar(response['message'] ?? 'Ошибка', isError: true);
      }
    } catch (e) {
      _showSnackBar('Ошибка: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBanner(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Удалить баннер?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      var response = await ApiClient.delete('api/banners/$id');

      if (response['success']) {
        _showSnackBar('Удалено');
        _loadBanners();
      }
    } catch (e) {
      _showSnackBar('Ошибка: $e', isError: true);
    }
  }

  Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.white;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _subtitleController.clear();
    _buttonTextController.text = 'Узнать больше';
    _linkController.text = '#';
    _orderController.text = '0';
    setState(() {
      _isPremium = false;
      _selectedImage = null;
      _selectedImageBase64 = null;
      _editingBannerId = null;
      _buttonColor = Colors.white;
      _buttonTextColor = const Color(0xFF3B82F6);
      _backgroundColor = const Color(0xFF3B82F6);
      _showTitle = true;
      _showSubtitle = true;
      _showButton = true;
      _showPremiumBadge = true;
      _contentPosition = 'center';
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPreview() {
    final hasContent =
        _titleController.text.isNotEmpty ||
        _subtitleController.text.isNotEmpty ||
        _selectedImageBase64 != null;

    if (!hasContent) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.preview, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'Превью баннера',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Заполните форму для предпросмотра',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ArenaBannerCard(
      key: ValueKey(
        '${_buttonColor.value}_${_buttonTextColor.value}_${_backgroundColor.value}_${_showTitle}_${_showSubtitle}_${_showButton}_${_contentPosition}',
      ),
      height: 220,
      banners: [
        BannerItem(
          imageUrl: _selectedImageBase64,
          title: _titleController.text.isEmpty
              ? 'Заголовок баннера'
              : _titleController.text,
          subtitle: _subtitleController.text.isEmpty
              ? 'Подзаголовок баннера'
              : _subtitleController.text,
          buttonText: _buttonTextController.text.isEmpty
              ? 'Узнать больше'
              : _buttonTextController.text,
          buttonColor: _buttonColor,
          buttonTextColor: _buttonTextColor,
          backgroundColor: _backgroundColor,
          showTitle: _showTitle,
          showSubtitle: _showSubtitle,
          showButton: _showButton,
          showPremiumBadge: _showPremiumBadge,
          contentPosition: _contentPosition,
        ),
      ],
    );
  }

  Future<void> _pickColor(
    bool isButtonColor, {
    bool isBackgroundColor = false,
  }) async {
    Color? selectedColor;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final currentColor = isBackgroundColor
              ? _backgroundColor
              : (isButtonColor ? _buttonColor : _buttonTextColor);

          return AlertDialog(
            title: Text(
              isBackgroundColor
                  ? 'Цвет фона баннера'
                  : (isButtonColor ? 'Цвет кнопки' : 'Цвет текста кнопки'),
            ),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    [
                      Colors.white,
                      const Color(0xFF3B82F6),
                      const Color(0xFF10B981),
                      const Color(0xFFF59E0B),
                      const Color(0xFFEF4444),
                      const Color(0xFF8B5CF6),
                      const Color(0xFFEC4899),
                      Colors.black,
                      const Color(0xFF14B8A6),
                      const Color(0xFFF97316),
                    ].map((color) {
                      final isSelected = currentColor == color;

                      return GestureDetector(
                        onTap: () {
                          selectedColor = color;
                          Navigator.pop(dialogContext);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: isSelected ? 4 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 2),
                                  ],
                                )
                              : null,
                        ),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Закрыть'),
              ),
            ],
          );
        },
      ),
    );

    // Update color after dialog closes
    if (selectedColor != null) {
      setState(() {
        if (isBackgroundColor) {
          _backgroundColor = selectedColor!;
          print(
            '🎨 Background color changed to: ${_backgroundColor.value.toRadixString(16)}',
          );
        } else if (isButtonColor) {
          _buttonColor = selectedColor!;
          print(
            '🎨 Button color changed to: ${_buttonColor.value.toRadixString(16)}',
          );
        } else {
          _buttonTextColor = selectedColor!;
          print(
            '🎨 Button text color changed to: ${_buttonTextColor.value.toRadixString(16)}',
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 20 : 16),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 1, child: _buildForm()),
                            const SizedBox(width: 20),
                            Expanded(flex: 2, child: _buildBannersList()),
                          ],
                        )
                      : ListView(
                          controller: _scrollController,
                          children: [
                            _buildForm(),
                            const SizedBox(height: 20),
                            _buildBannersList(),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalBanners = _banners.length;
    final activeBanners = _banners.where((b) => b['isActive'] == true).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF8b5cf6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'Управление баннерами',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildStatItem('Всего', totalBanners),
              const SizedBox(width: 20),
              _buildStatItem('Активных', activeBanners),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Icon(
                  _editingBannerId != null ? Icons.edit : Icons.add_circle,
                  color: const Color(0xFF667eea),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _editingBannerId != null
                        ? 'Редактировать'
                        : 'Создать баннер',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // Full Width Preview
            Row(
              children: [
                Icon(Icons.preview, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Text(
                  'Предпросмотр',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPreview(),
            const SizedBox(height: 24),

            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Заголовок *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Введите заголовок' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: 'Подзаголовок *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.subtitles),
              ),
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Введите подзаголовок' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _buttonTextController,
              decoration: InputDecoration(
                labelText: 'Текст кнопки',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.smart_button),
              ),
            ),
            const SizedBox(height: 16),

            // Button Colors
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Цвет кнопки',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickColor(true),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _buttonColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Выбрать цвет',
                              style: TextStyle(
                                color: _buttonColor.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Цвет текста',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _pickColor(false),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: _buttonTextColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Выбрать цвет',
                              style: TextStyle(
                                color: _buttonTextColor.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Background Color
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Цвет фона (если нет изображения)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickColor(false, isBackgroundColor: true),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        'Выбрать цвет фона',
                        style: TextStyle(
                          color: _backgroundColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: 'Ссылка',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _orderController,
              decoration: InputDecoration(
                labelText: 'Порядок',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.format_list_numbered),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text('⭐ Премиум баннер'),
              value: _isPremium,
              onChanged: (value) => setState(() => _isPremium = value ?? false),
              activeColor: const Color(0xFF667eea),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Visibility Settings
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Отображение элементов',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Показать заголовок'),
                    value: _showTitle,
                    onChanged: (value) =>
                        setState(() => _showTitle = value ?? true),
                    activeColor: const Color(0xFF667eea),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Показать подзаголовок'),
                    value: _showSubtitle,
                    onChanged: (value) =>
                        setState(() => _showSubtitle = value ?? true),
                    activeColor: const Color(0xFF667eea),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Показать кнопку'),
                    value: _showButton,
                    onChanged: (value) =>
                        setState(() => _showButton = value ?? true),
                    activeColor: const Color(0xFF667eea),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Показать бейдж "Премиум"'),
                    value: _showPremiumBadge,
                    onChanged: (value) =>
                        setState(() => _showPremiumBadge = value ?? true),
                    activeColor: const Color(0xFF667eea),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Position Settings
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Позиция контента',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Верх',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: 'top',
                        groupValue: _contentPosition,
                        onChanged: (value) => setState(
                          () => _contentPosition = value ?? 'center',
                        ),
                        activeColor: const Color(0xFF667eea),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Центр',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: 'center',
                        groupValue: _contentPosition,
                        onChanged: (value) => setState(
                          () => _contentPosition = value ?? 'center',
                        ),
                        activeColor: const Color(0xFF667eea),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Низ',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: 'bottom',
                        groupValue: _contentPosition,
                        onChanged: (value) => setState(
                          () => _contentPosition = value ?? 'center',
                        ),
                        activeColor: const Color(0xFF667eea),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: _selectedImageBase64 != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              base64Decode(
                                _selectedImageBase64!.split(',').last,
                              ),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => setState(() {
                                _selectedImage = null;
                                _selectedImageBase64 = null;
                              }),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Выберите изображение',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                if (_editingBannerId != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetForm,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Отмена'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (_editingBannerId != null) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitForm,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Icon(
                            _editingBannerId != null ? Icons.save : Icons.add,
                          ),
                    label: Text(
                      _editingBannerId != null ? 'Сохранить' : 'Создать',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildBannersList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.view_list, color: Color(0xFF667eea)),
              SizedBox(width: 8),
              Text(
                'Список баннеров',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 30),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _banners.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Нет баннеров',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Создайте первый баннер',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _banners.length,
                    itemBuilder: (context, index) =>
                        _buildBannerItem(_banners[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(Map<String, dynamic> banner) {
    final isActive = banner['isActive'] ?? true;
    final isPremium = banner['isPremium'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isActive
              ? const Color(0xFF667eea).withOpacity(0.3)
              : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  banner['imageUrl'] ?? '',
                  width: 120,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banner['subtitle'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (isPremium)
                          _buildBadge(
                            'Premium',
                            Colors.amber[100]!,
                            Colors.amber[900]!,
                          ),
                        _buildBadge(
                          isActive ? 'Активен' : 'Неактивен',
                          isActive ? Colors.green[100]! : Colors.red[100]!,
                          isActive ? Colors.green[900]! : Colors.red[900]!,
                        ),
                        _buildBadge(
                          'Порядок: ${banner['order']}',
                          Colors.indigo[50]!,
                          Colors.indigo[900]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteBanner(banner['_id']),
                    color: Colors.red,
                    tooltip: 'Удалить',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
