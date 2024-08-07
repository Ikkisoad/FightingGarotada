extends Node
class_name PaletteManager

func setPalette(p, material):
	var paletteArray:Array
	if p == 1:
		paletteArray = Global.player1Palette
	else:
		paletteArray = Global.player2Palette
	if paletteArray.is_empty(): return

	var index = 0
	var materialArray = ["shader_parameter/newColor1","shader_parameter/newColor2","shader_parameter/newColor3",
	"shader_parameter/newColor4","shader_parameter/newColor5","shader_parameter/newColor6","shader_parameter/newColor7",
	"shader_parameter/newColor8","shader_parameter/newColor9","shader_parameter/newColor10","shader_parameter/newColor11",
	"shader_parameter/newColor12","shader_parameter/newColor13","shader_parameter/newColor14","shader_parameter/newColor15",
	"shader_parameter/newColor16","shader_parameter/newColor17","shader_parameter/newColor18","shader_parameter/newColor19",
	"shader_parameter/newColor20","shader_parameter/newColor21","shader_parameter/newColor22","shader_parameter/newColor23",
	"shader_parameter/newColor24","shader_parameter/newColor25"]
	for m in materialArray:
		var r = paletteArray[index].r
		var g = paletteArray[index].g
		var b = paletteArray[index].b
		index += 1
		material.set(m, Vector4(r,g,b,255.0))
