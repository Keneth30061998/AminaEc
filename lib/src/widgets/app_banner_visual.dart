import 'dart:io';

import 'package:amina_ec/src/models/app_banner.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Componente visual único del banner.
/// Se reutiliza en el Home del usuario y en el preview del administrador.
class AppBannerVisual extends StatelessWidget {
  final bool useAspectRatio;
  final AppBanner banner;
  final File? localImage;
  final VoidCallback? onTap;
  final double borderRadius;

  const AppBannerVisual({
    super.key,
    required this.banner,
    this.localImage,
    this.onTap,
    this.borderRadius = 24,
    this.useAspectRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    final bannerContent = ClipRRect(
      borderRadius: BorderRadius.circular(
        borderRadius,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _image(),
          _readabilityGradient(),
          _content(),
        ],
      ),
    );

    final content = useAspectRatio
        ? AspectRatio(
      aspectRatio: 1.75,
      child: bannerContent,
    )
        : bannerContent;

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          borderRadius,
        ),
        child: content,
      ),
    );
  }

  Widget _image() {
    if (localImage != null) {
      return Image.file(localImage!, fit: BoxFit.cover);
    }

    final imageUrl = banner.imageUrl?.trim() ?? '';
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xffECEEF3),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffDDE1EA), Color(0xffAEB5C4)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 46, color: Colors.white70),
    );
  }

  Widget _readabilityGradient() {
    final hasText =
        banner.title.trim().isNotEmpty ||
            banner.message.trim().isNotEmpty;
    if (!hasText && !banner.hasLink) {
      return const SizedBox.shrink();
    }

    final blackText = banner.textColor == 'black';
    final colors = blackText
        ? [
      Colors.transparent,
      Colors.white.withValues(alpha: 0.20),
      Colors.white.withValues(alpha: 0.82),
    ]
        : [
      Colors.transparent,
      Colors.black.withValues(alpha: 0.08),
      Colors.black.withValues(alpha: 0.72),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.30, 0.58, 1.0],
          colors: colors,
        ),
      ),
    );
  }

  Widget _content() {
    final color = _resolveTextColor();
    final baseSize = banner.textSize.clamp(18, 48).toDouble();

    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (banner.title.trim().isNotEmpty)
            Text(
              banner.title.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: _resolveFontStyle(
                fontSize: baseSize,
                color: color,
                isTitle: true,
              ),
            ),
          if (banner.title.trim().isNotEmpty && banner.message.trim().isNotEmpty)
            const SizedBox(height: 7),
          if (banner.message.trim().isNotEmpty)
            Text(
              banner.message.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: _resolveFontStyle(
                fontSize: (baseSize * 0.50).clamp(12, 22).toDouble(),
                color: color.withValues(alpha: 0.94),
                isTitle: false,
              ),
            ),
          if (banner.hasLink)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Icon(Icons.arrow_outward_rounded, size: 19, color: color),
            ),
        ],
      ),
    );
  }

  Color _resolveTextColor() {
    switch (banner.textColor) {
      case 'black':
        return const Color(0xff101114);
      case 'gold':
        return const Color(0xFFDAFF7C);
      case 'indigo':
        return const Color(0xff6C63FF);
      case 'white':
      default:
        return Colors.white;
    }
  }

  TextStyle _resolveFontStyle({
    required double fontSize,
    required Color color,
    required bool isTitle,
  }) {
    final shadow = [
      Shadow(
        color: banner.textColor == 'black'
            ? Colors.white.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.32),
        blurRadius: 7,
        offset: const Offset(0, 2),
      ),
    ];

    switch (banner.textStyle) {
      case 'modern':
        return GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: isTitle ? FontWeight.w700 : FontWeight.w500,
          height: isTitle ? 1.02 : 1.25,
          color: color,
          shadows: shadow,
        );
      case 'elegant':
        return GoogleFonts.robotoSlab(
          fontSize: fontSize,
          fontWeight: isTitle ? FontWeight.w800 : FontWeight.w500,
          height: isTitle ? 1.06 : 1.28,
          color: color,
          shadows: shadow,
        );
      case 'condensed':
        return GoogleFonts.oswald(
          fontSize: fontSize,
          fontWeight: isTitle ? FontWeight.w700 : FontWeight.w500,
          height: isTitle ? 0.98 : 1.20,
          letterSpacing: isTitle ? 0.3 : 0.1,
          color: color,
          shadows: shadow,
        );
      case 'strong':
      default:
        return GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: isTitle ? FontWeight.w900 : FontWeight.w600,
          height: isTitle ? 1.00 : 1.23,
          letterSpacing: isTitle ? -0.45 : 0,
          color: color,
          shadows: shadow,
        );
    }
  }
}
