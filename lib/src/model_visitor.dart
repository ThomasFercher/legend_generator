// ignore_for_file: depend_on_referenced_packages

import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

const legendSubStyleClass = '@LegendSubStyle()';
const legendSubStyle = '@legendSubStyle';

const legendSubStyleFieldClass = '@LegendSubStyleField()';
const legendSubStyleField = '@legendSubStyleField';

class ModelVisitor extends SimpleElementVisitor {
  String? className;

  Map<String, dynamic> fields = {};

  Map<String, dynamic> components = {};

  Map<String, dynamic> componentsFields = {};

  @override
  visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType.toString();

    className = className?.replaceAll('Style', '');
  }

  @override
  visitFieldElement(FieldElement element) {
    final isSubStyle = element.metadata.any(
      (annotation) =>
          annotation.toSource() == legendSubStyle ||
          annotation.toSource() == legendSubStyleClass,
    );

    final isSubStyleField = element.metadata.any(
      (annotation) =>
          annotation.toSource() == legendSubStyleField ||
          annotation.toSource() == legendSubStyleFieldClass,
    );

    final type = element.type.toString().replaceAll('Style', '');

    if (isSubStyle) {
      components[element.name] = type;
      return;
    }

    if (isSubStyleField) {
      componentsFields[element.name] = type;
      return;
    }

    fields[element.name] = type;
  }
}
