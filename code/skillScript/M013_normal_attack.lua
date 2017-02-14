M013_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M013_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M013_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M013_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M013_pugong_1")
		PreLoadAvatar("M013_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgh" )
		effectScript:RegisterEvent( 18, "fdsgghh" )
		effectScript:RegisterEvent( 26, "fgdhgjh" )
		effectScript:RegisterEvent( 27, "fdghjj" )
	end,

	dsgh = function( effectScript )
		SetAnimation(M013_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fdsgghh = function( effectScript )
		AttachAvatarPosEffect(false, M013_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(90, 55), 1.5, 100, "M013_pugong_1")
	end,

	fgdhgjh = function( effectScript )
		AttachAvatarPosEffect(false, M013_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "M013_pugong_2")
	end,

	fdghjj = function( effectScript )
			DamageEffect(M013_normal_attack.info_pool[effectScript.ID].Attacker, M013_normal_attack.info_pool[effectScript.ID].Targeter, M013_normal_attack.info_pool[effectScript.ID].AttackType, M013_normal_attack.info_pool[effectScript.ID].AttackDataList, M013_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
