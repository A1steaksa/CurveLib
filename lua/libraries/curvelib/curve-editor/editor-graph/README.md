# Curve Graph

This is the component that is responsible for drawing and interactions with the Curve Editor's currently loaded Curve Data.

## Curve Drawing

The Curve Drawing class handles all of the drawing functions required to draw the Curve Graph.

Because the Curve Drawing class is so tightly coupled with the Curve Graph class, many of the functions need to have the specific context for the Curve Graph and the Curve Editor's state.  To achieve this, the Curve Drawing class has a Stack of Editor Graph classes.  The Editor Graph that is about to be drawn is pushed onto the Stack prior to being drawn and is popped after it is drawn.  In theory, this should never have more than one graph on it at a time, but using a Stack is an easy way to avoid errors.

