import 'dart:async';
import 'dart:io';

import 'package:amina_ec/src/models/app_banner.dart';
import 'package:amina_ec/src/widgets/app_banner_visual.dart';

import 'package:flutter/material.dart';
import 'package:amina_ec/src/models/app_banner.dart';

class AppBannerCarousel extends StatefulWidget {
  final List<AppBanner> banners;

  /// Se ejecuta cuando el usuario toca la carta principal.
  final ValueChanged<AppBanner>? onTap;

  const AppBannerCarousel({
    super.key,
    required this.banners,
    this.onTap,
  });

  @override
  State<AppBannerCarousel> createState() => _AppBannerCarouselState();
}

class _AppBannerCarouselState extends State<AppBannerCarousel>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // ESTADO
  // ============================================================

  int _currentIndex = 0;

  Timer? _timer;

  late AnimationController _animationController;

  double _dragOffset = 0.0;

  bool _isAnimating = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 650,
      ),
    );

    _startTimer();
  }

  // ============================================================
  // UPDATE WIDGET
  // ============================================================

  @override
  void didUpdateWidget(
    covariant AppBannerCarousel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.banners != widget.banners) {
      if (widget.banners.isEmpty) {
        _currentIndex = 0;
      } else if (_currentIndex >= widget.banners.length) {
        _currentIndex = 0;
      }

      _animationController.reset();
      _dragOffset = 0.0;

      _startTimer();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();

    super.dispose();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    if (widget.banners.length <= 1) {
      return;
    }

    if (_currentIndex >= widget.banners.length) {
      _currentIndex = 0;
    }

    final banner = widget.banners[_currentIndex];

    final seconds = (banner.displaySeconds ?? 5).clamp(1, 60).toInt();

    _timer = Timer(
      Duration(
        seconds: seconds,
      ),
      () {
        if (mounted) {
          _nextBanner();
        }
      },
    );
  }

  // ============================================================
  // SIGUIENTE BANNER
  // ============================================================

  Future<void> _nextBanner() async {
    if (_isAnimating || widget.banners.length <= 1) {
      return;
    }

    _isAnimating = true;

    _timer?.cancel();

    _dragOffset = 0.0;

    await _animationController.forward(
      from: 0.0,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.banners.length;
    });

    _animationController.reset();

    _isAnimating = false;

    _startTimer();
  }

  // ============================================================
  // BANNER ANTERIOR
  // ============================================================

  Future<void> _previousBanner() async {
    if (_isAnimating || widget.banners.length <= 1) {
      return;
    }

    _isAnimating = true;

    _timer?.cancel();

    _dragOffset = 0.0;

    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.banners.length) % widget.banners.length;
    });

    await Future.delayed(
      const Duration(
        milliseconds: 120,
      ),
    );

    if (!mounted) {
      return;
    }

    _isAnimating = false;

    _startTimer();
  }

  // ============================================================
  // DRAG UPDATE
  // ============================================================

  void _onHorizontalDragUpdate(
    DragUpdateDetails details,
  ) {
    if (_isAnimating || widget.banners.length <= 1) {
      return;
    }

    setState(() {
      _dragOffset += details.delta.dx;

      final maxDrag = MediaQuery.of(context).size.width * 0.85;

      if (_dragOffset > maxDrag) {
        _dragOffset = maxDrag;
      }

      if (_dragOffset < -maxDrag) {
        _dragOffset = -maxDrag;
      }
    });
  }

  // ============================================================
  // DRAG END
  // ============================================================

  void _onHorizontalDragEnd(
    DragEndDetails details,
  ) {
    if (_isAnimating || widget.banners.length <= 1) {
      return;
    }

    const threshold = 80.0;

    if (_dragOffset < -threshold) {
      _dragOffset = 0.0;
      _nextBanner();
      return;
    }

    if (_dragOffset > threshold) {
      _dragOffset = 0.0;
      _previousBanner();
      return;
    }

    setState(() {
      _dragOffset = 0.0;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.banners.length == 1) {
      return _buildSingleBanner(
        widget.banners.first,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCarousel(),
        const SizedBox(
          height: 18.0,
        ),
        _buildIndicators(),
      ],
    );
  }

  // ============================================================
  // CAROUSEL
  // ============================================================

  Widget _buildCarousel() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final width = constraints.maxWidth;

        /*
         * Antes:
         *
         * width * 0.58
         *
         * En móviles la carta terminaba siendo demasiado
         * pequeña verticalmente para contener todo el contenido.
         *
         * Ahora aumentamos ligeramente la altura en móviles.
         */

        final height = width < 380.0
            ? width * 0.68
            : width < 500.0
                ? width * 0.62
                : width * 0.48;

        return Padding(
          padding: const EdgeInsets.only(right: 25),
          child: SizedBox(
            width: width,
            height: height,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ==========================================
                  // CARTAS TRASERAS
                  // ==========================================

                  _buildBackgroundCards(
                    width,
                    height,
                  ),

                  // ==========================================
                  // CARTA PRINCIPAL
                  // ==========================================

                  _buildAnimatedMainCard(
                    width,
                    height,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CARTAS TRASERAS
  // ============================================================

  Widget _buildBackgroundCards(
    double width,
    double height,
  ) {
    if (widget.banners.length <= 1) {
      return const SizedBox.shrink();
    }

    final firstBackgroundIndex = (_currentIndex + 1) % widget.banners.length;

    final secondBackgroundIndex = (_currentIndex + 2) % widget.banners.length;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (
        context,
        child,
      ) {
        final animationValue = Curves.easeInOutCubic.transform(
          _animationController.value,
        );

        // ==========================================
        // CARTA 2
        // ==========================================

        final firstOffset = 18.0 * (1.0 - animationValue);

        final firstScale = 0.975 + (0.025 * animationValue);

        // ==========================================
        // CARTA 3
        // ==========================================

        final secondOffset = 36.0 - (18.0 * animationValue);

        final secondScale = 0.95 + (0.025 * animationValue);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ==========================================
            // TERCERA CARTA
            // ==========================================

            Positioned(
              left: secondOffset,
              right: -secondOffset,
              top: 0.0,
              bottom: 0.0,
              child: Transform.scale(
                scale: secondScale,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.82,
                  child: _buildBannerCard(
                    widget.banners[secondBackgroundIndex],
                    width,
                    height,
                    isBackground: true,
                  ),
                ),
              ),
            ),

            // ==========================================
            // SEGUNDA CARTA
            // ==========================================

            Positioned(
              left: firstOffset,
              right: -firstOffset,
              top: 0.0,
              bottom: 0.0,
              child: Transform.scale(
                scale: firstScale,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.92,
                  child: _buildBannerCard(
                    widget.banners[firstBackgroundIndex],
                    width,
                    height,
                    isBackground: true,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CARTA PRINCIPAL ANIMADA
  // ============================================================

  Widget _buildAnimatedMainCard(
    double width,
    double height,
  ) {
    final banner = widget.banners[_currentIndex];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (
        context,
        child,
      ) {
        final animationValue = Curves.easeInOutCubic.transform(
          _animationController.value,
        );

        final slideDistance = width * 1.15;

        final automaticOffset = -slideDistance * animationValue;

        final totalOffset = automaticOffset + _dragOffset;

        final scale = 1.0 - (0.08 * animationValue);

        final rotation = -0.018 * animationValue;

        return Positioned(
          left: totalOffset,
          right: -totalOffset,
          top: 0.0,
          bottom: 0.0,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(
                scale,
                scale,
              )
              ..rotateZ(rotation),
            child: child,
          ),
        );
      },
      child: _buildBannerCard(
        banner,
        width,
        height,
        isBackground: false,
      ),
    );
  }

  // ============================================================
  // CARTA
  // ============================================================
  Widget _buildBannerCard(
    AppBanner banner,
    double width,
    double height, {
    required bool isBackground,
  }) {
    final borderRadius = 24.0;

    final visual = AppBannerVisual(
      banner: banner,
      borderRadius: borderRadius,
      onTap: isBackground || widget.onTap == null
          ? null
          : () {
              widget.onTap!(banner);
            },
    );

    /*
   * Las cartas traseras son únicamente decorativas.
   * La carta frontal conserva toda la interacción.
   */
    return IgnorePointer(
      ignoring: isBackground,
      child: visual,
    );
  }

  // ============================================================
  // IMAGEN
  // ============================================================

  Widget _buildBannerImage(
    AppBanner banner,
  ) {
    final imageUrl = banner.imageUrl;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        color: const Color(
          0xFF11101F,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          color: const Color(
            0xFF11101F,
          ),
        );
      },
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: const Color(
            0xFF11101F,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GRADIENTES
  // ============================================================

  Widget _buildGradient() {
    return Stack(
      children: [
        // Gradiente lateral
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF080616),
                Color(0xC4080616),
                Color(0x35080616),
                Color(0x10080616),
              ],
              stops: [
                0.0,
                0.43,
                0.72,
                1.0,
              ],
            ),
          ),
        ),

        // Gradiente inferior
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xCC05040D),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENIDO DEL BANNER
  // ============================================================

  Widget _buildBannerContent(
    AppBanner banner,
    double width,
    double height,
  ) {
    /*
     * ==========================================================
     * IMPORTANTE
     * ==========================================================
     *
     * Ya no utilizamos:
     *
     *   Column + Spacer + Spacer
     *
     * porque eso provocaba:
     *
     * RenderFlex overflow
     *
     * especialmente en móviles.
     *
     * En su lugar utilizamos un Stack con posiciones relativas.
     * Así cada elemento conoce exactamente el espacio disponible.
     */

    final isSmall = width < 380.0;

    final horizontalPadding = isSmall
        ? 20.0
        : width < 500.0
            ? 24.0
            : 46.0;

    final topPadding = isSmall
        ? 16.0
        : width < 500.0
            ? 20.0
            : 32.0;

    final bottomPadding = isSmall
        ? 14.0
        : width < 500.0
            ? 18.0
            : 24.0;

    final progressBottom = bottomPadding;

    final availableWidth = width - (horizontalPadding * 2);

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: topPadding,
        bottom: bottomPadding,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BADGE NUEVO
          // ======================================================

          if (_hasText(banner.title))
            Positioned(
              left: 0.0,
              top: 0.0,
              child: _buildNewBadge(
                compact: isSmall,
              ),
            ),

          // ======================================================
          // CONTENIDO CENTRAL
          // ======================================================

          Positioned(
            left: 0.0,
            right: 0.0,

            /*
             * Dejamos espacio suficiente para:
             *
             * - badge
             * - progress bar
             */

            top: isSmall ? 52.0 : 58.0,
            bottom: isSmall ? 28.0 : 32.0,
            child: _buildMainTextContent(
              banner,
              availableWidth,
              isSmall,
            ),
          ),

          // ======================================================
          // PROGRESS BAR
          // ======================================================

          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: progressBottom,
            child: _buildProgressBar(
              banner,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTENIDO CENTRAL
  // ============================================================

  Widget _buildMainTextContent(
    AppBanner banner,
    double width,
    bool isSmall,
  ) {
    final titleFontSize = isSmall
        ? 21.0
        : width < 450.0
            ? 25.0
            : 42.0;

    final messageFontSize = isSmall
        ? 11.5
        : width < 450.0
            ? 13.0
            : 18.0;

    final buttonHeight = isSmall ? 38.0 : 48.0;

    final buttonHorizontalPadding = isSmall ? 16.0 : 21.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // ======================================================
        // TITULO
        // ======================================================

        if (_hasText(banner.title))
          Text(
            banner.title!,
            maxLines: isSmall ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _parseColor(
                banner.textColor,
                fallback: Colors.white,
              ),
              fontSize: titleFontSize,
              height: 0.98,
              fontWeight: FontWeight.w900,
              fontStyle: banner.textStyle == 'italic'
                  ? FontStyle.italic
                  : FontStyle.normal,
              letterSpacing: -0.8,
            ),
          ),

        // ======================================================
        // MENSAJE
        // ======================================================

        if (_hasText(banner.message))
          Padding(
            padding: EdgeInsets.only(
              top: isSmall ? 5.0 : 8.0,
            ),
            child: Text(
              banner.message!,
              maxLines: isSmall ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(
                  0.88,
                ),
                fontSize: messageFontSize,
                height: 1.25,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

        // ======================================================
        // BOTON
        // ======================================================

        if (_hasText(banner.linkText))
          Padding(
            padding: EdgeInsets.only(
              top: isSmall ? 7.0 : 14.0,
            ),
            child: SizedBox(
              height: buttonHeight,
              child: _buildLinkButton(
                banner,
                compact: isSmall,
                horizontalPadding: buttonHorizontalPadding,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // BADGE NUEVO
  // ============================================================

  Widget _buildNewBadge({
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 13.0 : 17.0,
        vertical: compact ? 7.0 : 9.0,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C2CFF),
            Color(0xFF4D16C7),
          ],
        ),
        borderRadius: BorderRadius.circular(
          11.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF7C2CFF,
            ).withOpacity(0.35),
            blurRadius: 12.0,
            offset: const Offset(
              0.0,
              5.0,
            ),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.campaign_rounded,
            color: Colors.white,
            size: compact ? 17.0 : 20.0,
          ),
          SizedBox(
            width: compact ? 6.0 : 8.0,
          ),
          Text(
            'NUEVO',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 12.0 : 14.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTON
  // ============================================================

  Widget _buildLinkButton(
    AppBanner banner, {
    bool compact = false,
    double horizontalPadding = 21.0,
  }) {
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7430FF),
              Color(0xFF5518D8),
            ],
          ),
          borderRadius: BorderRadius.circular(
            compact ? 11.0 : 13.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF6E2BFF,
              ).withOpacity(0.35),
              blurRadius: 15.0,
              offset: const Offset(
                0.0,
                7.0,
              ),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                banner.linkText ?? 'Ver más',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 12.5 : 15.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(
              width: compact ? 8.0 : 12.0,
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: compact ? 17.0 : 21.0,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS BAR
  // ============================================================

  Widget _buildProgressBar(
    AppBanner banner,
  ) {
    final seconds = (banner.displaySeconds ?? 5).clamp(1, 60).toInt();

    return TweenAnimationBuilder<double>(
      key: ValueKey(
        '${banner.id}-${_currentIndex}',
      ),
      tween: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ),
      duration: Duration(
        seconds: seconds,
      ),
      curve: Curves.linear,
      builder: (
        context,
        value,
        child,
      ) {
        return Container(
          height: 5.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.38,
            ),
            borderRadius: BorderRadius.circular(
              20.0,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7A32FF),
                      Color(0xFFB25CFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BANNER ÚNICO
  // ============================================================

  Widget _buildSingleBanner(
    AppBanner banner,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final width = constraints.maxWidth;

        final height = width < 380.0
            ? width * 0.68
            : width < 500.0
                ? width * 0.62
                : width * 0.48;

        return SizedBox(
          width: width,
          height: height,
          child: _buildBannerCard(
            banner,
            width,
            height,
            isBackground: false,
          ),
        );
      },
    );
  }

  // ============================================================
  // INDICADORES
  // ============================================================

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.banners.length,
        (index) {
          final selected = index == _currentIndex;

          return GestureDetector(
            onTap: () {
              if (_isAnimating || index == _currentIndex) {
                return;
              }

              _timer?.cancel();

              setState(() {
                _currentIndex = index;
                _dragOffset = 0.0;
              });

              _animationController.reset();

              _startTimer();
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 250,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              width: selected ? 28.0 : 9.0,
              height: 9.0,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF7131F4,
                      )
                    : const Color(
                        0xFFD0D0D8,
                      ),
                borderRadius: BorderRadius.circular(
                  20.0,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFF7131F4,
                          ).withOpacity(
                            0.35,
                          ),
                          blurRadius: 8.0,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  bool _hasText(
    String? value,
  ) {
    return value != null && value.trim().isNotEmpty;
  }

  // ============================================================
  // COLOR
  // ============================================================

  Color _parseColor(
    String? color, {
    required Color fallback,
  }) {
    if (color == null || color.trim().isEmpty) {
      return fallback;
    }

    final value = color.trim().toLowerCase();

    switch (value) {
      case 'white':
        return Colors.white;

      case 'black':
        return Colors.black;

      case 'red':
        return Colors.red;

      case 'blue':
        return Colors.blue;

      case 'green':
        return Colors.green;

      case 'purple':
        return const Color(
          0xFF7B2FFF,
        );
    }

    try {
      final hex = value.replaceFirst(
        '#',
        '',
      );

      if (hex.length == 6) {
        return Color(
          int.parse(
            'FF$hex',
            radix: 16,
          ),
        );
      }

      if (hex.length == 8) {
        return Color(
          int.parse(
            hex,
            radix: 16,
          ),
        );
      }
    } catch (_) {}

    return fallback;
  }
}
