M001_auto627_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M001_auto627_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M001_auto627_attack.info_pool[effectScript.ID].Attacker)
        
		M001_auto627_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S200")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
		effectScript:RegisterEvent( 27, "d" )
		effectScript:RegisterEvent( 29, "fd" )
	end,

	sf = function( effectScript )
		SetAnimation(M001_auto627_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, M001_auto627_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 2, 100, "S200")
	end,

	fd = function( effectScript )
			DamageEffect(M001_auto627_attack.info_pool[effectScript.ID].Attacker, M001_auto627_attack.info_pool[effectScript.ID].Targeter, M001_auto627_attack.info_pool[effectScript.ID].AttackType, M001_auto627_attack.info_pool[effectScript.ID].AttackDataList, M001_auto627_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
