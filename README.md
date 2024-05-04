# CurveLib

*All the fun of a graphing calculator, **now** in desktop form!*

This library adds arbitrary, user-defined Curves as a drop-in replacement for any of the [math.ease](https://wiki.facepunch.com/gmod/math.ease) library's functions.

But Curves aren't all that helpful on their own, which is why this library also adds a Curve Editor window that can create, view, and edit curves at runtime, even while they are being actively evaluated.

## 💡Concept Overview

### 🧣 Curves

#### What's a Curve in this context?

A Curve here is a sequence of at least two (2) Curve Points (More on these below,) that are each paired with the next Curve Point in the sequence to form Curve Segments.  Each Curve Segment is a pair of Curve Points that are used as the start and end of a cubic Bézier curve.

These Curves are then treated as continuous mathematical functions that take a fractional "Time" `X` value in the range `[0-1]` as their input and give a fractional "Position" `Y` value in the range `[0-1]` as their output.

### 📌 Curve Points

#### What is a Curve Point?

Curve Points are a grouping of three (3) Control Points, which are themselves simple 2D Vector (X, Y) positions.

Curve Points consist of three positions:

1. 📍 The Main Control Point  (**Main Point**)  
    This is either the start or the end of the Curve Segment(s) that contain this Curve Point.
2. ✋ The Left Handle Control Point (**Left Handle**)  
    This controls the ending tangent of the Curve Segment that ends at this Curve Point.  

    This Control Point is relative to the Main Control point and moves with it.

    **Note:** This will **not** be present on the first Curve Point in a Curve, as there is no Curve Segment before it.
3. 🤚 The Right Handle Control Point (**Right Handle**)  
    This controls the starting tangent of the Curve Segment that starts at this Curve Point.  

    This Control Point is relative to the Main Control point and moves with it.

    **Note:** This will **not** be present on the last Curve Point in a Curve, as there is no Curve Segment after it.

The Main Point controls the position of the Curve's end or start, while the Handles control the angle of the Curve as it approaches and leaves that position.

#### Bounds and Limits

1. The first and last Main Points in a Curve **must** have an `X` position of `0` and `1` respectively.
2. All Main Points must have their `X` and `Y` coordinates in the range `[0-1]`  
3. All Main Points must have a unique `X` coordinate.  Curve Segments can have overlapping and intersecting paths, but their start and ending positions must be a unique `X` coordinate.

These rules ensure that there is a valid output `Y` value for all input `X` values.

### 📈 The Curve Editor  

Curves are viewed, created, and edited from the Curve Editor, which is a tool that "lives" in a `DFrame`.

## 🛠️ Implementation Details

CurveLib has two halves:

1. 🔢 Curve Data  
    These are the Classes that define and evaluate Curves.  
    They're intended to be simple, efficient, and small so that using the library is as lightweight as possible.
2. 📈 The Curve Editor  
    This is the VGUI/Derma tool that is used during development when a Curve needs to be created, edited, refined, tested, etc.  
    This is not intended to be used outside of development and does not concern itself with performance beyond the need to run at an interactive framerate.  

    The Curve Editor is **not** intended to be shipped with addons that use CurveLib for Curve evaluation.  
    Because of this, the Curve Editor is designed to be wholly separate from the Curve Data and uses it in the same way that a third-party tool would.

### 🔢 Curve Data

Curves are represented by the `Curves.CurveData` Class available in `lua/includes/curvelib/curves/curve-data.lua`

Each `Curves.CurveData` contains a numerically-indexed `table<Curves.CurvePointData>` called `CurvePoints`.  
This is the sequence of Curve Points that define the Curve.

#### Curve Point Data

Curve Points are represented by the `Curves.CurvePointData` Class available in `lua/includes/curvelib/curves/curve-point-data.lua`

Each `Curves.CurvePointData` contains three (3) Vectors:
`MainPoint`, `LeftHandle` and `RightHandle`.  
These are the Control Points that dictate the shape and position of Curve Segments.

#### Curve Segments

Curve Segments are a useful way to think about Curves, but don't have a corresponding Class to represent them.  
They're mentioned here only to preempt confusion about the term.
