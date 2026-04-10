import 'snippet.dart';

class DetailResult {
  final bool deleted;
  final Snippet? updated;

  const DetailResult({this.deleted = false, this.updated});
}
