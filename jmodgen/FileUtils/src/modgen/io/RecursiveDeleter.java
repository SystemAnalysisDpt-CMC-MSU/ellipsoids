package modgen.io;
import java.io.IOException;
public class RecursiveDeleter {
 
    /**
     * @param args
     * @throws IOException 
     */
    public static void main(String[] args) throws IOException {
    	
    	String dirName=new String("C:\\Users\\Administrator\\Documents\\_Revolation\\ReVolation\\externals\\ellmodlib\\TTD\\c10ee9eb73443f3d16bde386fb73767db8b893b8");
    	modgen.io.FileUtils.removeDirectoryRecursively(dirName);
    }
 
}