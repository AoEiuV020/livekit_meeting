import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class NoVideoWidget extends StatelessWidget {
  //
  const NoVideoWidget({super.key});

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        child: LayoutBuilder(
          builder: (ctx, constraints) => Icon(
            Icons.videocam_off_outlined,
            color: LKColors.lkBlue,
            size: math.min(constraints.maxHeight, constraints.maxWidth) * 0.3,
          ),
        ),
      );
}
