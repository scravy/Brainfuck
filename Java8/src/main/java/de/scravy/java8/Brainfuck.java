package de.scravy.java8;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;

import lombok.Data;
import lombok.val;

import com.google.common.io.ByteStreams;

public class Brainfuck {

	private final static String VERSION = "Thu Nov 27 05:28:07 CET 2014 -- Java 8 Brainfuck Interpreter";
	private final static String[] HELP = {
			"  -p  pretty print parse tree",
			"  -h  this help",
			"  -v  print version information"
	};

	@Data
	private static class Options {

		private boolean optPrintParseTree = false;
		private String filename = null;
	}

	public static void main(String... args) {

		final val options = new Options();

		readArgs: for (int i = 0; i < args.length; i += 1) {
			switch (args[i]) {
			case "-v":
				System.out.println(VERSION);
				return;
			case "-h":
				Arrays.asList(HELP).forEach(System.out::println);
				return;
			case "-p":
				options.setOptPrintParseTree(true);
				continue;
			default:
				options.setFilename(args[i]);
				break readArgs;
			}
		}

		try {
			run(options);
		} catch (IOException e) {
			System.err.printf(
					"Could not read script from %s: %s",
					options.getFilename() == null ? "<stdin>" : options
							.getFilename(),
					e.getClass().getSimpleName());
			System.exit(1);
		}
	}

	private static void run(final Options options) throws IOException {
		final byte[] data = options.getFilename() == null
				? ByteStreams.toByteArray(System.in)
				: Files.readAllBytes(Paths.get(options.getFilename()));
				
		val parser = new BrainfuckParser();
		
		val parseTree = parser.parse(data);
		
		val interpreter = new BrainfuckVM();
	}

}
