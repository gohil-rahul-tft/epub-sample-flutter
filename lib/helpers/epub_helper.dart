import 'dart:io';
import 'dart:typed_data';

import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

class EpubHelper {
  final _extractDir = "extract_epub";

  Future<Directory> getFileDirectory() {
    return getApplicationSupportDirectory();
  }

  Future<String> fileExtractDirectory() async {
    final cacheDir = await getFileDirectory();
    return "${cacheDir.path}/$_extractDir";
  }

  Future<String> unZip(String epubFileName) async {
    debugPrint(epubFileName);

    final fileDir = await getFileDirectory();
    final zipFile = File("${fileDir.path}/$epubFileName");

    String extractFolder = await fileExtractDirectory();

    var directory = Directory(extractFolder);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }

    directory = await Directory(extractFolder).create(recursive: true);
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile, destinationDir: directory);
    } catch (e) {
      debugPrint("$e");
    }
    return extractFolder;
  }

  Future<String?> findContentFolder(String epubPath) async {
    final containerPath = '$epubPath/META-INF/container.xml';

    // Read container.xml file
    final containerFile = File(containerPath);
    final containerXml = XmlDocument.parse(await containerFile.readAsString());
    final rootFiles = containerXml.findAllElements('rootfile');

    if (rootFiles.isNotEmpty) {
      final rootFile = rootFiles.first;
      final packagePath = rootFile.getAttribute('full-path');

      // Read package.opf file
      final packageFile = File('$epubPath/$packagePath');
      final packageXml = XmlDocument.parse(await packageFile.readAsString());
      final manifest = packageXml.findAllElements('manifest');

      if (manifest.isNotEmpty) {
        final manifestElem = manifest.first;
        String? contentFolder;

        for (var item in manifestElem.children) {
          final id = item.getAttribute('id');
          final href = item.getAttribute('href');
          final mediaType = item.getAttribute('media-type');

          debugPrint("ID: $id - href: $href - mediaType: $mediaType");

          if (href != null) {
            final folder = Uri.parse(href).pathSegments[0];

            debugPrint("CONTENT FOLDER: $folder");

            // Store the content folder path in a variable
            contentFolder = folder;
          }
        }

        return contentFolder;
      }
    }

    return null;
  }

  Future<String?> getOpfFilePath(String epubPath) async {
    final containerPath = '$epubPath/META-INF/container.xml';

    // Read container.xml file
    final containerFile = File(containerPath);
    final containerXml = XmlDocument.parse(await containerFile.readAsString());

    // Find the rootfile element
    final rootfileElement = containerXml.findElements('rootfile').first;

    // Retrieve the full path of the .opf file
    final opfFilePath = rootfileElement.getAttribute('full-path');

    debugPrint("OPF FILE PATH : $opfFilePath");

    return opfFilePath;
  }

  void parseEPUB() async {
    const fileName = "urdu_sample.epub";

    Directory tempDir = await getFileDirectory();
    String fullPath = "${tempDir.path}/$fileName";

    ByteData assetData = await rootBundle.load("assets/book/$fileName");
    final buffer = assetData.buffer;
    File file = await File(fullPath).writeAsBytes(
      buffer.asUint8List(assetData.offsetInBytes, assetData.lengthInBytes),
      flush: true,
    );

    final path = await unZip(fileName);
    debugPrint("PATH IS $path");
    // Find the content folder
    final contentFolder = await findContentFolder(path);

    if (contentFolder != null) {
      debugPrint('The content folder is: $contentFolder');
    } else {
      debugPrint('Unable to determine the content folder dynamically.');
    }
    return;
  }
}
