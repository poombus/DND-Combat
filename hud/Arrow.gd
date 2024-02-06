extends Control
class_name Arrow

var point1:Vector2;
var point2:Vector2;
var max_points:int = 30;

@onready var line = $"Arrow Body";

func _ready():
	point_draw();
#    point1 = Vector2(0, 0);
#    point2 = Vector2(0, 0);
#    draw();

func init(p1:Vector2, p2:Vector2):
	point1 = p1;
	point2 = p2;
	
	draw();

func draw():
	visible = true;
	line.clear_points();
	
	var dist = point1.distance_to(point2);
	
	var coef:Array[float] = parabola_solver(point1, midpoint_logic(point1, point2), point2);
	
	for i in (max_points):
		var x;
		if point1.x <= point2.x: x = point1.x+((dist/max_points)*i);
		else: x = point1.x-((dist/max_points)*i);
		var y = parabola_point(coef[0], coef[1], coef[2], x);
		
		#if y > point2.y: break;
		var next_point = Vector2(x,y);
		line.add_point(next_point);
	line.add_point(point2);

func parabola_point(a:float,b:float,c:float,x:float) -> float:
	return (a*pow(x,2))+(b*x)+c;

func parabola_solver(p1:Vector2, p2:Vector2, p3:Vector2) -> Array[float]:
	var denom = (p1.x - p2.x)*(p1.x - p3.x)*(p2.x - p3.x);
	var A = (p3.x * (p2.y - p1.y) + p2.x * (p1.y - p3.y) + p1.x * (p3.y - p2.y)) / denom;
	var B = (pow(p3.x,2) * (p1.y - p2.y) + pow(p2.x,2) * (p3.y - p1.y) + pow(p1.x,2) * (p2.y - p3.y)) / denom;
	var C = (p2.x * p3.x * (p2.x - p3.x) * p1.y + p3.x * p1.x * (p3.x - p1.x) * p2.y + p1.x * p2.x * (p1.x - p2.x) * p3.y) / denom;
	return [A, B, C];

func midpoint_logic(p1:Vector2, p2:Vector2) -> Vector2:
	var midpoint:Vector2;
	
	var dist = p1.distance_to(p2);
	midpoint = Vector2(point1.x+((point2.x-point1.x)/2), min(100, min(point2.y,point1.y)-(40000/dist)));
	
	return midpoint;

func set_target(source_global_pos:Vector2, target_global_pos:Vector2):
	point1 = source_global_pos;
	point2 = target_global_pos;
	draw();

func point_draw():
	point1 = $Point1.global_position;
	point2 = $Point2.global_position;
	draw();
