package de.scravy.java8;

import java.util.List;

import lombok.Value;

public interface BrainfuckAST {

	@Value
	class Inc implements BrainfuckAST {
		private int amount;
	}
	
	@Value
	class Mem implements BrainfuckAST {
		private int amount;
	}
	
	@Value
	class Loop implements BrainfuckAST {
		private List<BrainfuckAST> program;
	}
	
	@Value
	class Get implements BrainfuckAST {
		
	}
	
	@Value
	class Put implements BrainfuckAST {
		
	}
}
