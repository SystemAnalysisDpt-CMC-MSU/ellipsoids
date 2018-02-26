package modgen.io;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.FileVisitOption;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static java.nio.file.StandardCopyOption.*;

public class FileUtils {
	public static void createDirectory(String dirName) throws IOException {
		Path newDirectoryPath = Paths.get(dirName);
		Files.createDirectory(newDirectoryPath);
	}

	public static String[] listDirsRecursive(String pathStr,String pattern,int maxDepth) {
		//
		final PathMatcher matcher = FileSystems.getDefault().getPathMatcher(pattern);
		Path path = Paths.get(pathStr);
		final List<String> files = new ArrayList<>();
		if (maxDepth==-1){
			maxDepth=Integer.MAX_VALUE;
		}		
		try {
			Files.walkFileTree(path, Collections.<FileVisitOption> emptySet(), maxDepth, 
					new SimpleFileVisitor<Path>() {
				@Override
				public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs)
						throws IOException {
					if (matcher.matches(dir)) {
						files.add(dir.toString());
					}
					return FileVisitResult.CONTINUE;
				}
			});
		} catch (IOException e) {
			e.printStackTrace();
		}
		return files.toArray(new String[files.size()]);
	}	
	
	
	public static String[] listFilesRecursive(String pathStr,String pattern,int maxDepth) {
		//
		final PathMatcher matcher = FileSystems.getDefault().getPathMatcher(pattern);
		Path path = Paths.get(pathStr);
		final List<String> files = new ArrayList<>();
		if (maxDepth==-1){
			maxDepth=Integer.MAX_VALUE;
		}		
		try {
			Files.walkFileTree(path, Collections.<FileVisitOption> emptySet(), maxDepth, 
					new SimpleFileVisitor<Path>() {
				@Override
				public FileVisitResult visitFile(Path file, BasicFileAttributes attrs)
						throws IOException {
					if (matcher.matches(file)) {
						files.add(file.toString());
					}
					return FileVisitResult.CONTINUE;
				}
			});
		} catch (IOException e) {
			e.printStackTrace();
		}
		return files.toArray(new String[files.size()]);
	}

	public static void createDirectoryRecursively(String dirName) throws IOException {
		Path newDirectoryPath = Paths.get(dirName);
		if (Files.exists(newDirectoryPath)) {
			throw new java.nio.file.FileAlreadyExistsException("directory " + dirName + 
					" already exists");
		}
		Files.createDirectories(newDirectoryPath);
	}

	public static void removeDirectory(String dirName) throws IOException {
		Path theDir = Paths.get(dirName);
		Files.delete(theDir);
	}

	public static void removeDirectoryRecursively(String dirName) throws IOException {
		Path directoryToDelete = Paths.get(dirName);
		if (Files.notExists(directoryToDelete)) {
			throw new java.nio.file.FileAlreadyExistsException("directory " + dirName +
					" doesn't exist");
		}
		DeletingFileVisitor delFileVisitor = new DeletingFileVisitor();
		Files.walkFileTree(directoryToDelete, delFileVisitor);
	}

	public static boolean isFile(String fileName) throws IOException {
		Path theFilePath = Paths.get(fileName);
		return Files.exists(theFilePath) && !Files.isDirectory(theFilePath);

	}

	public static boolean isDirectory(String fileName) throws IOException {
		Path theFilePath = Paths.get(fileName);
		return Files.exists(theFilePath) && Files.isDirectory(theFilePath);

	}

	public static void copyFile(String srcName, String dstName) throws IOException {
		Path theSrc = Paths.get(srcName);
		Path theDst = Paths.get(dstName);
		if (Files.isDirectory(theDst)) {
			theDst = theDst.resolve(theSrc.getFileName());
		}
		Files.copy(theSrc, theDst, REPLACE_EXISTING);
	}
}
