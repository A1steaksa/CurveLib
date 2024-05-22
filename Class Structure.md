CurveLib/
    Editor/
        **Frame** : *BFrame*
            **Panels**
        Sidebar/
            **Panel** : *CurveLib.Editor.PanelBase*
            **Draw** : *CurveLib.Editor.DrawBase*
        Toolbar/
            **Panel** : *CurveLib.Editor.PanelBase*
            **Draw** : *CurveLib.Editor.DrawBase*
        Graph/
            **Panel** : *CurveLib.Editor.PanelBase*
            **Draw** : *CurveLib.Editor.DrawBase*
	            **StackEntry**
            Draggable/
                **Base** : *DPanel*
                **HandlePoint** : *CurveLib.Editor.Graph.Draggable.Base*
                **MainPoint** : *CurveLib.Editor.Graph.Draggable.Base*
                **Draw** : *CurveLib.Editor.DrawBase*
	                **StackEntry**
		**PanelBase** : *DPanel*
		**DrawBase**
		**Config**
			**Graph**
				**Axes**
					**Axis**
						**Label**
						**NumberLine**
				**Caches**
			**Sidebar**
			**Toolbar**
		**Utils**
    Curve/
        **Data**
        **Point**

