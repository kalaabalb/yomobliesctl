import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utility/responsive_utils.dart';
import '../../../utility/constants.dart';

class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.totalOrder,
  }) : super(key: key);

  final String title, svgSrc;
  final int totalOrder;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      margin: EdgeInsets.only(top: isMobile ? 8 : defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : defaultPadding,
        vertical: isMobile ? 10 : defaultPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(width: 1, color: primaryColor.withOpacity(0.14)),
        borderRadius: const BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 18,
                  width: 18,
                  child: SvgPicture.asset(
                    svgSrc,
                    colorFilter: const ColorFilter.mode(
                      Colors.white70,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
                Text(
                  "$totalOrder orders",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: SvgPicture.asset(
                    svgSrc,
                    colorFilter:
                        const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          "$totalOrder orders",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
