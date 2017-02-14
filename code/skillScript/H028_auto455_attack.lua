H028_auto455_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H028_auto455_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H028_auto455_attack.info_pool[effectScript.ID].Attacker)
        
		H028_auto455_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S390_2")
		PreLoadAvatar("S452_1")
		PreLoadAvatar("S442_8")
		PreLoadAvatar("S452_2")
		PreLoadAvatar("S442_shouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfdh" )
		effectScript:RegisterEvent( 18, "dsfdhdsg" )
		effectScript:RegisterEvent( 24, "sdfdhfjh" )
		effectScript:RegisterEvent( 32, "dsfdh" )
		effectScript:RegisterEvent( 35, "dfg" )
		effectScript:RegisterEvent( 39, "gddfhf" )
		effectScript:RegisterEvent( 43, "cdsg" )
	end,

	sdfdh = function( effectScript )
		SetAnimation(H028_auto455_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsfdhdsg = function( effectScript )
		AttachAvatarPosEffect(false, H028_auto455_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 135), 1, 100, "S390_2")
	end,

	sdfdhfjh = function( effectScript )
		AttachAvatarPosEffect(false, H028_auto455_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(70, 80), 1.2, 100, "S452_1")
	end,

	dsfdh = function( effectScript )
		AttachAvatarPosEffect(false, H028_auto455_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S442_8")
	end,

	dfg = function( effectScript )
		AttachAvatarPosEffect(false, H028_auto455_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(60, 80), 1, 100, "S452_2")
	end,

	gddfhf = function( effectScript )
		AttachAvatarPosEffect(false, H028_auto455_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "S442_shouji")
	end,

	cdsg = function( effectScript )
			DamageEffect(H028_auto455_attack.info_pool[effectScript.ID].Attacker, H028_auto455_attack.info_pool[effectScript.ID].Targeter, H028_auto455_attack.info_pool[effectScript.ID].AttackType, H028_auto455_attack.info_pool[effectScript.ID].AttackDataList, H028_auto455_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
