extends ColorRect

func _ready():
	GlobalSignals.connect("pawn_clicked", self._on_signal_pawn_clicked);

func _on_signal_pawn_clicked(pawn:Pawn2D):
	visible = true;
	
	#Update plate to show Pawn stats
	$HealthBar/Label.text = str(pawn.hp) + "/" + str(pawn.max_hp);
	$HealthBar.max_value = pawn.max_hp;
	$HealthBar.value = pawn.hp;
	
	$Name.text = pawn.display_name;
	$LevelRaceClass.text = "Level " + str(pawn.level) + " " + str(pawn.race) + " " + str(pawn.pclass[0]);
	
	$Stats/StrContainer/Strength.text = "STR " + str(pawn.get_as(CharacterSheet.AS.STR));
	$Stats/DexContainer/Dexterity.text = "DEX " + str(pawn.get_as(CharacterSheet.AS.DEX));
	$Stats/ConContainer/Constitution.text = "CON " + str(pawn.get_as(CharacterSheet.AS.CON));
	$Stats/IntContainer/Intelligence.text = "INT " + str(pawn.get_as(CharacterSheet.AS.INT));
	$Stats/WisContainer/Wisdom.text = "WIS " + str(pawn.get_as(CharacterSheet.AS.WIS));
	$Stats/ChaContainer/Charisma.text = "CHA " + str(pawn.get_as(CharacterSheet.AS.CHA));

func _on_close_button_pressed(): visible = false;
