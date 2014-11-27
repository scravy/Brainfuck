package de.scravy.java8;

public interface BrainfuckVM {

	class InterpreterException extends Exception {

		private static final long serialVersionUID = 2941489569497720106L;

		public InterpreterException(final Exception cause) {
			super(cause.getMessage(), cause);
		}
	}

	void run(final BrainfuckScript script);

}
