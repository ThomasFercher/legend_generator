import 'package:build/build.dart';
import 'package:legend_generator/src/copy/copy_generator.dart';
import 'package:legend_generator/src/style/style_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder styleClassGen(BuilderOptions options) =>
    SharedPartBuilder([StyleGenerator()], 'style_generator');

Builder copyClassGen(BuilderOptions options) =>
    SharedPartBuilder([CopyGenerator()], 'copy_generator');
