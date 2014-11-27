package de.scravy.java8;

import static java.nio.file.Files.readAllBytes;
import static java.nio.file.Paths.get;

import java.io.IOException;

public class Brainfuck {

	public static void main(String... args) {

		try {
			final String data = new String(readAllBytes(get(args[0])));
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

}
