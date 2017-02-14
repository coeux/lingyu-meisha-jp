H037_auto724_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H037_auto724_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H037_auto724_attack.info_pool[effectScript.ID].Attacker)
        
		H037_auto724_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H037_xuli_3")
		PreLoadSound("attack_03703")
		PreLoadSound("atalk_03701")
		PreLoadAvatar("H037_xuli_2")
		PreLoadAvatar("H037_xuli_1")
		PreLoadSound("attack_03702")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dghhhdgf" )
		effectScript:RegisterEvent( 12, "sdfdh" )
		effectScript:RegisterEvent( 14, "sdfdhghh" )
		effectScript:RegisterEvent( 26, "sfdhhjjjj" )
		effectScript:RegisterEvent( 28, "fghjj" )
	end,

	dghhhdgf = function( effectScript )
		SetAnimation(H037_auto724_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sdfdh = function( effectScript )
		AttachAvatarPosEffect(false, H037_auto724_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, 0), 1.5, -100, "H037_xuli_3")
		PlaySound("attack_03703")
		PlaySound("atalk_03701")
	end,

	sdfdhghh = function( effectScript )
		AttachAvatarPosEffect(false, H037_auto724_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 50), 1, 100, "H037_xuli_2")
	end,

	sfdhhjjjj = function( effectScript )
		AttachAvatarPosEffect(false, H037_auto724_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H037_xuli_1")
		PlaySound("attack_03702")
	end,

	fghjj = function( effectScript )
			DamageEffect(H037_auto724_attack.info_pool[effectScript.ID].Attacker, H037_auto724_attack.info_pool[effectScript.ID].Targeter, H037_auto724_attack.info_pool[effectScript.ID].AttackType, H037_auto724_attack.info_pool[effectScript.ID].AttackDataList, H037_auto724_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
