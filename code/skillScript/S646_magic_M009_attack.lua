S646_magic_M009_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S646_magic_M009_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S646_magic_M009_attack.info_pool[effectScript.ID].Attacker)
        
		S646_magic_M009_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S646_1")
		PreLoadAvatar("S646_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fgdsh" )
		effectScript:RegisterEvent( 11, "gfhhhh" )
		effectScript:RegisterEvent( 36, "ghfh" )
	end,

	fgdsh = function( effectScript )
		SetAnimation(S646_magic_M009_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	gfhhhh = function( effectScript )
		AttachAvatarPosEffect(false, S646_magic_M009_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S646_1")
	end,

	ghfh = function( effectScript )
		AttachAvatarPosEffect(false, S646_magic_M009_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(130, 110), 1, 100, "S646_2")
	end,

}
