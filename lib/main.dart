import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:once_upon_a_time/barrel.dart';
import 'package:once_upon_a_time/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Bloc.observer = SimpleBlocObserver();

  SystemChannels.textInput.invokeMethod('TextInput.hide');

  runApp(const OnceUponATime());
}

class OnceUponATime extends StatelessWidget {
  const OnceUponATime({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => SettingsCubit())],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: goRouter,
            // theme: state == Brightness.dark ? darkTheme() : lightTheme(),
            theme: darkTheme(),
          );
        },
      ),
    );
  }
}
