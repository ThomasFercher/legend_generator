import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:legend_annotations/legend_annotations.dart';
import 'package:legend_generator/src/style/components.dart';
import 'package:legend_generator/src/style/style.dart';

import 'package:source_gen/source_gen.dart';

import '../model_visitor.dart';

String seperator(String name) =>
    "\n// **************************************************************************\n// $name\n// **************************************************************************\n";

class StyleGenerator extends GeneratorForAnnotation<LegendStyle> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final bool nullable =
        annotation.objectValue.getField("nullable")?.toBoolValue() ?? false;
    return _generatedSource(
      element,
      nullable,
    );
  }

  Iterable<String> _generatedSource(Element element, bool nullable) {
    List<String> content = [];
    var visitor = ModelVisitor();
    element.visitChildren(visitor);
    var buffer = StringBuffer();

    final generator = LegendStyleGenerator(
      buffer: buffer,
      visitor: visitor,
      nullable: nullable,
    );

    var class1 = generator.generateInfoNull();
    content.add(generator.content);

    var class2 = generator.generateInfo(class1);
    content.add(generator.content);

    String? className7;
    String? className5;
    String? className6;

    if (visitor.components.isNotEmpty || visitor.componentsFields.isNotEmpty) {
      final componetsGenerator = LegendComponentsGenerator(
        buffer: buffer,
        visitor: visitor,
        nullable: nullable,
      );

      className7 = componetsGenerator.generateComponentsInfo();
      content.add(componetsGenerator.content);

      className5 = componetsGenerator.generateComponentsOverride(className7);
      content.add(componetsGenerator.content);

      className6 = componetsGenerator.generateComponents(className7);
      content.add(componetsGenerator.content);
    }

    var class3 = generator.generateOverride(class1, className5);
    content.add(generator.content);

    generator.generateMainClass(class2, className6, class3);
    content.add(generator.content);

    return content;
  }
}
