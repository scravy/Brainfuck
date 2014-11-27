package de.scravy.java8;

import java.util.List;

import lombok.EqualsAndHashCode;
import lombok.Value;

public abstract class BrainfuckAST {

	private BrainfuckAST() {
	}

	@Value
	@EqualsAndHashCode(callSuper = false)
	public static class Inc extends BrainfuckAST {
		private int amount;
	}

	@Value
	@EqualsAndHashCode(callSuper = false)
	public static class Mem extends BrainfuckAST {
		private int amount;
	}

	@Value
	@EqualsAndHashCode(callSuper = false)
	public static class Loop extends BrainfuckAST {
		private List<BrainfuckAST> program;
	}

	@Value
	@EqualsAndHashCode(callSuper = false)
	public static class Get extends BrainfuckAST {

	}

	@Value
	@EqualsAndHashCode(callSuper = false)
	public static class Put extends BrainfuckAST {

	}
}
