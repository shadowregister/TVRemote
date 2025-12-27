import '../device_discovery/domain/discovered_device.dart';
import 'base_tv_controller.dart';
import 'samsung/data/samsung_controller.dart';
import 'lg/data/lg_controller.dart';
import 'roku/data/roku_controller.dart';
import 'android_tv/data/android_tv_controller.dart';

class TvControllerFactory {
  static BaseTvController? createController(DiscoveredDevice device) {
    switch (device.brand) {
      case TvBrand.samsung:
        return SamsungController(device);
      case TvBrand.lg:
        return LgController(device);
      case TvBrand.roku:
        return RokuController(device);
      case TvBrand.androidTv:
        return AndroidTvController(device);
      case TvBrand.fireTv:
        // Fire TV uses ADB, similar to Android TV
        return AndroidTvController(device);
      case TvBrand.vizio:
        // TODO: Implement Vizio controller
        return null;
      case TvBrand.sony:
        // Sony Bravia uses similar protocol to Android TV for newer models
        return AndroidTvController(device);
      case TvBrand.unknown:
        return null;
    }
  }
}
