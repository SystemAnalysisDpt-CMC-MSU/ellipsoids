package modgen.io;

import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
 
public class DeletingFileVisitor extends SimpleFileVisitor<Path>{
 
@Override
public FileVisitResult visitFile(Path file, BasicFileAttributes attributes)
        throws IOException {
    if(attributes.isRegularFile()){
        //System.out.println("Deleting Regular File: " + file.getFileName());
        Files.delete(file);
    }
    return FileVisitResult.CONTINUE;
}
 
@Override
    public FileVisitResult postVisitDirectory(Path directory, IOException ioe)
            throws IOException {
        //System.out.println("Deleting Directory: " + directory.getFileName());
        Files.delete(directory);
        return FileVisitResult.CONTINUE;
    }
 
@Override
    public FileVisitResult visitFileFailed(Path file, IOException ioe)
            throws IOException {
        //System.out.println("Something went wrong while working on : " + file.getFileName());
        ioe.printStackTrace();
        return FileVisitResult.CONTINUE;
    }
}