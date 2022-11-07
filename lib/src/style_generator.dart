import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:legend_annotations/legend_annotations.dart';

import 'package:source_gen/source_gen.dart';

import 'model_visitor.dart';

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

    var classBuffer = StringBuffer();

    /// InfoNull
    ///

    classBuffer.writeln("abstract class $className{");

    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      type = type.contains('?') ? type : "$type?";
      // getter
      classBuffer.writeln("final $type $variable;");
    }

    // constructor
    classBuffer.writeln("const $className({");

    // assign variables to Map
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      if (type.contains('?')) {
        classBuffer.writeln("this.$variable,");
      } else {
        classBuffer.writeln("required this.$variable,");
      }
    }
    // constructor close
    classBuffer.writeln("});");

    // class ends here
    classBuffer.writeln("}");

    content.add(classBuffer.toString());
    classBuffer.clear();

    /// Not Null
    ///
    var className2 = "${visitor.className}Info";
    classBuffer.writeln("abstract class $className2 implements $className{");

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
      classBuffer.writeln("@override");
      classBuffer.writeln("final $type $variable;");
    }

    // constructor
    classBuffer.writeln("const $className2({");

    // assign variables to Map
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      if (type.contains('?') || nullable) {
        classBuffer.writeln("this.$variable,");
      } else {
        classBuffer.writeln("required this.$variable,");
      }
    }
    // constructor close
    classBuffer.writeln("});");

    // class ends here
    classBuffer.writeln("}");

    content.add(classBuffer.toString());
    classBuffer.clear();

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
      classBuffer.writeln("class $className7{");
      for (var comp in visitor.components.keys) {
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
        }
        type = "${type}InfoNull?";
        classBuffer.writeln("final $type $comp;");
      }
      classBuffer.write("$className7({");
      // assign variables to Map
      for (var comp in visitor.components.keys) {
        // remove '_' from private variables
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        classBuffer.writeln("this.$variable,");
      }
      // constructor close
      classBuffer.writeln("});");

      classBuffer.writeln("}");

      className5 = "${visitor.className}ComponentsOverride";
      classBuffer.writeln("class $className5 implements $className7{");
      for (var comp in visitor.components.keys) {
        // remove '_' from private variables
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
        }
        type = "${type}Override?";

        // getter
        classBuffer.writeln("@override");
        classBuffer.writeln("final $type $variable;");
      }
      if (visitor.components.keys.isNotEmpty) {
        classBuffer.write("$className5({");
        // assign variables to Map
        for (var comp in visitor.components.keys) {
          // remove '_' from private variables
          var variable =
              comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
          classBuffer.writeln("this.$variable,");
        }
        // constructor close
        classBuffer.writeln("});");
      }
      // class ends here
      classBuffer.writeln("}");
      content.add(classBuffer.toString());
      classBuffer.clear();

      //
      className6 = "${visitor.className}Components";
      classBuffer.writeln("class $className6 implements $className7{");
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
        classBuffer.writeln("@override");
        classBuffer.writeln("final $type $variable;");
      }
      if (visitor.components.keys.isNotEmpty) {
        classBuffer.write("$className6({");
        // assign variables to Map
        for (var comp in visitor.components.keys) {
          // remove '_' from private variables
          var variable =
              comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
          String type = visitor.components[comp].toString();
          if (type.contains('?')) {
            classBuffer.writeln("this.$variable,");
          } else {
            classBuffer.writeln("required this.$variable,");
          }
        }
        // constructor close
        classBuffer.writeln("});");
      }
      // class ends here
      classBuffer.writeln("}");
      content.add(classBuffer.toString());
      classBuffer.clear();
    }
    //

    /// Override
    ///

    var className3 = "${visitor.className}Override";
    classBuffer.writeln("class $className3 extends $className");
    if (visitor.components.isNotEmpty) {
      classBuffer.write("implements $className5");
    }
    classBuffer.write("{");
    if (visitor.components.isNotEmpty) {
      classBuffer.writeln(
          "final $className5 Function($className sizing)? buildComponents;");
      for (var comp in visitor.components.keys) {
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
        }
        type = "${type}Override";

        classBuffer.writeln("@override");
        classBuffer.writeln("late final $type? $variable;");
      }
    }

    // constructor
    classBuffer.writeln("$className3({");
    if (visitor.components.isNotEmpty) {
      classBuffer.writeln("this.buildComponents,");
    }
    // assign variables to Map
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      classBuffer.writeln("super.$variable,");
    }

    // constructor close
    classBuffer.writeln("})");
    if (visitor.components.isNotEmpty) {
      classBuffer.write("{");
      classBuffer
          .writeln("$className5? components = buildComponents?.call(this);");
      for (var comp in visitor.components.keys) {
        classBuffer.writeln("$comp = components?.$comp;");
      }
      classBuffer.writeln("}");
    } else {
      classBuffer.write(";");
    }

    // class ends here
    classBuffer.writeln("}");
    content.add(classBuffer.toString());
    classBuffer.clear();

    ///
    /// MainClass
    ///
    ///
    ///
    var className4 = "${visitor.className}Style";
    classBuffer.writeln("class $className4 extends $className2");
    if (visitor.components.isNotEmpty) {
      classBuffer.write("implements $className6");
    }
    classBuffer.write("{");

    if (visitor.components.isNotEmpty) {
      classBuffer.writeln(
          "final $className6 Function($className2 sizing) buildComponents;");

      for (var comp in visitor.components.keys) {
        var variable = comp.startsWith('_') ? comp.replaceFirst('_', '') : comp;
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
          type = "${type}Style?";
        } else {
          type = "${type}Style";
        }

        classBuffer.writeln("@override");
        classBuffer.writeln("late final $type $variable;");
      }
    }
    // constructor
    classBuffer.writeln("$className4({");
    if (visitor.components.isNotEmpty) {
      classBuffer.writeln("required this.buildComponents,");
    }
    // assign variables to Map
    for (var field in visitor.fields.keys) {
      // remove '_' from private variables
      var variable =
          field.startsWith('_') ? field.replaceFirst('_', '') : field;
      String type = visitor.fields[field].toString();
      if (type.contains('?')) {
        classBuffer.writeln("super.$variable,");
      } else {
        classBuffer.writeln("required super.$variable,");
      }
    }

    // constructor close
    classBuffer.writeln("})");
    if (visitor.components.isNotEmpty) {
      classBuffer.write("{");
      classBuffer
          .writeln("$className6 components = buildComponents.call(this);");
      for (var comp in visitor.components.keys) {
        classBuffer.writeln("$comp = components.$comp;");
      }
      classBuffer.writeln("}");
    } else {
      classBuffer.write(";");
    }

    classBuffer.writeln(
        "factory $className4.override($className4 def,$className3? override,){");
    classBuffer.writeln("if(override==null){return def;}");

    classBuffer.writeln("return $className4(");
    for (var field in visitor.fields.keys) {
      classBuffer.writeln("$field: override.$field ?? def.$field,");
    }
    if (visitor.components.isNotEmpty) {
      classBuffer.writeln("buildComponents: (_){return $className6(");
      bool isNullable = false;
      for (var comp in visitor.components.keys) {
        String type = visitor.components[comp].toString();
        if (type.contains("?")) {
          type = type.replaceAll("?", "");
          isNullable = true;
        }
        type = "${type}Style";

        if (isNullable) {
          classBuffer.writeln(
              "$comp: def.$comp == null ? null : $type.override(def.$comp!, override.$comp),");
        } else {
          classBuffer
              .writeln("$comp:  $type.override(def.$comp, override.$comp),");
        }
      }
      classBuffer.writeln(");},");
    }

    classBuffer.writeln(");");
    classBuffer.writeln("}");
    // class ends here
    classBuffer.writeln("}");
    content.add(classBuffer.toString());
    classBuffer.clear();

    return content;
  }
}
