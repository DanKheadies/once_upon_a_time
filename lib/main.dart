import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_web_plugins/url_strategy.dart';
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

  // TODO: implement if (hosted) browser behaves weird, i.e. refreshing
  // usePathUrlStrategy();

  SystemChannels.textInput.invokeMethod('TextInput.hide');

  runApp(const OnceUponATime());
}

class OnceUponATime extends StatelessWidget {
  const OnceUponATime({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),
        RepositoryProvider<DatabaseRepository>(
          create: (_) => DatabaseRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(create: (_) => SettingsCubit()),
          BlocProvider(
            create: (context) => StoryBloc(
              databaseRepository: context.read<DatabaseRepository>(),
            ),
          ),
        ],
        child: OnceUponATimeApp(),
      ),
    );
  }
}
