import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/features/guide/presentation/view_model/guide_viewmodel.dart';
import '../../data/datasources/remote/guide_remote_datasource.dart';


// Provider for remote datasource
final guideRemoteDatasourceProvider =
    Provider<GuideRemoteDatasource>((ref) => GuideRemoteDatasource());

// Provider for GuideViewModel
final guideViewModelProvider =
    ChangeNotifierProvider<GuideViewModel>((ref) => GuideViewModel(ref));
