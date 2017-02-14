M103_auto577_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M103_auto577_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M103_auto577_attack.info_pool[effectScript.ID].Attacker)
        
		M103_auto577_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S576_1")
		PreLoadAvatar("S576_2")
		PreLoadAvatar("S577")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dcdfd" )
		effectScript:RegisterEvent( 16, "hgfhj" )
		effectScript:RegisterEvent( 30, "sfdsf" )
		effectScript:RegisterEvent( 32, "sfdf" )
		effectScript:RegisterEvent( 36, "dsf" )
	end,

	dcdfd = function( effectScript )
		SetAnimation(M103_auto577_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	hgfhj = function( effectScript )
		AttachAvatarPosEffect(false, M103_auto577_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-60, 300), 1, 100, "S576_1")
	end,

	sfdsf = function( effectScript )
		AttachAvatarPosEffect(false, M103_auto577_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 20), 1.5, 100, "S576_2")
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, M103_auto577_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 2.5, 100, "S577")
	end,

	dsf = function( effectScript )
			DamageEffect(M103_auto577_attack.info_pool[effectScript.ID].Attacker, M103_auto577_attack.info_pool[effectScript.ID].Targeter, M103_auto577_attack.info_pool[effectScript.ID].AttackType, M103_auto577_attack.info_pool[effectScript.ID].AttackDataList, M103_auto577_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
