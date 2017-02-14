M015_auto611_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M015_auto611_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M015_auto611_attack.info_pool[effectScript.ID].Attacker)
        
		M015_auto611_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S611_1")
		PreLoadAvatar("H001_pugong_2")
		PreLoadAvatar("S292_2")
		PreLoadAvatar("S292_2")
		PreLoadAvatar("S292_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdg" )
		effectScript:RegisterEvent( 12, "dsfh" )
		effectScript:RegisterEvent( 34, "dsgh" )
		effectScript:RegisterEvent( 35, "sfdh" )
		effectScript:RegisterEvent( 37, "sdfdhh" )
		effectScript:RegisterEvent( 40, "fdgfj" )
		effectScript:RegisterEvent( 41, "fvdgfj" )
	end,

	sfdg = function( effectScript )
		SetAnimation(M015_auto611_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsfh = function( effectScript )
		AttachAvatarPosEffect(false, M015_auto611_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 150), 1, 100, "S611_1")
	end,

	dsgh = function( effectScript )
		AttachAvatarPosEffect(false, M015_auto611_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, -50), 1, 100, "H001_pugong_2")
	end,

	sfdh = function( effectScript )
		AttachAvatarPosEffect(false, M015_auto611_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(150, 0), 0.8, 100, "S292_2")
	end,

	sdfdhh = function( effectScript )
		AttachAvatarPosEffect(false, M015_auto611_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -50), 1, 100, "S292_2")
	end,

	fdgfj = function( effectScript )
		AttachAvatarPosEffect(false, M015_auto611_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-150, 0), 0.7, 100, "S292_2")
	end,

	fvdgfj = function( effectScript )
			DamageEffect(M015_auto611_attack.info_pool[effectScript.ID].Attacker, M015_auto611_attack.info_pool[effectScript.ID].Targeter, M015_auto611_attack.info_pool[effectScript.ID].AttackType, M015_auto611_attack.info_pool[effectScript.ID].AttackDataList, M015_auto611_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
