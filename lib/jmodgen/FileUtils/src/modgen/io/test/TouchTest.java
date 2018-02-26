package modgen.io.test;

import java.util.Arrays;

//import static org.junit.Assert.*;

import org.junit.Test;

public class TouchTest {

	@Test
	public void test() {
		String pathStr="C:\\Users\\Administrator\\Documents\\_Git\\test";
		//String[] files=mxberry.io.FileUtils.listFilesRecursive(pathStr,"regex:.*m$",2);
		String[] files=modgen.io.FileUtils.listDirsRecursive(pathStr,"glob:**",0);
		java.lang.System.out.println(Arrays.toString(files));
		//files=modgen.io.FileUtils.listFilesRecursive(path,"regex:.*m$",0);
		//java.lang.System.out.println(files.toString());
	}
}
