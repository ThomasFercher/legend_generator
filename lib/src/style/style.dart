import 'package:legend_generator/src/model_visitor.dart';

import 'style_generator.dart';

class LegendStyleGenerator {
  final StringBuffer buffer;
  final ModelVisitor visitor;
  final bool nullable;

  bool get fieldsNotEmpty => visitor.fields.isNotEmpty;
  bool get componentsNotEmpty => visitor.components.isNotEmpty;
  bool get componentsFieldsNotEmpty => visitor.componentsFields.isNotEmpty;
  bool get isNotEmpty =>
      fieldsNotEmpty || componentsFieldsNotEmpty || componentsNotEmpty;

  const LegendStyleGenerator({
    required this.buffer,
    required this.visitor,
    required this.nullable,
  });

  String get content {
    final result = buffer.toString();
    buffer.clear();
    return result;
  }

  String generateInfoNull() {
    String className = "${visitor.className}InfoNull";

    buffer.writeln("abstract class $className{");

    for (var field in visitor.fields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      type = type.contains('?') ? type : "$type?";
      // getter
      buffer.writeln("final $type $variable;");
    }

    // constructor
    if (fieldsNotEmpty) {
      buffer.writeln("const $className({");
      // assign variables to Map
      for (var field in visitor.fields.keys) {
        // remove '_' from private variables
        var variable =
            field.startsWith('_') ? field.replaceFirst('_', '') : field;
        String type = visitor.fields[field].toString();
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

  String generateInfo(String implements) {
    /// Not Null
    String className = "${visitor.className}Info";
    buffer.writeln("abstract class $className implements $implements{");

    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      if (nullable) {
        type = "$type?";
      }
      print(type);

      // getter
      buffer.writeln("@override");
      buffer.writeln("final $type $variable;");
    }
    if (fieldsNotEmpty) {
      // constructor
      buffer.writeln("const $className({");

      // assign variables to Map
      for (var field in visitor.fields.keys) {
        // remove '_' from private variables
        var variable =
            field.startsWith('_') ? field.replaceFirst('_', '') : field;
        String type = visitor.fields[field].toString();
        if (type.contains('?') || nullable) {
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

  String generateOverride(String extend, String? implement) {
    bool genComponents = implement != null;

    /// Not Null
    ///

    String className = "${visitor.className}Override";
    buffer.writeln("class $className extends $extend");
    if (genComponents) {
      buffer.write("implements $implement");
    }
    buffer.write("{");

    if (genComponents) {
      if (componentsNotEmpty) {
        buffer.writeln(
          "final $implement Function($extend sizing)? buildComponents;",
        );
        for (var comp in visitor.components.keys) {
          var variable =
              comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
          String type = visitor.components[comp].toString();
          if (type.contains("?")) {
            type = type.replaceAll("?", "");
          }
          type = "${type}Override";

          buffer.writeln("@override");
          buffer.writeln("late final $type? $variable;");
        }
      }

      if (componentsFieldsNotEmpty) {
        for (var comp in visitor.componentsFields.keys) {
          var variable =
              comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
          String type = visitor.componentsFields[comp].toString();
          if (type.contains("?")) {
            type = type.replaceAll("?", "");
          }
          type = "${type}Override";

          buffer.writeln("@override");
          buffer.writeln("final $type? $variable;");
        }
      }
    }

    // constructor
    buffer.writeln("$className(");
    if (isNotEmpty) buffer.write("{");
    if (genComponents && componentsNotEmpty) {
      buffer.writeln("this.buildComponents,");
    }

    /// Fields
    for (var field in visitor.fields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      buffer.writeln("super.$variable,");
    }

    /// Component Fields
    for (var field in visitor.componentsFields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      buffer.writeln("this.$variable,");
    }
    if (isNotEmpty) buffer.write("}");
    // constructor close
    buffer.writeln(")");
    if (genComponents && componentsNotEmpty) {
      buffer.write("{");
      buffer.writeln("$implement? components = buildComponents?.call(this);");
      for (var comp in visitor.components.keys) {
        buffer.writeln("$comp = components?.$comp;");
      }
      buffer.writeln("}");
    } else {
      buffer.write(";");
    }

    // class ends here
    buffer.writeln("}");

    return className;
  }

  String generateMainClass(String extend, String? implement, String override) {
    bool genComponents = implement != null;

    String className = "${visitor.className}";
    buffer.writeln("class $className extends $extend");
    if (genComponents) {
      buffer.write("implements $implement");
    }
    buffer.write("{");

    if (genComponents) {
      if (componentsNotEmpty) {
        for (var comp in visitor.components.keys) {
          var variable =
              comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
          String type = visitor.components[comp].toString();
          if (type.contains("?")) {
            type = type.replaceAll("?", "");
            type = "$type?";
          }

          buffer.writeln("@override");
          buffer.writeln("late final $type $variable;");
        }
      }

      if (componentsFieldsNotEmpty) {
        for (var comp in visitor.componentsFields.keys) {
          var variable =
              comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
          String type = visitor.componentsFields[comp].toString();
          if (type.contains("?")) {
            type = type.replaceAll("?", "");
            type = "$type?";
          }

          buffer.writeln("@override");
          buffer.writeln("final $type $variable;");
        }
      }
    }

    // constructor
    buffer.writeln("$className(");
    if (isNotEmpty) buffer.write("{");
    if (genComponents && componentsNotEmpty) {
      buffer.writeln(
        "required $implement Function($extend sizing) buildComponents,",
      );
    }
    // Fields
    for (var field in visitor.fields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      if (type.contains('?') || nullable) {
        buffer.writeln("super.$variable,");
      } else {
        buffer.writeln("required super.$variable,");
      }
    }

    // Component Fields
    for (var field in visitor.componentsFields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.componentsFields[field].toString();
      if (type.contains('?') || nullable) {
        buffer.writeln("this.$variable,");
      } else {
        buffer.writeln("required this.$variable,");
      }
    }
    if (isNotEmpty) buffer.write("}");
    // constructor close
    buffer.writeln(")");
    if (genComponents && componentsNotEmpty) {
      buffer.write("{");
      buffer.writeln("$implement components = buildComponents.call(this);");
      for (var comp in visitor.components.keys) {
        buffer.writeln("$comp = components.$comp;");
      }
      buffer.writeln("}");
    } else {
      buffer.write(";");
    }

    // Second Constructor
    buffer.writeln("$className.copy(");
    if (isNotEmpty) buffer.write("{");
    // Fields
    for (var field in visitor.fields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      if (type.contains('?') || nullable) {
        buffer.writeln("super.$variable,");
      } else {
        buffer.writeln("required super.$variable,");
      }
    }

    // Component Fields
    for (var field in visitor.componentsFields.keys) {
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.componentsFields[field].toString();
      if (type.contains('?') || nullable) {
        buffer.writeln("this.$variable,");
      } else {
        buffer.writeln("required this.$variable,");
      }
    }

    if (genComponents) {
      for (var field in visitor.components.keys) {
        String type = visitor.components[field].toString();
        if (type.contains('?')) {
          buffer.writeln("this.$field,");
        } else {
          buffer.writeln("required this.$field,");
        }
      }
    }
    if (isNotEmpty) buffer.write("}");
    buffer.writeln(");");

    // Override Method
    buffer.write(seperator("Override"));

    buffer.writeln(
        "factory $className.override($className def,$override? override,){");
    buffer.writeln("if(override==null){return def;}");

    buffer.writeln("return $className(");
    for (var field in visitor.fields.keys) {
      buffer.writeln("$field: override.$field ?? def.$field,");
    }

    if (genComponents) {
      if (componentsNotEmpty) {
        buffer.writeln("buildComponents: (_){return $implement(");
        bool isNullable = false;
        for (var comp in visitor.components.keys) {
          String type = visitor.components[comp].toString();
          if (type.contains("?")) {
            type = type.replaceAll("?", "");
            isNullable = true;
          }

          if (isNullable) {
            buffer.writeln(
                "$comp: def.$comp == null ? null : $type.override(def.$comp!, override.$comp),");
          } else {
            buffer
                .writeln("$comp:  $type.override(def.$comp, override.$comp),");
          }
        }
        buffer.writeln(");},");
      }

      if (componentsFieldsNotEmpty) {
        for (var field in visitor.componentsFields.keys) {
          String type = visitor.componentsFields[field].toString();

          if (type.contains('?')) {
            type = type.replaceAll("?", "");
            buffer.writeln(
                "$field: def.$field != null ?  $type.override(def.$field!,override.$field,) : null,");
          } else {
            buffer.writeln(
                "$field: $type.override(def.$field,override.$field,),");
          }
        }
      }
    }

    buffer.writeln(");");
    buffer.writeln("}");

    // Copy With Method
    buffer.write(seperator("Copy With"));
    buffer.write("$className copyWith(");
    if (isNotEmpty) buffer.write("{");

    // Vars
    for (var field in visitor.fields.keys) {
      var type = visitor.fields[field].toString();
      if (!type.contains('?')) {
        type += "?";
      }
      buffer.writeln("$type $field,");
    }
    // Components
    if (componentsNotEmpty) {
      for (var field in visitor.components.keys) {
        String type = visitor.components[field].toString();
        if (!type.contains('?')) {
          type += "?";
        }
        buffer.writeln("$type $field,");
      }
    }
    if (componentsFieldsNotEmpty) {
      for (var field in visitor.componentsFields.keys) {
        String type = visitor.componentsFields[field].toString();
        if (!type.contains('?')) {
          type += "?";
        }
        buffer.writeln("$type $field,");
      }
    }
    if (isNotEmpty) buffer.write("}");
    buffer.writeln("){");

    buffer.writeln("return $className.copy(");
    // Vars
    for (var field in visitor.fields.keys) {
      buffer.writeln("$field: $field ?? this.$field,");
    }
    // Components
    if (componentsNotEmpty) {
      for (var field in visitor.components.keys) {
        buffer.writeln("$field: $field ?? this.$field,");
      }
    }
    // Components Fields
    if (componentsFieldsNotEmpty) {
      for (var field in visitor.componentsFields.keys) {
        buffer.writeln("$field: $field ?? this.$field,");
      }
    }

    buffer.writeln(");");

    buffer.writeln("}");

    buffer.writeln("}");

    return className;
  }
}
