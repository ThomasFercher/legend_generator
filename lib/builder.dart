import 'package:build/build.dart';
import 'package:legend_generator/src/subSizing_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder styleClassGen(BuilderOptions options) =>
    SharedPartBuilder([SubSizingGenerator()], 'style_generator');
