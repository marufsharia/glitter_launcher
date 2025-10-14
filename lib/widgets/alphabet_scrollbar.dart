import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AlphabetScrollbar extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> appNames; // List of app names sorted alphabetically

  const AlphabetScrollbar({
    super.key,
    required this.scrollController,
    required this.appNames,
  });

  @override
  State<AlphabetScrollbar> createState() => _AlphabetScrollbarState();
}

class _AlphabetScrollbarState extends State<AlphabetScrollbar> {
  final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
  String? activeLetter;

  void _scrollToLetter(String letter) {
    final index = widget.appNames.indexWhere(
      (name) => name.toUpperCase().startsWith(letter),
    );

    if (index >= 0) {
      final scrollPosition = index * 100.0; // estimated item height
      widget.scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      setState(() => activeLetter = letter);

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => activeLetter = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final safePaddingTop = MediaQuery.of(context).padding.top;
    final safePaddingBottom = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          top: safePaddingTop + 20,
          bottom: safePaddingBottom + 20,
          right: 8,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final letterHeight = constraints.maxHeight / letters.length;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localY = box.globalToLocal(details.globalPosition).dy;
                int index = (localY ~/ letterHeight).clamp(
                  0,
                  letters.length - 1,
                );
                _scrollToLetter(letters[index]);
              },
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final localY = box.globalToLocal(details.globalPosition).dy;
                int index = (localY ~/ letterHeight).clamp(
                  0,
                  letters.length - 1,
                );
                _scrollToLetter(letters[index]);
              },
              child: Container(
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: letters.map((letter) {
                      final isActive = letter == activeLetter;
                      return AnimatedScale(
                        scale: isActive ? 1.5 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.yellow : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms),
            );
          },
        ),
      ),
    );
  }
}
