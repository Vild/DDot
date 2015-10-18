/**
	Types used for ddot
	Copyright: Copyright © 2015 Dan Printzell
	License: Mozila Public License Version 2.0
	Authors: Dan Printzell
*/
module ddot.type;
import ddot.dot;
import std.variant;
import std.format : format;

/// Contains all the different types that a dot object can be
enum DotType {
	GRAPH,  /// A graph object
	DIGRAPH,/// A disgraph object
	SUBGRAPH/// A subgraph object
}

string toString(DotType type) {
	final switch (type) with(DotType) {
	case GRAPH:
		return "graph";
	case DIGRAPH:
		return "disgraph";
	case SUBGRAPH:
		return "subgraph";
	}
}

/// Contains all the different types that a attribute statement can apply attribute to
enum DotAttributeTypes {
	GRAPH, /// A graph statement
	NODE,  /// A node statement
	EDGE   /// A edge statement
}

string toString(DotAttributeTypes type) {
	final switch (type) with(DotAttributeTypes) {
	case GRAPH:
		return "graph";
	case NODE:
		return "node";
	case EDGE:
		return "edge";
	}
}

/// The different direction a port can point to
enum DotDirection {
	NONE,/// Port is unused
	N,   /// North
	NE,  /// Northeast
	E,   /// East
	SE,  /// Southeast
	S,   /// South
	SW,  /// Southwest
	W,   /// West
	NW  /// Northwest
}
string toString(DotDirection dir) {
	final switch(dir) with (DotDirection) {
	case NONE:
		return null;
	case N:
		return "n";
	case NE:
		return "ne";
	case E:
		return "e";
	case SE:
		return "se";
	case S:
		return "s";
	case SW:
		return "sw";
	case W:
		return "w";
	case NW:
		return "nw";
	}
}

/// Identifier via a ID
struct DotIdentifierID {
	string id; /// The ID
	DotIdentifierID * port; /// Optional port
	DotDirection dir; /// Optional direction

	this(string id, DotIdentifierID * port = null, DotDirection dir = DotDirection.NONE) {
		this.id = id;
		this.port = port;
		this.dir = dir;
	}

	string toString() {
		string d = dir.toString;
		return id ~ (port ? (":" ~ port.toString) : "") ~ (d ? (":" ~ d) : "");
	}
}

/// Combined type for all indentifiers
alias DotIdentifier = Algebraic!(DotIdentifierID, Dot *);

/// Contains attribute data for a dot object.
struct DotAttribute {
	string id; /// Identifies the property
	string data; /// The value for the property

	string toString() {
		return format("%s=%s", id, data);
	}
}

string toString(DotAttribute[] attribs) {
	return format("%-(%s,%)", attribs);
}

/// Holds the data for a node
struct DotNodeStatement {
	DotIdentifierID object; /// The object
	DotAttribute[] attribs; /// The attributes for the object

	string toString(string indent) {
		return format("%s%s[%s];", indent, object.toString, attribs.toString);
	}
}

/// Holds the data for a edge
struct DotEdgeStatement {
	DotIdentifier object; /// The object
	DotIdentifier[] others; /// The other objects
	DotAttribute[] attribs; /// The attributes for the connection

	this(T)(T object, DotIdentifier[] others, DotAttribute[] attribs) {
		this.object = object;
		this.others = others;
		this.attribs = attribs;
	}

	string toString(string indent, DotType type) {
		assert(others.length);

		if (type == DotType.GRAPH)
			return format("%s%s -- %-(%s -- %)[%s];", indent, object.toString, others, attribs.toString);
		else
			return format("%s%s -> %-(%s -> %)[%s];", indent, object.toString, others, attribs.toString);
	}
}

/// Holds the data for a attribute statement
struct DotAttributeStatement {
	DotAttributeTypes id; /// The object
	DotAttribute[] attribs; /// The attributes for the object

	string toString(string indent) {
		return format("%s%s[%s];", indent, id.toString, attribs.toString);
	}
}

/// Holds the data for a assignment statement
struct DotAssignmentStatement {
	DotIdentifier to; /// The object to be copied to
	DotIdentifier from; /// The object to be copied from

	this(T1, T2)(T1 to, T2 from) {
		this.to = to;
		this.from = from;
	}

	string toString(string indent) {
		return format("%s%s = %s;", indent, to.toString, from.toString);
	}
}

/// Combined type for all statements
alias DotStatement = Algebraic!(DotNodeStatement, DotEdgeStatement, DotAttributeStatement, DotAssignmentStatement, Dot);

string toString(DotStatement stmt, string indent, DotType type) {
	if (auto node = stmt.peek!DotNodeStatement)
		return node.toString(indent);
	else if (auto edge = stmt.peek!DotEdgeStatement)
		return edge.toString(indent, type);
	else if (auto attr = stmt.peek!DotAttributeStatement)
		return attr.toString(indent);
	else if (auto copy = stmt.peek!DotAssignmentStatement)
		return copy.toString(indent);
	else if (auto dot = stmt.peek!Dot)
		return dot.toString(indent);
	else
		assert(0);
}
