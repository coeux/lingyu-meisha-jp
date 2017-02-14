S580_magic_M014_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S580_magic_M014_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S580_magic_M014_attack.info_pool[effectScript.ID].Attacker)
        
		S580_magic_M014_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S580_1")
		PreLoadAvatar("S580_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfhgj" )
		effectScript:RegisterEvent( 24, "hgfdjj" )
		effectScript:RegisterEvent( 27, "fdgfjh" )
		effectScript:RegisterEvent( 28, "hgjhkjhl" )
	end,

	dgfhgj = function( effectScript )
		SetAnimation(S580_magic_M014_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	hgfdjj = function( effectScript )
		AttachAvatarPosEffect(false, S580_magic_M014_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 80), 2, 100, "S580_1")
	end,

	fdgfjh = function( effectScript )
		AttachAvatarPosEffect(false, S580_magic_M014_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S580_2")
	end,

	hgjhkjhl = function( effectScript )
			DamageEffect(S580_magic_M014_attack.info_pool[effectScript.ID].Attacker, S580_magic_M014_attack.info_pool[effectScript.ID].Targeter, S580_magic_M014_attack.info_pool[effectScript.ID].AttackType, S580_magic_M014_attack.info_pool[effectScript.ID].AttackDataList, S580_magic_M014_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
