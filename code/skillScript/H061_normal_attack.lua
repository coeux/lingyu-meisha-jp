H061_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H061_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H061_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H061_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H061_2_1")
		PreLoadAvatar("H061_2_2")
		PreLoadSound("atalk_06101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdavgb" )
		effectScript:RegisterEvent( 7, "gszg" )
		effectScript:RegisterEvent( 23, "fsv" )
	end,

	sdavgb = function( effectScript )
		SetAnimation(H061_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	gszg = function( effectScript )
		AttachAvatarPosEffect(false, H061_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, -70), 1.1, 100, "H061_2_1")
	AttachAvatarPosEffect(false, H061_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 70), 1.2, 100, "H061_2_2")
		PlaySound("atalk_06101")
	end,

	fsv = function( effectScript )
			DamageEffect(H061_normal_attack.info_pool[effectScript.ID].Attacker, H061_normal_attack.info_pool[effectScript.ID].Targeter, H061_normal_attack.info_pool[effectScript.ID].AttackType, H061_normal_attack.info_pool[effectScript.ID].AttackDataList, H061_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
