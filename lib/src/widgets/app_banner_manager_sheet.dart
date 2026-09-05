import 'package:amina_ec/src/models/app_banner.dart';
import 'package:amina_ec/src/providers/app_banner_provider.dart';
import 'package:amina_ec/src/utils/color.dart';
import 'package:amina_ec/src/widgets/app_banner_editor_sheet.dart';
import 'package:amina_ec/src/widgets/app_banner_visual.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBannerManagerSheet extends StatefulWidget {
  const AppBannerManagerSheet({
    super.key,
  });

  @override
  State<AppBannerManagerSheet> createState() => _AppBannerManagerSheetState();
}

class _AppBannerManagerSheetState extends State<AppBannerManagerSheet> {
  final AppBannerProvider _provider = AppBannerProvider();

  List<AppBanner> _banners = <AppBanner>[];

  bool _loading = true;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    try {
      final banners = await _provider.getAllAdmin();

      if (!mounted) {
        return;
      }

      setState(() {
        _banners = banners
          ..sort(
            (a, b) => a.position.compareTo(
              b.position,
            ),
          );

        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(
        () => _loading = false,
      );

      Get.snackbar(
        'No se pudo cargar',
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    }
  }

  Future<void> _openEditor(
    AppBanner? banner,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppBannerEditorSheet(
        banner: banner,
        onSaved: _load,
      ),
    );

    await _load();
  }

  Future<void> _deleteBanner(
    AppBanner banner,
  ) async {
    if (banner.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Eliminar banner',
        ),
        content: Text(
          '¿Seguro que deseas eliminar este banner?',
          style: GoogleFonts.roboto(
            color: almostBlack
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              false,
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(color: almostBlack),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              true,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text(
              'Eliminar',
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _provider.deleteBanner(
        banner.id!,
      );

      await _load();

      Get.snackbar(
        'Banner eliminado',
        'El banner fue eliminado correctamente.',
        backgroundColor: Colors.white,
        colorText: Colors.green.shade700,
      );
    } catch (error) {
      Get.snackbar(
        'No se pudo eliminar',
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    }
  }

  Future<void> _moveBanner(
    int index,
    int direction,
  ) async {
    final targetIndex = index + direction;

    if (targetIndex < 0 || targetIndex >= _banners.length) {
      return;
    }

    final current = _banners[index];

    final target = _banners[targetIndex];

    if (current.id == null || target.id == null) {
      return;
    }

    setState(
      () => _saving = true,
    );

    try {
      final currentPosition = current.position;

      final targetPosition = target.position;

      await Future.wait([
        _provider.updatePosition(
          current.id!,
          targetPosition,
        ),
        _provider.updatePosition(
          target.id!,
          currentPosition,
        ),
      ]);

      await _load();
    } catch (error) {
      Get.snackbar(
        'No se pudo cambiar el orden',
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(
          () => _saving = false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(
                context,
              ).size.height *
              0.94,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              28,
            ),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 14,
            ),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(
                  30,
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Banners',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: almostBlack,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Administra los banners del inicio.',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openEditor(
                      null,
                    ),
                    icon: const Icon(
                      Icons.add,
                      size: 19,
                    ),
                    label: const Text(
                      'Nuevo',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: almostBlack,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _banners.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              4,
                              20,
                              28,
                            ),
                            itemCount: _banners.length,
                            separatorBuilder: (_, __) => const SizedBox(
                              height: 14,
                            ),
                            itemBuilder: (_, index) {
                              return _bannerCard(
                                _banners[index],
                                index,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerCard(
    AppBanner banner,
    int index,
  ) {
    final isFirst = index == 0;

    final isLast = index == _banners.length - 1;

    return Container(
      padding: const EdgeInsets.all(
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(
            0.06,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.035,
            ),
            blurRadius: 14,
            offset: const Offset(
              0,
              6,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.75,
            child: AppBannerVisualPreview(
              banner: banner,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: banner.isActive
                      ? Colors.green.withOpacity(
                          0.10,
                        )
                      : Colors.grey.withOpacity(
                          0.10,
                        ),
                  borderRadius: BorderRadius.circular(
                    99,
                  ),
                ),
                child: Text(
                  banner.isActive ? 'Activo' : 'Inactivo',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: banner.isActive
                        ? Colors.green.shade700
                        : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                '${banner.displaySeconds} s',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              Text(
                '#${index + 1}',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: almostBlack,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          if (banner.title.trim().isNotEmpty)
            Text(
              banner.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: almostBlack,
              ),
            )
          else
            Text(
              'Sin texto principal',
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.black45,
              ),
            ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              IconButton(
                tooltip: 'Subir',
                onPressed: isFirst || _saving
                    ? null
                    : () => _moveBanner(
                          index,
                          -1,
                        ),
                icon: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                ),
              ),
              IconButton(
                tooltip: 'Bajar',
                onPressed: isLast || _saving
                    ? null
                    : () => _moveBanner(
                          index,
                          1,
                        ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Editar',
                onPressed: () => _openEditor(
                  banner,
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: () => _deleteBanner(
                  banner,
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.collections_outlined,
              size: 58,
              color: Colors.black26,
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              'No hay banners',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: almostBlack,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              'Crea tu primer banner para mostrarlo en el inicio.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            FilledButton.icon(
              onPressed: () => _openEditor(
                null,
              ),
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'Crear banner',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: almostBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/**
 * =========================================================
 * PREVIEW
 * =========================================================
 *
 * Evitamos hacer que AppBannerVisual ocupe
 * exactamente el mismo espacio con un AspectRatio
 * externo.
 */
class AppBannerVisualPreview extends StatelessWidget {
  final AppBanner banner;

  const AppBannerVisualPreview({
    super.key,
    required this.banner,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppBannerVisual(
      banner: banner,
      borderRadius: 16,
    );
  }
}
