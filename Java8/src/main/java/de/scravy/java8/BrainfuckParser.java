package de.scravy.java8;

public class BrainfuckParser {

	public static class ParseException extends Exception {

		private static final long serialVersionUID = -5921265904576187667L;

		public ParseException(final String message) {
			super(message);
		}
	}

	public BrainfuckScript parse(final byte[] data) throws ParseException {
		return null;
	}
}
