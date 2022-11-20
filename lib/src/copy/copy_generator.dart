import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:legend_annotations/legend_annotations.dart';
import 'package:legend_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';

class CopyGenerator extends GeneratorForAnnotation<LegendCopy> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generatedSource(element);
  }

  Iterable<String> _generatedSource(Element element) {
    // Init
    final List<String> content = [];
    final StringBuffer buffer = StringBuffer();
    var visitor = ModelVisitor();
    element.visitChildren(visitor);

    /// Class
    copyWithMethod(buffer, visitor);
    copyWithMethod2(buffer, visitor);

    // Cleanup
    content.add(buffer.toString());
    buffer.clear();
    return content;
  }

  void copyWithMethod(StringBuffer buffer, ModelVisitor visitor) {
    final classname = visitor.className;

    buffer.write("$classname _\$copyWith({");
    buffer.writeln("required $classname instance,");
    for (final entry in visitor.fields.entries) {
      final field = entry.key;
      var type = entry.value.toString();
      if (!type.contains('?')) {
        type += '?';
      }
      buffer.writeln("$type $field,");
    }
    buffer.writeln("}){");

    buffer.writeln("return $classname(");

    for (final field in visitor.fields.keys) {
      buffer.writeln("$field: $field ?? instance.$field,");
    }

    buffer.writeln(");");

    buffer.writeln("}");
  }

  void copyWithMethod2(StringBuffer buffer, ModelVisitor visitor) {
    final classname = visitor.className;

    buffer.write("$classname _\$copyWithInstance({");
    buffer.writeln("required $classname instance,");
    buffer.writeln("$classname? copyInstance,");

    buffer.writeln("}){");

    buffer.writeln("return $classname(");

    for (final field in visitor.fields.keys) {
      buffer.writeln("$field: copyInstance?.$field ?? instance.$field,");
    }

    buffer.writeln(");");

    buffer.writeln("}");
  }
}
