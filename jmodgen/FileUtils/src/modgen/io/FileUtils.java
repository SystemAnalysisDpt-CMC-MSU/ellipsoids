package modgen.io;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import static java.nio.file.StandardCopyOption.*;

public class FileUtils {
	public static void createDirectory(String dirName) throws IOException {
		Path newDirectoryPath = Paths.get(dirName);
		Files.createDirectory(newDirectoryPath);
	}
	public static void createDirectoryRecursively(String dirName) throws IOException {
		Path newDirectoryPath = Paths.get(dirName);
		if (Files.exists(newDirectoryPath)){
			throw new java.nio.file.FileAlreadyExistsException("directory "+dirName+" already exists");
		}
		Files.createDirectories(newDirectoryPath);
	}
	public static void removeDirectory(String dirName) throws IOException {
		Path theDir = Paths.get(dirName);
		Files.delete(theDir);
	}    
	public static void removeDirectoryRecursively(String dirName) throws IOException {
		Path directoryToDelete = Paths.get(dirName);
		if (Files.notExists(directoryToDelete)){
			throw new java.nio.file.FileAlreadyExistsException("directory "+dirName+" doesn't exist");
		}
		DeletingFileVisitor delFileVisitor = new DeletingFileVisitor();
		Files.walkFileTree(directoryToDelete, delFileVisitor);
	}
	public static boolean isFile(String fileName) throws IOException {
		Path theFilePath = Paths.get(fileName);
		return Files.exists(theFilePath)&&!Files.isDirectory(theFilePath);

	}
	public static boolean isDirectory(String fileName) throws IOException {
		Path theFilePath = Paths.get(fileName);
		return Files.exists(theFilePath)&&Files.isDirectory(theFilePath);

	}
	public static void copyFile(String srcName,String dstName) throws IOException {
		Path theSrc = Paths.get(srcName);
		Path theDst = Paths.get(dstName);
		if (Files.isDirectory(theDst)){
			theDst=theDst.resolve(theSrc.getFileName());	
		}
		Files.copy(theSrc, theDst,REPLACE_EXISTING);
	}
}
