# Notes for Feature Node Selection Branch

## Major Goals

✔️ Make main handles selectable

✔️ Only show side handles for selected main handle(s)
This is probably going to be an issue.  It feels unnatural for none of the other handles to show their side handles.

Maybe show handles for the nodes directly connected to selected nodes?

⏹️ Move all selected main handles together when dragged

✔️ Have the ability to box-select main handles

## Minor Goals

✔️ Make handles draw below box selection  
Maybe need to have the graph panel draw the handles manually?
(They're now drawn manually)

## Known Issues

❓ Outlined Rect drawing doesn't respect line alignment and the corners are hollow

❓ Sidebar checkboxes don't work

# Notes for Feature Multi Handle Drag Branch

## Major Goals

⏹️ Move Handles together when multiple are selected and one is dragged

⏹️ Prevent Main Handles from being dragged into positions where their Side Handles would leave the graph

## Notes

* Handle dragging logic currently lives within the Handle Base.  That's just not going to work long-term.  
It'll need to be moved to the Graph Panel and the Handle will just be detecting and passing inputs to the Graph Panel.