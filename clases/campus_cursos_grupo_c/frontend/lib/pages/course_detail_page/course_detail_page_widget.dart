import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'course_detail_page_model.dart';

import '/models/course.dart';
import '/repositories/course_repositorie.dart';

export 'course_detail_page_model.dart';

class CourseDetailPageWidget extends StatefulWidget {
  const CourseDetailPageWidget({super.key, required this.courseId});

  final int? courseId;

  static String routeName = 'CourseDetailPage';
  static String routePath = '/courseDetailPage';

  @override
  State<CourseDetailPageWidget> createState() => _CourseDetailPageWidgetState();
}

class _CourseDetailPageWidgetState extends State<CourseDetailPageWidget> {
  late CourseDetailPageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final CourseRepositorie _repository = CourseRepositorie();

  late Future<Course> _courseFuture;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, CourseDetailPageModel.new);

    _courseFuture = _loadCourses();
  }

  Future<Course> _loadCourses(){
    final courseId = widget.courseId;
    if(courseId == null || courseId <= 0){
      return Future.error('No se recibio un curso');
    }

    return _repository.getCourse(courseId);
  }

  void _reloadCourses(){
    setState(() {
      _courseFuture = _loadCourses();
    });
  }

  @override
  void dispose() {
    _repository.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

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
            'Detalle del curso',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          elevation: 2.0,
        ),
        body: FutureBuilder<Course>(
          future: _courseFuture,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if(snapshot.hasError){
              return Center(
                child: Text('Error al cargar el curso: ${snapshot.error}'),
              );
            }

            final course = snapshot.data!;
            return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width < 600.0 ? 20.0 : 40.0,
              vertical: 24.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 50.0,
                      ),
                      const SizedBox(height: 14.0),
                      Text(
                        'Programacion móvil',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                              fontSize: width < 600.0 ? 22.0 : 26.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 14.0),
                      Text(
                        'Desarrollo de aplicacion multiplataforma con Flutter y Dart',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              fontSize: width < 600.0 ? 16.0 : 18.0,
                              letterSpacing: 0.0,
                              lineHeight: 1.4,
                            ),
                      ),
                      const SizedBox(height: 14.0),
                      Divider(
                        thickness: 2.0,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      const SizedBox(height: 14.0),
                      Text(
                        'Profesor: Irving Cardona',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              fontSize: width < 600.0 ? 14.0 : 16.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 14.0),
                      Text(
                        'Semestre:  7',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.inter(),
                              fontSize: width < 600.0 ? 14.0 : 16.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 20.0),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: [
                          _DetailActionButton(
                            label: 'Editar',
                            icon: Icons.edit,
                            onPressed: _editCourse,
                          ),
                          _DetailActionButton(
                            label: 'Eliminar',
                            icon: Icons.delete,
                            onPressed: (){
                              _deleteCourse(course);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
          },
        ),
      ),
    );
  }

  Future<void> _editCourse() async{
    final id = widget.courseId;
    if(id == null || id <= 0) return;

    await context.pushNamed(
      CourseFormPageWidget.routeName,
      queryParameters: {
        'courseId': serializeParam(id, ParamType.int),
      }.withoutNulls,
    );

    if(!mounted){
      return;
    }

    _reloadCourses();
  }

  Future<void> _deleteCourse(Course course) async{
    final confirm = await showDialog<bool>(context: context, 
    builder: (dialogContext){
      return AlertDialog(
        title: const Text('Eliminar curso'),
        content: Text('Deseas eliminar "${course.name}"'),

        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(
                dialogContext,
                false,
              );
            }, 
            child: const Text('Cancelar')
          ),

          FilledButton(
            onPressed: (){
              Navigator.pop(dialogContext,true);
            }, 
            child: const Text('Eliminar')
          )
        ],
      );
    }
    );

    if(confirm != true){
      return;
    }

    try{
      await _repository.deleteCourse(course.id!);
      if(!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('curso eliminado...'))
      );

      context.pop();
    }catch(e){
      print(e.toString());
    }
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FFButtonWidget(
      onPressed: onPressed,
      text: label,
      icon: Icon(icon, size: 20.0),
      options: FFButtonOptions(
        width: 150.0,
        height: 48.0,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        iconPadding: EdgeInsets.zero,
        color: FlutterFlowTheme.of(context).primary,
        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
              font: GoogleFonts.interTight(),
              color: Colors.white,
              fontSize: 18.0,
              letterSpacing: 0.0,
            ),
        elevation: 0.0,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
