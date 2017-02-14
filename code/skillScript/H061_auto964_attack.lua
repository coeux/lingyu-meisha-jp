H061_auto964_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H061_auto964_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H061_auto964_attack.info_pool[effectScript.ID].Attacker)
        
		H061_auto964_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_06101")
		PreLoadSound("stalk_06101")
		PreLoadAvatar("H061_3_3")
		PreLoadAvatar("H061_3_4")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ert" )
		effectScript:RegisterEvent( 1, "sd" )
		effectScript:RegisterEvent( 11, "sd1" )
		effectScript:RegisterEvent( 15, "sbv" )
		effectScript:RegisterEvent( 16, "ofds" )
		effectScript:RegisterEvent( 18, "erg" )
	end,

	ert = function( effectScript )
		SetAnimation(H061_auto964_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	sd = function( effectScript )
			PlaySound("skill_06101")
	end,

	sd1 = function( effectScript )
			PlaySound("stalk_06101")
	end,

	sbv = function( effectScript )
		AttachAvatarPosEffect(false, H061_auto964_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 180), 1.3, 100, "H061_3_3")
	end,

	ofds = function( effectScript )
		AttachAvatarPosEffect(false, H061_auto964_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.35, 100, "H061_3_4")
	end,

	erg = function( effectScript )
			DamageEffect(H061_auto964_attack.info_pool[effectScript.ID].Attacker, H061_auto964_attack.info_pool[effectScript.ID].Targeter, H061_auto964_attack.info_pool[effectScript.ID].AttackType, H061_auto964_attack.info_pool[effectScript.ID].AttackDataList, H061_auto964_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
