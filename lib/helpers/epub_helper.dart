import 'dart:io';

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

  Future<List<String>?> getFileContents(String epubPath) async {
    final containerPath = '$epubPath/META-INF/container.xml';

    // Read container.xml file
    final opfFilePath = await getOpfFilePath(containerPath);

    if (opfFilePath.isNotEmpty) {
      // Read package.opf file
      final opfFilePathAfterSplit = opfFilePath.contains('/') ? opfFilePath.split('/').first : '';

      final opfFile = File('$epubPath/$opfFilePath');
      final opfFileXml = XmlDocument.parse(await opfFile.readAsString());

      // Find the manifest element
      final manifestElement =
          opfFileXml.rootElement.findElements('manifest').first;

      // Find the spine element
      final spineElement = opfFileXml.rootElement.findElements('spine').first;

      // Get the idRef values in the spine element
      final idRefs = spineElement
          .findElements('itemref')
          .map((itemRef) => itemRef.getAttribute('idref'))
          .toList();

      // Retrieve the href values based on idRef
      final hrefs = idRefs.map((idRef) {
        final item = manifestElement.findElements('item').firstWhere((item) {
          return item.getAttribute('id') == idRef;
        });
        return "$epubPath/$opfFilePathAfterSplit/${item.getAttribute('href')}" ?? "";
      }).toList();

      return hrefs;
    }

    return null;
  }

  Future<String> getOpfFilePath(String containerPath) async {
    // Read container.xml file
    final containerFile = File(containerPath);
    final containerXml = XmlDocument.parse(await containerFile.readAsString());

    // Find the rootfile element
    final rootFileElement =
        containerXml.findAllElements('rootfile').firstOrNull;

    // Retrieve the full path of the .opf file
    final opfFilePath = rootFileElement?.getAttribute('full-path');

    debugPrint("OPF FILE PATH : $opfFilePath");

    return opfFilePath ?? "";
  }

  Future<List<String>> parseEPUB({String bookName = "alice.epub"}) async {

    Directory tempDir = await getFileDirectory();
    String fullPath = "${tempDir.path}/$bookName";

    ByteData assetData = await rootBundle.load("assets/book/$bookName");
    final buffer = assetData.buffer;
    await File(fullPath).writeAsBytes(
      buffer.asUint8List(assetData.offsetInBytes, assetData.lengthInBytes),
      flush: true,
    );

    final path = await unZip(bookName);
    debugPrint("PATH IS $path");
    // Find the content folder
    final files = await getFileContents(path);

    if (files != null) {
      debugPrint('The content folder is: ${files.toString()}');
      return files;
    } else {
      debugPrint('Unable to determine the content folder dynamically.');
      return [];
    }

  }
}
