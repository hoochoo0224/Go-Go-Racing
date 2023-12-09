extends Node


func _ready():
	var record = "{0}:{1}:{2}".format([str(Global.m).pad_zeros(2), str(Global.s).pad_zeros(2), str(Global.ms).pad_zeros(2)], "{_}")
	var best_record = Global.fload("res://data/time_record.dat")[Global.levelNum-1]
	$ColorRect/Label2.text = "기록   " + record
	if Global.time_calc(best_record, record):
		$ColorRect/Label3.text = "최고 기록     " + record
	else:
		$ColorRect/Label3.text = "최고 기록     " + best_record
