S524_magic_M013_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S524_magic_M013_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S524_magic_M013_attack.info_pool[effectScript.ID].Attacker)
        
		S524_magic_M013_attack.info_pool[effectScript.ID] = nil
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
		SetAnimation(S524_magic_M013_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	fdsgghh = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M013_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(90, 55), 1.5, 100, "M013_pugong_1")
	end,

	fgdhgjh = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M013_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "M013_pugong_2")
	end,

	fdghjj = function( effectScript )
			DamageEffect(S524_magic_M013_attack.info_pool[effectScript.ID].Attacker, S524_magic_M013_attack.info_pool[effectScript.ID].Targeter, S524_magic_M013_attack.info_pool[effectScript.ID].AttackType, S524_magic_M013_attack.info_pool[effectScript.ID].AttackDataList, S524_magic_M013_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
