S576_magic_M103_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S576_magic_M103_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S576_magic_M103_attack.info_pool[effectScript.ID].Attacker)
        
		S576_magic_M103_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S576_1")
		PreLoadAvatar("S576_2")
		PreLoadAvatar("S576_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dcdfd" )
		effectScript:RegisterEvent( 17, "hgfhj" )
		effectScript:RegisterEvent( 30, "sfdsf" )
		effectScript:RegisterEvent( 31, "sdgfg" )
		effectScript:RegisterEvent( 32, "sfdf" )
		effectScript:RegisterEvent( 34, "dsfg" )
	end,

	dcdfd = function( effectScript )
		SetAnimation(S576_magic_M103_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	hgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S576_magic_M103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-60, 300), 1, 100, "S576_1")
	end,

	sfdsf = function( effectScript )
		AttachAvatarPosEffect(false, S576_magic_M103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 20), 1.5, 100, "S576_2")
	end,

	sdgfg = function( effectScript )
		CameraShake()
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, S576_magic_M103_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S576_3")
	end,

	dsfg = function( effectScript )
			DamageEffect(S576_magic_M103_attack.info_pool[effectScript.ID].Attacker, S576_magic_M103_attack.info_pool[effectScript.ID].Targeter, S576_magic_M103_attack.info_pool[effectScript.ID].AttackType, S576_magic_M103_attack.info_pool[effectScript.ID].AttackDataList, S576_magic_M103_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
