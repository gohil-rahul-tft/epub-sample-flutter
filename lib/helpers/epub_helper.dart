import 'dart:io';
import 'dart:typed_data';

import 'package:epub_parser/epub_parser.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';

class EpubHelper {
  void parseEPUB() async {
    const fileName = "table.epub";

    Directory tempDir = await getApplicationSupportDirectory();
    String fullPath = "${tempDir.path}/$fileName";

    ByteData assetData = await rootBundle.load("assets/book/$fileName");
    final buffer = assetData.buffer;
    File file = await File(fullPath).writeAsBytes(buffer.asUint8List(
      assetData.offsetInBytes,
      assetData.lengthInBytes,
    ));

    List<int> bytes = await file.readAsBytes();
    // print("bytes : ${bytes.toString()}");

    // Opens a book and reads all of its content into memory
    EpubBook epubBook = await EpubReader.readBook(bytes);
    print("epubBook : ${epubBook.toString()}");

    // COMMON PROPERTIES

    // Book's title
    String? title = epubBook.Title;
    print("title : ${title.toString()}");

    // Book's authors (comma separated list)
    String? author = epubBook.Author;
    print("author : ${author.toString()}");

    // Book's authors (list of authors names)
    List<String?>? authors = epubBook.AuthorList;
    print("authors : ${authors.toString()}");

    // Book's cover image (null if there is no cover)
    Uint8List? coverImage = epubBook.CoverImage;
    print("coverImage: ${coverImage.toString()}");

    // CHAPTERS

    // Enumerating chapters
    epubBook.Chapters?.forEach((EpubChapter chapter) {
      // Title of chapter
      String? chapterTitle = chapter.Title;
      print("chapterTitle: ${chapterTitle.toString()}");

      // HTML content of current chapter
      String? chapterHtmlContent = chapter.HtmlContent;
      print("chapterHtmlContent: ${chapterHtmlContent.toString()}");

      // Nested chapters
      List<EpubChapter>? subChapters = chapter.SubChapters;
      print("subChapters: ${subChapters.toString()}");
    });

    // CONTENT

    // Book's content (HTML files, stylesheets, images, fonts, etc.)
    EpubContent? bookContent = epubBook.Content;
    print("bookContent: ${bookContent.toString()}");

    // IMAGES

    // All images in the book (file name is the key)
    Map<String, EpubByteContentFile>? images = bookContent?.Images;

    EpubByteContentFile? firstImage = images?.values.first;

    // Content type (e.g. EpubContentType.IMAGE_JPEG, EpubContentType.IMAGE_PNG)
    EpubContentType? contentType = firstImage?.ContentType;

    // MIME type (e.g. "image/jpeg", "image/png")
    String? mimeContentType = firstImage?.ContentMimeType;

    // HTML & CSS

    // All XHTML files in the book (file name is the key)
    Map<String, EpubTextContentFile>? htmlFiles = bookContent?.Html;
    print("htmlFiles: ${htmlFiles.toString()}");

    // All CSS files in the book (file name is the key)
    Map<String, EpubTextContentFile>? cssFiles = bookContent?.Css;
    print("cssFiles: ${cssFiles.toString()}");

    // Entire HTML content of the book
    htmlFiles?.values.forEach((EpubTextContentFile htmlFile) {
      String? htmlContent = htmlFile.Content;
      print("htmlContent: ${htmlContent.toString()}");
    });

    // All CSS content in the book
    cssFiles?.values.forEach((EpubTextContentFile cssFile) {
      String? cssContent = cssFile.Content;
      print("cssContent: ${cssContent.toString()}");
    });

    // OTHER CONTENT

    // All fonts in the book (file name is the key)
    Map<String, EpubByteContentFile>? fonts = bookContent?.Fonts;
    print("fonts: ${fonts.toString()}");

    // All files in the book (including HTML, CSS, images, fonts, and other types of files)
    Map<String, EpubContentFile>? allFiles = bookContent?.AllFiles;
    print("allFiles: ${allFiles.toString()}");

  }
}
