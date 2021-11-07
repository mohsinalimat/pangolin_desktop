/*
Copyright 2021 The dahliaOS Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'dart:async';

import 'package:dahlia_backend/dahlia_backend.dart';
import 'package:pangolin/components/overlays/quick_settings/pages/account_page.dart';
import 'package:pangolin/components/overlays/quick_settings/widgets/qs_action_button.dart';
import 'package:pangolin/components/overlays/quick_settings/widgets/qs_shortcut_button.dart';
import 'package:pangolin/components/overlays/quick_settings/widgets/qs_slider.dart';
import 'package:pangolin/components/overlays/quick_settings/widgets/qs_toggle_button.dart';
import 'package:pangolin/components/shell/shell.dart';
import 'package:pangolin/services/locales/locale_strings.g.dart';
import 'package:pangolin/services/locales/locales.g.dart';
import 'package:pangolin/utils/extensions/extensions.dart';
import 'package:pangolin/utils/data/common_data.dart';
import 'package:pangolin/utils/providers/connection_provider.dart';
import 'package:pangolin/utils/providers/customization_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pangolin/utils/providers/io_provider.dart';

class QuickSettingsOverlay extends ShellOverlay {
  static const String overlayId = 'quicksettings';

  QuickSettingsOverlay() : super(id: overlayId);

  @override
  _QuickSettingsOverlayState createState() => _QuickSettingsOverlayState();
}

class _QuickSettingsOverlayState extends State<QuickSettingsOverlay>
    with SingleTickerProviderStateMixin, ShellOverlayState {
  late AnimationController ac;

  @override
  void initState() {
    super.initState();
    ac = AnimationController(
      vsync: this,
      duration: CommonData.of(context).animationDuration(),
    );
  }

  @override
  void dispose() {
    ac.dispose();
    super.dispose();
  }

  @override
  Future<void> requestShow(Map<String, dynamic> args) async {
    controller.showing = true;
    await ac.forward();
  }

  @override
  Future<void> requestDismiss(Map<String, dynamic> args) async {
    await ac.reverse();
    controller.showing = false;
  }

  @override
  Widget build(BuildContext context) {
    final _customizationProvider = CustomizationProvider.of(context);
    // _getTime(context);
    final Animation<double> _animation = CurvedAnimation(
      parent: ac,
      curve: CommonData.of(context).animationCurve(),
    );

    if (!controller.showing) return SizedBox();

    return Positioned(
      bottom: _customizationProvider.isTaskbarRight ||
              _customizationProvider.isTaskbarLeft
          ? 8
          : !_customizationProvider.isTaskbarTop
              ? 48 + 8
              : null,
      top: _customizationProvider.isTaskbarTop ? 48 + 8 : null,
      right: _customizationProvider.isTaskbarRight
          ? 48 + 8
          : _customizationProvider.isTaskbarLeft
              ? null
              : 8,
      left: _customizationProvider.isTaskbarLeft ? 48 + 8 : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, chilld) => FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            alignment: FractionalOffset(
                0.8, !_customizationProvider.isTaskbarTop ? 1.0 : 0.0),
            child: BoxSurface(
              borderRadius:
                  CommonData.of(context).borderRadius(BorderRadiusType.BIG),
              width: 560,
              height: 490,
              dropShadow: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MaterialApp(
                  routes: {
                    "/": (context) => QsMain(),
                    "/account_page": (context) => QsAccountPage(),
                  },
                  theme: Theme.of(context)
                      .copyWith(scaffoldBackgroundColor: Colors.transparent),
                  debugShowCheckedModeBanner: false,
                  locale: context.locale,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QsMain extends StatelessWidget {
  const QsMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Action Button Bar
    List<Widget> _qsActionButton = [
      QsActionButton(
        leading: FlutterLogo(
          size: 18,
        ),
        title: "dahliaOS Live User",
        onPressed: () => Navigator.pushNamed(context, "/account_page"),
        margin: EdgeInsets.zero,
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: context.theme.darkMode ? ColorsX.white : ColorsX.black,
        ),
      ),
      Spacer(),
      QsActionButton(
        leading: Icon(IconsX.of(context).power),
        isCircular: true,
        //title: "Power",
      ),
      QsActionButton(
        leading: Icon(IconsX.of(context).sign_out),
        isCircular: true,
        //title: "Sign out",
      ),
      QsActionButton(
        leading: Icon(IconsX.of(context).edit),
        isCircular: true,
        //title: "Edit panel",
      ),
      QsActionButton(
        leading: Icon(IconsX.of(context).settings),
        isCircular: true,
        //title: "Settings",
        margin: EdgeInsets.only(left: 8),
      ),
    ];
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _qsActionButton,
            ),
            _qsTitle("Quick Controls"),
            Builder(builder: (context) {
              final _connectionProvider = ConnectionProvider.of(context);
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QsToggleButton(
                        title: LocaleStrings.qs.wifi,
                        icon: _connectionProvider.wifi
                            ? Icons.wifi_rounded
                            : Icons.wifi_off_rounded,
                        subtitle: "Connected",
                        value: _connectionProvider.wifi,
                        onPressed: () => _connectionProvider.wifi =
                            !_connectionProvider.wifi,
                      ),
                      QsToggleButton(
                        title: LocaleStrings.qs.bluetooth,
                        subtitle: _connectionProvider.bluetooth ? "On" : "Off",
                        icon: _connectionProvider.bluetooth
                            ? Icons.bluetooth_connected_rounded
                            : Icons.bluetooth_disabled_rounded,
                        value: _connectionProvider.bluetooth,
                        onPressed: () => _connectionProvider.bluetooth =
                            !_connectionProvider.bluetooth,
                      ),
                      QsToggleButton(
                        title: LocaleStrings.qs.airplanemode,
                        icon: !(!_connectionProvider.wifi &&
                                !_connectionProvider.bluetooth)
                            ? Icons.airplanemode_off_rounded
                            : Icons.airplanemode_active_rounded,
                        value: !(!_connectionProvider.wifi &&
                                !_connectionProvider.bluetooth)
                            ? false
                            : true,
                        onPressed: () {
                          if (_connectionProvider.wifi &&
                              _connectionProvider.bluetooth) {
                            _connectionProvider.wifi = false;
                            _connectionProvider.bluetooth = false;
                          } else if (_connectionProvider.wifi &&
                              !_connectionProvider.bluetooth) {
                            _connectionProvider.wifi = false;
                            _connectionProvider.bluetooth = false;
                          } else if (!_connectionProvider.wifi &&
                              _connectionProvider.bluetooth) {
                            _connectionProvider.wifi = false;
                            _connectionProvider.bluetooth = false;
                          } else {
                            _connectionProvider.wifi = true;
                            _connectionProvider.bluetooth = true;
                          }
                        },
                      ),
                      QsToggleButton(
                        title: LocaleStrings.settings.generalLanguage,
                        subtitle: LocaleStrings.qs.changelanguage,
                        icon: Icons.language_rounded,
                        value: true,
                        onPressed: () {
                          int index = Locales.supported.indexOf(context.locale);
                          if (index + 1 < Locales.supported.length) {
                            context.setLocale(Locales.supported[index + 1]);
                          } else {
                            context.setLocale(Locales.supported[0]);
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QsToggleButton(
                        title: LocaleStrings.qs.autorotate,
                        icon: Icons.screen_lock_rotation_rounded,
                        value: false,
                      ),
                      QsToggleButton(
                        title: LocaleStrings.qs.theme,
                        icon: Icons.palette_outlined,
                        value: true,
                      ),
                      QsToggleButton(
                        title: LocaleStrings.qs.dnd,
                        icon: Icons.do_not_disturb_off_rounded,
                        value: false,
                      ),
                      QsToggleButton(
                        title: "Night light",
                        icon: Icons.brightness_4_rounded,
                        value: false,
                      ),
                    ],
                  ),
                ],
              );
            }),
            _qsTitle("Shortcuts"),
            Row(
              children: [
                QsShortcutButton(
                  title: "New event",
                  icon: Icons.calendar_today_rounded,
                ),
                QsShortcutButton(
                  title: "Alpha Build",
                  icon: Icons.info_outline_rounded,
                ),
                QsShortcutButton(
                  title: "dahliaos.io",
                  icon: Icons.language_rounded,
                ),
                QsShortcutButton(),
              ],
            ),
            SizedBox(
              height: 12,
            ),
            Builder(
              builder: (context) {
                final _ioProvider = IOProvider.of(context);
                return Column(
                  children: [
                    QsSlider(
                      icon: _ioProvider.isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      onChanged: (val) {
                        _ioProvider.volume = val;
                      },
                      value: _ioProvider.volume,
                      steps: 20,
                      onIconTap: () =>
                          _ioProvider.isMuted = !_ioProvider.isMuted,
                    ),
                    QsSlider(
                      icon: _ioProvider.isAutoBrightnessEnabled
                          ? Icons.brightness_auto_rounded
                          : Icons.brightness_5_rounded,
                      onChanged: (val) {
                        _ioProvider.brightness = val;
                      },
                      value: _ioProvider.brightness,
                      steps: 10,
                      onIconTap: () => _ioProvider.isAutoBrightnessEnabled =
                          !_ioProvider.isAutoBrightnessEnabled,
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QsActionButton(
                  leading: Icon(Icons.calendar_today),
                  title: "27.10.2021 - 21:33",
                  margin: EdgeInsets.zero,
                ),
                QsActionButton(
                  leading: Icon(Icons.battery_charging_full),
                  title: "100% - fully charged",
                  margin: EdgeInsets.zero,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Padding _qsTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 16.0, 0.0, 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
