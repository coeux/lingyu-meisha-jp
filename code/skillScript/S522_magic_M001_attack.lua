S522_magic_M001_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S522_magic_M001_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S522_magic_M001_attack.info_pool[effectScript.ID].Attacker)
        
		S522_magic_M001_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S502_yinbo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asds" )
		effectScript:RegisterEvent( 26, "asfd" )
		effectScript:RegisterEvent( 31, "hgfdjhk" )
	end,

	asds = function( effectScript )
		SetAnimation(S522_magic_M001_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	asfd = function( effectScript )
		AttachAvatarPosEffect(false, S522_magic_M001_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 80), 2, 100, "S502_yinbo")
	end,

	hgfdjhk = function( effectScript )
			DamageEffect(S522_magic_M001_attack.info_pool[effectScript.ID].Attacker, S522_magic_M001_attack.info_pool[effectScript.ID].Targeter, S522_magic_M001_attack.info_pool[effectScript.ID].AttackType, S522_magic_M001_attack.info_pool[effectScript.ID].AttackDataList, S522_magic_M001_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
