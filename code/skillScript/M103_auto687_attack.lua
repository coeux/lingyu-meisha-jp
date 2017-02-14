M103_auto687_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M103_auto687_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M103_auto687_attack.info_pool[effectScript.ID].Attacker)
        
		M103_auto687_attack.info_pool[effectScript.ID] = nil
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
		effectScript:RegisterEvent( 33, "dsfg" )
	end,

	dcdfd = function( effectScript )
		SetAnimation(M103_auto687_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	hgfhj = function( effectScript )
		AttachAvatarPosEffect(false, M103_auto687_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-60, 300), 1, 100, "S576_1")
	end,

	sfdsf = function( effectScript )
		AttachAvatarPosEffect(false, M103_auto687_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 20), 1.5, 100, "S576_2")
	end,

	sdgfg = function( effectScript )
		CameraShake()
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, M103_auto687_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S576_3")
	end,

	dsfg = function( effectScript )
			DamageEffect(M103_auto687_attack.info_pool[effectScript.ID].Attacker, M103_auto687_attack.info_pool[effectScript.ID].Targeter, M103_auto687_attack.info_pool[effectScript.ID].AttackType, M103_auto687_attack.info_pool[effectScript.ID].AttackDataList, M103_auto687_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
