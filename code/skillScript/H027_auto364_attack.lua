H027_auto364_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H027_auto364_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H027_auto364_attack.info_pool[effectScript.ID].Attacker)
        
		H027_auto364_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S360_11")
		PreLoadAvatar("S360_2")
		PreLoadAvatar("S360_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gfh" )
		effectScript:RegisterEvent( 16, "hgj" )
		effectScript:RegisterEvent( 22, "fgh" )
		effectScript:RegisterEvent( 27, "fdgfh" )
		effectScript:RegisterEvent( 30, "dgh" )
	end,

	gfh = function( effectScript )
		SetAnimation(H027_auto364_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	hgj = function( effectScript )
		AttachAvatarPosEffect(false, H027_auto364_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 70), 1, 100, "S360_11")
	end,

	fgh = function( effectScript )
		AttachAvatarPosEffect(false, H027_auto364_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 75), 1, 100, "S360_2")
	end,

	fdgfh = function( effectScript )
		AttachAvatarPosEffect(false, H027_auto364_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S360_3")
	end,

	dgh = function( effectScript )
			DamageEffect(H027_auto364_attack.info_pool[effectScript.ID].Attacker, H027_auto364_attack.info_pool[effectScript.ID].Targeter, H027_auto364_attack.info_pool[effectScript.ID].AttackType, H027_auto364_attack.info_pool[effectScript.ID].AttackDataList, H027_auto364_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
