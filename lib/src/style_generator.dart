import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:legend_annotations/legend_annotations.dart';

import 'package:source_gen/source_gen.dart';

import 'model_visitor.dart';

String seperator(String name) =>
    "\n// **************************************************************************\n// $name\n// **************************************************************************\n";

class StyleGenerator extends GeneratorForAnnotation<LegendStyle> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generatedSource(element,
        annotation.objectValue.getField("nullable")?.toBoolValue() ?? false);
  }

  Iterable<String> _generatedSource(Element element, bool nullable) {
    List<String> content = [];
    var visitor = ModelVisitor();

    element.visitChildren(visitor);

    var className = "${visitor.className}InfoNull";

    var buffer = StringBuffer();

    /// InfoNull
    ///

    buffer.writeln("abstract class $className{");

    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      type = type.contains('?') ? type : "$type?";
      // getter
      buffer.writeln("final $type $variable;");
    }

    // constructor
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

    // class ends here
    buffer.writeln("}");

    content.add(buffer.toString());
    buffer.clear();

    /// Not Null
    ///
    var className2 = "${visitor.className}Info";
    buffer.writeln("abstract class $className2 implements $className{");

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

    // constructor
    buffer.writeln("const $className2({");

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

    // class ends here
    buffer.writeln("}");

    content.add(buffer.toString());
    buffer.clear();

    // class ends here

    ////
    ///
    /// Components
    ///
    var className7;
    var className5;
    var className6;

    if (visitor.components.isNotEmpty) {
      className7 = "${visitor.className}ComponentsInfo";
      buffer.writeln("class $className7{");
      for (var comp in visitor.components.keys) {
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
        }
        type = "${type}InfoNull?";
        buffer.writeln("final $type $comp;");
      }
      buffer.write("$className7({");
      // assign variables to Map
      for (var comp in visitor.components.keys) {
        // remove '_' from private variables
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        buffer.writeln("this.$variable,");
      }
      // constructor close
      buffer.writeln("});");

      buffer.writeln("}");

      className5 = "${visitor.className}ComponentsOverride";
      buffer.writeln("class $className5 implements $className7{");
      for (var comp in visitor.components.keys) {
        // remove '_' from private variables
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
        }
        type = "${type}Override?";

        // getter
        buffer.writeln("@override");
        buffer.writeln("final $type $variable;");
      }
      if (visitor.components.keys.isNotEmpty) {
        buffer.write("$className5({");
        // assign variables to Map
        for (var comp in visitor.components.keys) {
          // remove '_' from private variables
          var variable =
              comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
          buffer.writeln("this.$variable,");
        }
        // constructor close
        buffer.writeln("});");
      }
      // class ends here
      buffer.writeln("}");
      content.add(buffer.toString());
      buffer.clear();

      //
      className6 = "${visitor.className}Components";
      buffer.writeln("class $className6 implements $className7{");
      for (var comp in visitor.components.keys) {
        // remove '_' from private variables
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
          type = "${type}Style?";
        } else {
          type = "${type}Style";
        }

        // getter
        buffer.writeln("@override");
        buffer.writeln("final $type $variable;");
      }
      if (visitor.components.keys.isNotEmpty) {
        buffer.write("$className6({");
        // assign variables to Map
        for (var comp in visitor.components.keys) {
          // remove '_' from private variables
          var variable =
              comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
          String type = visitor.components[comp].toString();
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
      content.add(buffer.toString());
      buffer.clear();
    }
    //

    /// Override
    ///

    var className3 = "${visitor.className}Override";
    buffer.writeln("class $className3 extends $className");
    if (visitor.components.isNotEmpty) {
      buffer.write("implements $className5");
    }
    buffer.write("{");
    if (visitor.components.isNotEmpty) {
      buffer.writeln(
          "final $className5 Function($className sizing)? buildComponents;");
      for (var comp in visitor.components.keys) {
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
        }
        type = "${type}Override";

        buffer.writeln("@override");
        buffer.writeln("late final $type? $variable;");
      }
    }

    // constructor
    buffer.writeln("$className3({");
    if (visitor.components.isNotEmpty) {
      buffer.writeln("this.buildComponents,");
    }
    // assign variables to Map
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      buffer.writeln("super.$variable,");
    }

    // constructor close
    buffer.writeln("})");
    if (visitor.components.isNotEmpty) {
      buffer.write("{");
      buffer.writeln("$className5? components = buildComponents?.call(this);");
      for (var comp in visitor.components.keys) {
        buffer.writeln("$comp = components?.$comp;");
      }
      buffer.writeln("}");
    } else {
      buffer.write(";");
    }

    // class ends here
    buffer.writeln("}");
    content.add(buffer.toString());
    buffer.clear();

    ///
    /// MainClass
    ///
    ///
    ///
    var className4 = "${visitor.className}Style";
    buffer.writeln("class $className4 extends $className2");
    if (visitor.components.isNotEmpty) {
      buffer.write("implements $className6");
    }
    buffer.write("{");

    if (visitor.components.isNotEmpty) {
      for (var comp in visitor.components.keys) {
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
          type = "${type}Style?";
        } else {
          type = "${type}Style";
        }

        buffer.writeln("@override");
        buffer.writeln("late final $type $variable;");
      }
    }
    // constructor
    buffer.writeln("$className4({");
    if (visitor.components.isNotEmpty) {
      buffer.writeln(
          "required $className6 Function($className2 sizing) buildComponents,");
    }
    // assign variables to Map
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      if (type.contains('?')) {
        buffer.writeln("super.$variable,");
      } else {
        buffer.writeln("required super.$variable,");
      }
    }

    // constructor close
    buffer.writeln("})");
    if (visitor.components.isNotEmpty) {
      buffer.write("{");
      buffer.writeln("$className6 components = buildComponents.call(this);");
      for (var comp in visitor.components.keys) {
        buffer.writeln("$comp = components.$comp;");
      }
      buffer.writeln("}");
    } else {
      buffer.write(";");
    }

    // Second Constructor
    buffer.writeln("$className4.copy({");
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      if (type.contains('?')) {
        buffer.writeln("super.$variable,");
      } else {
        buffer.writeln("required super.$variable,");
      }
    }

    if (visitor.components.isNotEmpty) {
      for (var field in visitor.components.keys) {
        String type = visitor.components[field].toString();
        if (type.contains('?')) {
          buffer.writeln("this.$field,");
        } else {
          buffer.writeln("required this.$field,");
        }
      }
    }

    buffer.writeln("});");

    // Override Method
    buffer.write(seperator("Override"));

    buffer.writeln(
        "factory $className4.override($className4 def,$className3? override,){");
    buffer.writeln("if(override==null){return def;}");

    buffer.writeln("return $className4(");
    for (var field in visitor.fields.keys) {
      buffer.writeln("$field: override.$field ?? def.$field,");
    }
    if (visitor.components.isNotEmpty) {
      buffer.writeln("buildComponents: (_){return $className6(");
      bool isNullable = false;
      for (var comp in visitor.components.keys) {
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
          isNullable = true;
        }
        type = "${type}Style";

        if (isNullable) {
          buffer.writeln(
              "$comp: def.$comp == null ? null : $type.override(def.$comp!, override.$comp),");
        } else {
          buffer.writeln("$comp:  $type.override(def.$comp, override.$comp),");
        }
      }
      buffer.writeln(");},");
    }

    buffer.writeln(");");
    buffer.writeln("}");

    // Copy With Method
    buffer.write(seperator("Copy With"));
    buffer.write("$className4 copyWith({");
    // Vars
    for (var field in visitor.fields.keys) {
      var type = visitor.fields[field].toString();
      if (!type.contains('?')) {
        type += "?";
      }
      buffer.writeln("$type $field,");
    }
    // Components
    if (visitor.components.isNotEmpty) {
      for (var field in visitor.components.keys) {
        String type = visitor.components[field].toString();
        if (!type.contains('?')) {
          type += "Style?";
        } else {
          type = type.replaceAll("?", "Style?");
        }
        buffer.writeln("$type $field,");
      }
    }
    buffer.writeln("}){");

    buffer.writeln("return $className4.copy(");
    // Vars
    for (var field in visitor.fields.keys) {
      buffer.writeln("$field: $field ?? this.$field,");
    }
    // Components
    if (visitor.components.isNotEmpty) {
      for (var field in visitor.components.keys) {
        buffer.writeln("$field: $field ?? this.$field,");
      }
    }

    buffer.writeln(");");

    buffer.writeln("}");

    // class ends here
    buffer.writeln("}");
    content.add(buffer.toString());
    buffer.clear();

    return content;
  }
}
