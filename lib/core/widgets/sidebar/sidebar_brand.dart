import 'package:material_ui/material_ui.dart';
import '../../constants/assets/app_assets.dart';

class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key, required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (compact)
              Image.asset(AppAssets.logo, height: 44)
            else
              Image.asset(AppAssets.appFullLogoWhite, height: 78),
          ],
        ),
      );
}
