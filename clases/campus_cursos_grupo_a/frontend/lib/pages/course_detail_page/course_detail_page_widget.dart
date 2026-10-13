import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/ui/widgets/campus_app_bar.dart';
import '/ui/widgets/campus_page_layout.dart';
import '/ui/widgets/course_sections.dart';
import 'package:flutter/material.dart';

import 'course_detail_page_model.dart';

import '/repositories/course_repository.dart';
import '/models/course.dart';

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

  final CourseRepository _courseRepository = CourseRepository();
  late Future<Course> _courseFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CourseDetailPageModel.new);

    _courseFuture = _loadCourse();
  }

  Future<Course> _loadCourse() async {
    if (widget.courseId != null) {
      return await _courseRepository.getCourse(widget.courseId!);
    } else {
      throw Exception('No se proporcionó un ID de curso válido.');
    }
  }

  void _reloadCourse() {
    setState(() {
      _courseFuture = _loadCourse();
    });
  }

  @override
  void dispose() {
    _courseRepository.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _editCourse() async {
    final id = widget.courseId;
    if(id == null || id <=0 ) return;

    await context.pushNamed(
      CourseFromPageWidget.routeName,
      queryParameters: {
        'courseId': serializeParam(id, ParamType.int),
      }.withoutNulls,
    );

    _reloadCourse();
  }

  Future<void> _deleteCourse(Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if(confirm != true) return;

    try {
      await _courseRepository.deleteCourse(course.id!);
      if(!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Curso eliminado exitosamente')),
      );
      
      context.pop();
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el curso: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: campusPageBackground,
        appBar: buildCampusAppBar(context, 'Cursos'),
        body: FutureBuilder<Course>(
          future: _courseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('Curso no encontrado.'));
            } else {
              final course = snapshot.data!;
              return CampusPageLayout(
                maxWidth: 800,
                children: [
                  CourseDetailCard(
                    course: course,
                    onEdit: _editCourse,
                    onDelete: () => _deleteCourse(course),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
