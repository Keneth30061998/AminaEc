import 'dart:io';

import 'package:amina_ec/src/models/app_banner.dart';
import 'package:amina_ec/src/providers/app_banner_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/widgets/app_banner_visual.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../components/Compress/image_compress_util.dart';

/// Editor gráfico independiente del módulo de asistencia.
class AppBannerEditorSheet extends StatefulWidget {
  final AppBanner? banner;

  final VoidCallback? onSaved;

  const AppBannerEditorSheet({
    super.key,
    this.banner,
    this.onSaved,
  });

  @override
  State<AppBannerEditorSheet> createState() => _AppBannerEditorSheetState();
}

class _AppBannerEditorSheetState extends State<AppBannerEditorSheet> {
  final AppBannerProvider _provider = AppBannerProvider();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  AppBanner? _currentBanner;
  File? _selectedImage;
  bool _active = false;
  bool _loading = true;
  bool _saving = false;
  String _textColor = 'white';
  String _textStyle = 'strong';
  double _textSize = 30;
  double _displaySeconds = 5;

  static const Map<String, String> _colorLabels = {
    'white': 'Blanco',
    'black': 'Negro',
    'gold': 'Dorado',
    'indigo': 'Índigo',
  };

  static const Map<String, String> _styleLabels = {
    'strong': 'Impacto',
    'modern': 'Moderno',
    'elegant': 'Elegante',
    'condensed': 'Condensado',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final banner = widget.banner;
      if (!mounted) return;
      setState(() {
        _currentBanner = banner;
        _titleController.text = banner?.title ?? '';
        _messageController.text = banner?.message ?? '';
        _linkController.text = banner?.linkUrl ?? '';
        _active = banner?.isActive ?? false;
        _textColor = banner?.textColor ?? 'white';
        _textStyle = banner?.textStyle ?? 'strong';
        _textSize = banner?.textSize ?? 30;
        _displaySeconds = (banner?.displaySeconds ?? 5).toDouble();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      Get.snackbar(
        'No se pudo cargar',
        error.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (picked == null || !mounted) {
        return;
      }

      final originalFile = File(picked.path);

      print('');
      print('══════════════════════════════════════════════════');
      print('🖼️ [BANNER] IMAGEN ORIGINAL');
      print('══════════════════════════════════════════════════');
      print('📁 Path: ${originalFile.path}');
      print('📦 Tamaño: ${await originalFile.length()} bytes');
      print('══════════════════════════════════════════════════');
      print('');

      final compressedFile = await ImageCompressUtil.compress(
        input: originalFile,
        minWidth: 1920,
        minHeight: 1080,
        quality: 80,
      );

      final originalSize = await originalFile.length();
      final compressedSize = await compressedFile.length();

      print('');
      print('══════════════════════════════════════════════════');
      print('🖼️ [BANNER] IMAGEN COMPRIMIDA');
      print('══════════════════════════════════════════════════');
      print('📁 Path: ${compressedFile.path}');
      print('📦 Tamaño original: $originalSize bytes');
      print('📦 Tamaño comprimido: $compressedSize bytes');

      if (originalSize > 0) {
        final reduction =
            ((originalSize - compressedSize) / originalSize) * 100;

        print(
          '📉 Reducción: ${reduction.toStringAsFixed(2)}%',
        );
      }

      print('══════════════════════════════════════════════════');
      print('');

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImage = compressedFile;
      });
    } catch (error, stackTrace) {
      print('');
      print('══════════════════════════════════════════════════');
      print('❌ [BANNER] ERROR COMPRIMIENDO IMAGEN');
      print('══════════════════════════════════════════════════');
      print('Error: $error');
      print('StackTrace: $stackTrace');
      print('══════════════════════════════════════════════════');
      print('');

      if (!mounted) {
        return;
      }

      Get.snackbar(
        'Error',
        'No se pudo procesar la imagen seleccionada.',
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    }
  }

  AppBanner _draftBanner() {
    final link = _linkController.text.trim();

    return AppBanner(
      id: _currentBanner?.id,
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      imageUrl: _currentBanner?.imageUrl,
      textColor: _textColor,
      textStyle: _textStyle,
      textSize: _textSize,
      linkText: link.isEmpty ? null : 'Abrir',
      linkUrl: link.isEmpty ? null : link,
      isActive: _active,
      position: _currentBanner?.position ?? 1,
      displaySeconds: _displaySeconds.round(),
    );
  }

  bool _isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    final draft = _draftBanner();

    final hasImage = _selectedImage != null || draft.hasImage;

    if (_active && !hasImage) {
      Get.snackbar(
        'Imagen requerida',
        'Selecciona una imagen antes de activar el banner.',
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );

      return;
    }

    final link = _linkController.text.trim();

    if (link.isNotEmpty && !_isValidHttpUrl(link)) {
      Get.snackbar(
        'Enlace incorrecto',
        'El enlace debe comenzar con http:// o https://.',
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );

      return;
    }

    setState(
      () => _saving = true,
    );

    try {
      late AppBanner updated;

      /**
       * NUEVO
       */
      if (draft.id == null) {
        updated = await _provider.createBanner(
          draft,
          imageFile: _selectedImage,
        );
      }

      /**
       * EXISTENTE
       */
      else {
        updated = await _provider.updateBanner(
          draft,
          imageFile: _selectedImage,
        );
      }

      if (!mounted) {
        return;
      }

      Get.snackbar(
        'Cambios guardados',
        updated.isActive
            ? 'El banner está visible para los usuarios.'
            : 'El banner quedó guardado, pero está desactivado.',
        backgroundColor: Colors.white,
        colorText: Colors.green.shade700,
      );

      widget.onSaved?.call();

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      Get.snackbar(
        'No se pudo guardar',
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
      print(error);
    } finally {
      if (mounted) {
        setState(
          () => _saving = false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(
        child: SizedBox(
            height: 260, child: Center(child: CircularProgressIndicator())),
      );
    }

    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.94),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.banner == null
                      ? 'Nuevo banner'
                      : 'Editar banner',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: almostBlack,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                    'Crea una pieza visual con fotografía, texto superpuesto y enlace.',
                    style: GoogleFonts.roboto(
                        fontSize: 14, height: 1.4, color: Colors.black54)),
                const SizedBox(height: 18),
                _activeSwitch(),
                const SizedBox(height: 18),
                _sectionTitle('1. Imagen'),
                const SizedBox(height: 10),
                _imageSelector(),
                const SizedBox(height: 20),
                _sectionTitle('2. Texto'),
                const SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  maxLength: 120,
                  maxLines: 2,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                      label: 'Texto principal',
                      hint: 'Ej. Tema',
                      icon: Icons.title_rounded),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLength: 500,
                  minLines: 2,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                      label: 'Texto secundario',
                      hint: 'Ej. 5:00 AM',
                      icon: Icons.subject_rounded),
                ),
                const SizedBox(height: 12),
                _sectionTitle('3. Color'),
                const SizedBox(height: 9),
                _colorPicker(),
                const SizedBox(height: 18),
                _sectionTitle('4. Estilo'),
                const SizedBox(height: 9),
                _stylePicker(),
                const SizedBox(height: 18),
                _sectionTitle('5. Tamaño'),
                const SizedBox(height: 6),
                _sizePicker(),
                const SizedBox(height: 18),
                _sectionTitle('6. Duración'),
                const SizedBox(height: 6),
                _durationPicker(),
                const SizedBox(height: 18),
                _sectionTitle('7. Enlace'),
                const SizedBox(height: 9),
                TextField(
                  controller: _linkController,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDecoration(
                      label: 'URL al tocar el banner',
                      hint: 'https://ejemplo.com',
                      icon: Icons.link_rounded),
                ),
                const SizedBox(height: 22),
                _sectionTitle('Vista previa'),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: _active ? 1 : 0.55,
                  duration: const Duration(milliseconds: 180),
                  child: AppBannerVisual(
                      banner: _draftBanner(), localImage: _selectedImage),
                ),
                const SizedBox(height: 24),
                _actions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeSwitch() {
    return Material(
      color: colorBackgroundBox,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile.adaptive(
        value: _active,
        activeColor: almostBlack,
        title: Text(
          _active ? 'Banner activo' : 'Banner desactivado',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: almostBlack,
          ),
        ),
        subtitle: Text(
          _active
              ? 'Se mostrará en el Home de los usuarios.'
              : 'Puedes diseñarlo y guardarlo sin publicarlo todavía.',
          style: GoogleFonts.roboto(
            fontSize: 12.5,
            color: Colors.black54,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _active = value;
          });
        },
      ),
    );
  }

  Widget _imageSelector() {
    final hasRemoteImage = (_currentBanner?.imageUrl?.trim() ?? '').isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(_selectedImage != null || hasRemoteImage
              ? 'Cambiar imagen'
              : 'Seleccionar imagen'),
          style: OutlinedButton.styleFrom(
            foregroundColor: almostBlack,
            minimumSize: const Size.fromHeight(48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 7),
        Text(
            'JPG, PNG o WebP. El servidor la optimizará antes de guardarla en Firebase.',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.black45)),
      ],
    );
  }

  Widget _colorPicker() => Wrap(
        spacing: 9,
        runSpacing: 9,
        children: _colorLabels.entries.map((entry) {
          return ChoiceChip(
            selected: _textColor == entry.key,
            onSelected: (_) => setState(() => _textColor = entry.key),
            avatar: CircleAvatar(
                radius: 8, backgroundColor: _colorValue(entry.key)),
            label: Text(entry.value,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          );
        }).toList(),
      );

  Widget _stylePicker() => Wrap(
        spacing: 9,
        runSpacing: 9,
        children: _styleLabels.entries.map((entry) {
          return ChoiceChip(
            selected: _textStyle == entry.key,
            onSelected: (_) => setState(() => _textStyle = entry.key),
            label: Text(entry.value,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          );
        }).toList(),
      );

  Widget _sizePicker() => Row(
        children: [
          Text('${_textSize.round()}',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: almostBlack)),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: _textSize,
              min: 18,
              max: 48,
              divisions: 30,
              label: '${_textSize.round()}',
              onChanged: (value) => setState(() => _textSize = value),
            ),
          ),
        ],
      );

  Widget _actions() => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                  foregroundColor: almostBlack,
                  minimumSize: const Size.fromHeight(50)),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: almostBlack,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Guardar'),
            ),
          ),
        ],
      );

  Widget _durationPicker() {
    return Row(
      children: [
        Text(
          '${_displaySeconds.round()} s',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: almostBlack,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Slider(
            value: _displaySeconds,
            min: 2,
            max: 60,
            divisions: 58,
            label: '${_displaySeconds.round()} s',
            onChanged: (value) {
              setState(() {
                _displaySeconds = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w700, color: almostBlack),
      );

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: almostBlack),
      filled: true,
      fillColor: colorBackgroundBox,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: almostBlack, width: 1.2),
      ),
    );
  }

  Color _colorValue(String key) {
    switch (key) {
      case 'black':
        return const Color(0xff101114);
      case 'gold':
        return Color(0xFFDAFF7C);
      case 'indigo':
        return const Color(0xff6C63FF);
      case 'white':
      default:
        return Colors.white;
    }
  }
}
