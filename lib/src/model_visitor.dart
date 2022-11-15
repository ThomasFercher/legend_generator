import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class ModelVisitor extends SimpleElementVisitor {
  DartType? className;

  Map<String, dynamic> fields = {};

  Map<String, dynamic> components = {};

  @override
  visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType;
  }

  @override
  visitFieldElement(FieldElement element) {
    if (element.isLate) {
      components[element.name] = element.type;
    } else {
      fields[element.name] = element.type;
    }
  }
}
