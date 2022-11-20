import 'package:legend_generator/src/model_visitor.dart';

class LegendComponentsGenerator {
  final StringBuffer buffer;
  final ModelVisitor visitor;
  final bool nullable;

  const LegendComponentsGenerator({
    required this.buffer,
    required this.visitor,
    required this.nullable,
  });

  bool get componentsNotEmpty => visitor.components.isNotEmpty;

  bool get componentsFieldsNotEmpty => visitor.componentsFields.isNotEmpty;

  Map<String, dynamic> get components => {
        ...visitor.components,
        ...visitor.componentsFields,
      };

  String get content {
    final result = buffer.toString();
    buffer.clear();
    return result;
  }

  String generateComponentsInfo() {
    String className = "${visitor.className}ComponentsInfo";
    buffer.writeln("class $className{");
    for (var comp in components.keys) {
      String type = components[comp].toString();
      if (type.contains("?")) {
        type = type.replaceAll("?", "");
      }
      type = "${type}InfoNull?";
      buffer.writeln("final $type $comp;");
    }
    buffer.write("$className({");
    // assign variables to Map
    for (var comp in components.keys) {
      // remove '_' from private variables
      var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
      buffer.writeln("this.$variable,");
    }
    // constructor close
    buffer.writeln("});");

    buffer.writeln("}");

    return className;
  }

  String generateComponentsOverride(
    String implements,
  ) {
    String className = "${visitor.className}ComponentsOverride";
    buffer.writeln("class $className implements $implements{");
    for (var comp in components.keys) {
      // remove '_' from private variables
      var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
      String type = components[comp].toString();
      if (type.contains("?")) {
        type = type.replaceAll("?", "");
      }
      type = "${type}Override?";

      // getter
      buffer.writeln("@override");
      buffer.writeln("final $type $variable;");
    }
    if (components.keys.isNotEmpty) {
      buffer.write("$className({");
      // assign variables to Map
      for (var comp in components.keys) {
        // remove '_' from private variables
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        buffer.writeln("this.$variable,");
      }
      // constructor close
      buffer.writeln("});");
    }
    // class ends here
    buffer.writeln("}");

    return className;
  }

  String generateComponents(
    String implements,
  ) {
    String className = "${visitor.className}Components";
    buffer.writeln("class $className implements $implements{");
    for (var comp in components.keys) {
      // remove '_' from private variables
      var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
      String type = components[comp].toString();
      if (type.contains("?")) {
        type = type.replaceAll("?", "");
        type = "$type?";
      } else {
        type = type;
      }

      // getter
      buffer.writeln("@override");
      buffer.writeln("final $type $variable;");
    }
    if (components.keys.isNotEmpty) {
      buffer.write("$className({");
      // assign variables to Map
      for (var comp in components.keys) {
        // remove '_' from private variables
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        String type = components[comp].toString();
        if (type.contains('?')) {
          buffer.writeln("this.$variable,");
        } else {
          buffer.writeln("required this.$variable,");
        }
      }
      // constructor close
      buffer.writeln("});");
    }
    // class ends here
    buffer.writeln("}");

    return className;
  }
}
