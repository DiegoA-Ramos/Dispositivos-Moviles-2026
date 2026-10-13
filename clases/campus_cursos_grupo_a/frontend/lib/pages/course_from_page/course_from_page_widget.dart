import 'package:campus_cursos_grupo_a/models/course.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/ui/widgets/campus_app_bar.dart';
import '/ui/widgets/campus_page_layout.dart';
import '/ui/widgets/course_form_section.dart';
import 'package:flutter/material.dart';

import '../../repositories/course_repository.dart';

import 'course_from_page_model.dart';
export 'course_from_page_model.dart';

class CourseFromPageWidget extends StatefulWidget {
  const CourseFromPageWidget({
    super.key,
    required this.courseId,
  });

  final int? courseId;

  static String routeName = 'CourseFromPage';
  static String routePath = '/courseFromPage';

  @override
  State<CourseFromPageWidget> createState() => _CourseFromPageWidgetState();
}

class _CourseFromPageWidgetState extends State<CourseFromPageWidget> {
  late CourseFromPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final CourseRepository _courseRepository = CourseRepository();

  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEditing{
    final id = widget.courseId;
    return id != null && id > 0;
  }

  String? _nameFieldTextControllerValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el nombre del curso.';
    }
    return null;
  }

  String? _descriptionFieldTextControllerValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la descripción del curso.';
    }
    return null;
  }

  String? _teacherFieldTextControllerValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el nombre del profesor.';
    }
    return null;
  }

  String? _semesterFieldTextControllerValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el semestre del curso.';
    }
    return null;
  }


  @override
  void initState() {
    super.initState();
    _model = createModel(context, CourseFromPageModel.new);
    _model.nameFieldTextController ??= TextEditingController();
    _model.nameFieldFocusNode ??= FocusNode();
    _model.descriptionFieldTextController ??= TextEditingController();
    _model.descriptionFieldFocusNode ??= FocusNode();
    _model.teacherFieldTextController ??= TextEditingController();
    _model.teacherFieldFocusNode ??= FocusNode();
    _model.semesterFieldTextController ??= TextEditingController();
    _model.semesterFieldFocusNode ??= FocusNode();

    if(_isEditing){
      _isLoading = true;
      _loadCourse();
    }
  }

  

  Future<void> _loadCourse() async {
    final id = widget.courseId;
    if (id == null || id <= 0) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final course = await _courseRepository.getCourse(id);
      _model.nameFieldTextController?.text = course.name;
      _model.descriptionFieldTextController?.text = course.description;
      _model.teacherFieldTextController?.text = course.teacher;
      _model.semesterFieldTextController?.text = course.semester.toString();
    } catch (e) {
      // Manejar el error, por ejemplo, mostrando un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el curso: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCourse() async{
    if(_isSaving) return;

    if(_model.formKey.currentState == null || !_model.formKey.currentState!.validate()){
      return;
    }

    final course = Course(
      id: _isEditing ? widget.courseId : null,
      name: _model.nameFieldTextController!.text.trim(), 
      description: _model.descriptionFieldTextController!.text.trim(), 
      teacher: _model.teacherFieldTextController!.text.trim(), 
      semester: _model.semesterFieldTextController!.text.trim()
    );

    setState(() {
      _isSaving = true;
    });

    try {
      if(_isEditing){
        await _courseRepository.updateCourse(course);
      } else {
        await _courseRepository.createCourse(course);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Curso guardado exitosamente')),
      );
      context.pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el curso: $e')),
      );
    } finally {
      if(mounted){
        setState(() {
        _isSaving = false;
      });
      }
    }
  }

  @override
  void dispose() {
    _courseRepository.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: campusPageBackground,
        appBar: buildCampusAppBar(context, 'Formulario'),
        body: 
          _isLoading ? const Center(
            child: CircularProgressIndicator() ,) : CampusPageLayout(
          maxWidth: 760,
          children: [
            CourseFormSection(
              formKey: _model.formKey,
              nameController: _model.nameFieldTextController!,
              nameFocusNode: _model.nameFieldFocusNode!,
              nameValidator:
                  _model.nameFieldTextControllerValidator.asValidator(context),
              
              descriptionController: _model.descriptionFieldTextController!,
              descriptionFocusNode: _model.descriptionFieldFocusNode!,
              descriptionValidator: _model
                  .descriptionFieldTextControllerValidator
                  .asValidator(context),
              teacherController: _model.teacherFieldTextController!,
              teacherFocusNode: _model.teacherFieldFocusNode!,
              teacherValidator: _model.teacherFieldTextControllerValidator
                  .asValidator(context),
              semesterController: _model.semesterFieldTextController!,
              semesterFocusNode: _model.semesterFieldFocusNode!,
              semesterValidator: _model.semesterFieldTextControllerValidator
                  .asValidator(context),
              onSave: _saveCourse,
            ),
          ],
        )
      ),
    );
  }
}
