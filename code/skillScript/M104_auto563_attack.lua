M104_auto563_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M104_auto563_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M104_auto563_attack.info_pool[effectScript.ID].Attacker)
        
		M104_auto563_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S562_1")
		PreLoadAvatar("S562_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdh" )
		effectScript:RegisterEvent( 26, "dsgh" )
		effectScript:RegisterEvent( 39, "sddddg" )
		effectScript:RegisterEvent( 43, "cvxb" )
	end,

	sfdh = function( effectScript )
		SetAnimation(M104_auto563_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dsgh = function( effectScript )
		AttachAvatarPosEffect(false, M104_auto563_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-100, 250), 1.2, 100, "S562_1")
	end,

	sddddg = function( effectScript )
		AttachAvatarPosEffect(false, M104_auto563_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S562_2")
	end,

	cvxb = function( effectScript )
			DamageEffect(M104_auto563_attack.info_pool[effectScript.ID].Attacker, M104_auto563_attack.info_pool[effectScript.ID].Targeter, M104_auto563_attack.info_pool[effectScript.ID].AttackType, M104_auto563_attack.info_pool[effectScript.ID].AttackDataList, M104_auto563_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
