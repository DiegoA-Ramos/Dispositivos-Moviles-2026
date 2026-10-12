import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/ui/widgets/campus_app_bar.dart';
import '/ui/widgets/course_detail_card.dart';
import '/ui/widgets/responsive_page_section.dart';
import 'course_detail_page_model.dart';

import '/models/course.dart';
import '/repositories/course_repository.dart';

export 'course_detail_page_model.dart';

class CourseDetailPageWidget extends StatefulWidget {
  const CourseDetailPageWidget({
    super.key,
    required this.courseId,
  });

  final int? courseId;

  static String routeName = 'CourseDetailPage';
  static String routePath = '/courseDetailPage';

  @override
  State<CourseDetailPageWidget> createState() => _CourseDetailPageWidgetState();
}

class _CourseDetailPageWidgetState extends State<CourseDetailPageWidget> {
  late CourseDetailPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final CourseRepository _repository = CourseRepository();
  late Future<Course> _courseFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CourseDetailPageModel.new);
    _courseFuture = _loadCourses();
  }

  Future<Course> _loadCourses() {
    final id = widget.courseId;
    if (id == null || id <= 0) {
      throw Exception('Invalid course ID');
    }
    return _repository.getCourse(id);
  }

  void _reloadCourses() {
    setState(() {
      _courseFuture = _loadCourses();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();

    _repository.dispose();
  }

  Future<void> _editCourse() async {
    final id = widget.courseId;
    if (id == null || id <= 0) {
      throw Exception('Invalid course ID');
      return;
    }
    await context.pushNamed(
      CourseFormPageWidget.routeName,
      queryParameters: {
        'courseId': serializeParam(id, ParamType.int),
      }.withoutNulls,
    );

    if (!mounted) return;
    _reloadCourses();
  }

  void _showDeletingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Eliminando...',
          style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
        ),
        duration: const Duration(milliseconds: 4000),
        backgroundColor: FlutterFlowTheme.of(context).secondary,
      ),
    );
  }

  Future<void> _deleteCourse(Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este curso?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _repository.deleteCourse(course.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Curso eliminado exitosamente.',
            style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
          ),
          duration: const Duration(milliseconds: 4000),
          backgroundColor: FlutterFlowTheme.of(context).secondary,
        ),
      );
      context.pop();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: const CampusAppBar(title: 'Cursos'),
        body: SafeArea(
          top: true,
          child: FutureBuilder<Course>(
            future: _courseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Text(
                    'No se encontró el curso.',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                );
              } else {
                final course = snapshot.data!;
                return ResponsivePageSection(
                  child: CourseDetailCard(
                    course: course,
                    onEdit: _editCourse,
                    onDelete: () {
                      _deleteCourse(course);
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
