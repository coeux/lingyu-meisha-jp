H022_auto347_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H022_auto347_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H022_auto347_attack.info_pool[effectScript.ID].Attacker)
        
		H022_auto347_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S340_shifa")
		PreLoadAvatar("S340_fazhen")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "awdff" )
		effectScript:RegisterEvent( 14, "safdg" )
		effectScript:RegisterEvent( 15, "asdsfg" )
	end,

	awdff = function( effectScript )
		SetAnimation(H022_auto347_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	safdg = function( effectScript )
		AttachAvatarPosEffect(false, H022_auto347_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(25, 125), 1.2, -100, "S340_shifa")
	end,

	asdsfg = function( effectScript )
		AttachAvatarPosEffect(false, H022_auto347_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 10), 2, 100, "S340_fazhen")
	end,

}
