/**
	The Dot class
	Copyright: Copyright © 2015 Dan Printzell
	License: Mozila Public License Version 2.0
	Authors: Dan Printzell
*/

module ddot.dot;
import ddot.type;

/***
	A DOT is represented by a instance of this class.
*/
class Dot {
public:
	/**
		Generate a empty dot instance.
		$(PARAM name) the name of the object.
		$(PARAM type) specifices the dot type, the dot object is not allowed to be a $(PSYMBOL SUBGRAPH).
		$(PARAM strict) specifices if the object should be strict.
	*/
	this(string name, DotType type = DotType.GRAPH, bool strict = false) {
		this._name = name;
		this._type = type;
		this._strict = strict;
	}

	/*
		Generate a dot instance based on text.
	*/
	/*this(string data) {
		load(data);
	}*/

	void add(DotStatement stmt) {
		statements ~= stmt;
	}

	void add(T)(T stmt) {
		statements ~= DotStatement(stmt);
	}

	void save(string file, int indent = 0) {
		import std.stdio : File;

		File f = File(file, "w");
		scope (exit)
			f.close();

		f.write(toString());
	}

	/**
		Get/Set the current type of the dot object.
		Root dot object is not allowed to be a $(PSYMBOL SUBGRAPH).
	*/
	@property ref DotType type() { return _type; }

	/**
		Get/Set if the dot object should be strict.
	*/
	@property ref bool strict() { return _strict; }

	/**
		Get/Set the dot object name.
	*/
	@property ref string name() { return _name; }

	/**
		Returns the list of all the children.
	*/
	@property ref DotStatement[] statements() { return _statements; }

	override string toString() { return toString(""); }

	string toString(string indent) {
		import std.format : format;
		alias toStr = ddot.type.toString;
		string str = "";

		str = format("%s%s%s%s {\n", indent, (strict?"strict ":""), (type == DotType.GRAPH ? "graph ": (type == DotType.DIGRAPH ? "disgraph " : "subgraph ")), name);

		foreach (stmt; statements)
			str ~= format("%s\n", toStr(stmt, indent ~ "\t", _type));

		str ~= format("%s}\n", indent);

		return str;
	}

private:
	DotType _type;
	bool _strict;
	string _name;
	DotStatement[] _statements;
	/**
		Converting the $(PARAM data) into its API containers.
	*/
	void load(string data) {
		data = data;
		assert(0, "Data loading is not implemented!");
	}
}

unittest {
	Dot dot = new Dot("test");
	assert(dot.type == DotType.GRAPH);
	assert(!dot.strict);
	dot.strict = true;
	assert(dot.strict);
	dot.destroy;
}

unittest {
	import std.stdio;
/*
graph graphname {
		// This attribute applies to the graph itself
		size="1,1";
		// The label attribute can be used to change the label of a node
		a [label="Foo"];
		// Here, the node shape is changed.
		b [shape=box];
		// These edges both have different line properties
		a -- b -- c [color=blue];
		b -- d [style=dotted];
}
*/

	Dot dot = new Dot("graphname");
	dot.add(
		DotAssignmentStatement(
			DotIdentifierID("size"),
			DotIdentifierID("\"1,1\"")
		)
	);

	dot.add(
		DotNodeStatement(
			DotIdentifierID("a"),
			[
				DotAttribute("label", "\"Foo\"")
			]
		)

	);

	dot.add(
		DotNodeStatement(
			DotIdentifierID("b"),
			[
				DotAttribute("shape", "box")
			]
		)
	);

	dot.add(
		DotEdgeStatement(
			DotIdentifierID("a"),
			[
				DotIdentifier(
					DotIdentifierID("b")
				),
				DotIdentifier(
					DotIdentifierID("c")
				)
			],
			[
				DotAttribute("color", "blue")
			]
		)
	);

	dot.add(
		DotEdgeStatement(
			DotIdentifierID("b"),
			[
				DotIdentifier(
					DotIdentifierID("d")
				)
			],
			[
				DotAttribute("style", "dotted")
			]
		)
	);

	writeln(dot);

	dot.destroy;
}
