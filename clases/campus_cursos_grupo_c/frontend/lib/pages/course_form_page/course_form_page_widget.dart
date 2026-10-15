import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ui/widgets/course_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'course_form_page_model.dart';

import '/models/course.dart';
import '/repositories/course_repositorie.dart';

export 'course_form_page_model.dart';

class CourseFormPageWidget extends StatefulWidget {
  const CourseFormPageWidget({super.key, required this.courseId});

  final int? courseId;

  static String routeName = 'CourseFormPage';
  static String routePath = '/courseFormPage';

  @override
  State<CourseFormPageWidget> createState() => _CourseFormPageWidgetState();
}

class _CourseFormPageWidgetState extends State<CourseFormPageWidget> {
  late CourseFormPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final CourseRepositorie _repository = CourseRepositorie();
  bool _loadingCourse = false;
  bool get _isEditing{
    final courseId = widget.courseId;
    return courseId != null && courseId > 0;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CourseFormPageModel.new);
    _model.nameFieldTextController ??= TextEditingController();
    _model.nameFieldFocusNode ??= FocusNode();
    _model.descriptionFieldTextController ??= TextEditingController();
    _model.descriptionFieldFocusNode ??= FocusNode();
    _model.cacherFieldTextController ??= TextEditingController();
    _model.cacherFieldFocusNode ??= FocusNode();
    _model.semesterFieldTextController ??= TextEditingController();
    _model.semesterFieldFocusNode ??= FocusNode();

    if(_isEditing){
      _loadingCourse = true;
      _loadCourse();
    }
  }

  Future<void> _loadCourse() async {
    final courseId = widget.courseId;
    if(courseId == null || courseId <= 0){
      return;
    }

    try{
      final course = await _repository.getCourse(courseId);
      _model.nameFieldTextController!.text = course.name;
      _model.descriptionFieldTextController!.text = course.description;
      _model.cacherFieldTextController!.text = course.teacher;
      _model.semesterFieldTextController!.text = course.semester.toString();
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar el curso: $e',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          duration: const Duration(milliseconds: 4000),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
    }finally{
      setState(() {
        _loadingCourse = false;
      });
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
        MediaQuery.sizeOf(context).width < 600.0 ? 20.0 : 32.0;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Curso',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          elevation: 2.0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  child: Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Crear / editar curso',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    fontSize: 28.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 24.0),
                        CourseTextField(
                          controller: _model.nameFieldTextController,
                          focusNode: _model.nameFieldFocusNode,
                          label: 'Nombre del curso',
                          hint: 'Ej. Programación móvil',
                          validator: _model.nameFieldTextControllerValidator
                              ?.asValidator(context),
                        ),
                        const SizedBox(height: 16.0),
                        CourseTextField(
                          controller: _model.descriptionFieldTextController,
                          focusNode: _model.descriptionFieldFocusNode,
                          label: 'Descripcion',
                          hint: 'Ej. Escribe alguna descripcion',
                          maxLines: 4,
                          validator: _model
                              .descriptionFieldTextControllerValidator
                              ?.asValidator(context),
                        ),
                        const SizedBox(height: 16.0),
                        CourseTextField(
                          controller: _model.cacherFieldTextController,
                          focusNode: _model.cacherFieldFocusNode,
                          label: 'Profesor',
                          hint: 'Nombre completo',
                          validator: _model.cacherFieldTextControllerValidator
                              ?.asValidator(context),
                        ),
                        const SizedBox(height: 16.0),
                        CourseTextField(
                          controller: _model.semesterFieldTextController,
                          focusNode: _model.semesterFieldFocusNode,
                          label: 'Semestre',
                          hint: 'numero del semestre',
                          keyboardType: TextInputType.number,
                          validator: _model.semesterFieldTextControllerValidator
                              ?.asValidator(context),
                        ),
                        const SizedBox(height: 24.0),
                        Align(
                          alignment: Alignment.center,
                          child: FFButtonWidget(
                            onPressed: _saveCourse,
                            text: 'Guardar',
                            options: FFButtonOptions(
                              height: 44.0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              iconPadding: EdgeInsets.zero,
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    font: GoogleFonts.interTight(),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCourse() async {
    if (!_model.formKey.currentState!.validate()) {
      return;
    }

    final name = _model.nameFieldTextController!.text.trim();
    final description = _model.descriptionFieldTextController!.text.trim();
    final teacher = _model.cacherFieldTextController!.text.trim();
    final semester = int.tryParse(_model.semesterFieldTextController!.text);

    if (semester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semestre debe ser un número válido')),
      );
      return;
    }

    final course = Course(
      id: widget.courseId,
      name: name,
      description: description,
      teacher: teacher,
      semester: semester,
    );

    try {
      if (_isEditing) {
        await _repository.updateCourse(course);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Curso actualizado exitosamente')),
        );
      } else {
        await _repository.createCourse(course);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Curso creado exitosamente')),
        );
      }

      if(!mounted) return;

      context.pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el curso: $e')),
      );
    }
  }
}
