S524_magic_M014_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S524_magic_M014_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S524_magic_M014_attack.info_pool[effectScript.ID].Attacker)
        
		S524_magic_M014_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S580_1")
		PreLoadAvatar("S580_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfhgj" )
		effectScript:RegisterEvent( 22, "hgfdjj" )
		effectScript:RegisterEvent( 25, "fdgfjh" )
		effectScript:RegisterEvent( 26, "hgjhkjhl" )
	end,

	dgfhgj = function( effectScript )
		SetAnimation(S524_magic_M014_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	hgfdjj = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M014_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 80), 2, 100, "S580_1")
	end,

	fdgfjh = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M014_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S580_2")
	end,

	hgjhkjhl = function( effectScript )
			DamageEffect(S524_magic_M014_attack.info_pool[effectScript.ID].Attacker, S524_magic_M014_attack.info_pool[effectScript.ID].Targeter, S524_magic_M014_attack.info_pool[effectScript.ID].AttackType, S524_magic_M014_attack.info_pool[effectScript.ID].AttackDataList, S524_magic_M014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
