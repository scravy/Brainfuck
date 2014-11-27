package de.scravy.java8;

import java.util.List;

import lombok.Data;

@Data
public class BrainfuckScript {

	final List<BrainfuckAST> commands;
}
