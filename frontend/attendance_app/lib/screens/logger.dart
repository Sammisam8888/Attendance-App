import 'package:logging/logging.dart';

final Logger logger = Logger('AttendanceApp');

void setupLogger() {
  logger.level = Level.ALL;
  logger.onRecord.listen((record) {
    logger.log(record.level, '${record.level.name}: ${record.time}: ${record.message}');
  });
}
