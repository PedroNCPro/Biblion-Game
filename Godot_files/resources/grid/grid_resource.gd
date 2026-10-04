extends Resource
class_name GridResource


# NOTE: it would be great to have a @tool script that allowed the developer to build the level through
#       the editor itself
## Bounding box of the grid
@export var grid_size: Vector2i = Vector2i(5, 5)
## Positions where there are cells in the grid
@export var cell_layout: Dictionary[Vector2i, int] 
