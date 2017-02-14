S588_magic_M011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S588_magic_M011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S588_magic_M011_attack.info_pool[effectScript.ID].Attacker)
       	if S588_magic_M011_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S588_magic_M011_attack.info_pool[effectScript.ID].Effect1);S588_magic_M011_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		S588_magic_M011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S569_1")
		PreLoadAvatar("S569_3")
		PreLoadAvatar("S569_2")
		PreLoadAvatar("M011_pugong_1")
		PreLoadAvatar("S569_5")
		PreLoadAvatar("S568_3")
		PreLoadAvatar("S569_6")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdg" )
		effectScript:RegisterEvent( 4, "dsgfdg" )
		effectScript:RegisterEvent( 5, "dgh" )
		effectScript:RegisterEvent( 14, "sdggh" )
		effectScript:RegisterEvent( 15, "dsgh" )
		effectScript:RegisterEvent( 16, "fdgh" )
		effectScript:RegisterEvent( 17, "fdh" )
		effectScript:RegisterEvent( 46, "dghgjhgk" )
		effectScript:RegisterEvent( 49, "dsfdgfdh" )
		effectScript:RegisterEvent( 53, "dfgfh" )
	end,

	dsfdg = function( effectScript )
		SetAnimation(S588_magic_M011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dsgfdg = function( effectScript )
		AttachAvatarPosEffect(false, S588_magic_M011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 0.8, -100, "S569_1")
	end,

	dgh = function( effectScript )
		AttachAvatarPosEffect(false, S588_magic_M011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 10), 1.2, -100, "S569_3")
	AttachAvatarPosEffect(false, S588_magic_M011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, -20), 0.8, 100, "S569_2")
	end,

	sdggh = function( effectScript )
		S588_magic_M011_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S588_magic_M011_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 0), 3, 800, 300, 1, S588_magic_M011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-50, 0), "M011_pugong_1", effectScript)
	end,

	dsgh = function( effectScript )
		if S588_magic_M011_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S588_magic_M011_attack.info_pool[effectScript.ID].Effect1);S588_magic_M011_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	fdgh = function( effectScript )
		AttachAvatarPosEffect(false, S588_magic_M011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1, 100, "S569_5")
	end,

	fdh = function( effectScript )
			DamageEffect(S588_magic_M011_attack.info_pool[effectScript.ID].Attacker, S588_magic_M011_attack.info_pool[effectScript.ID].Targeter, S588_magic_M011_attack.info_pool[effectScript.ID].AttackType, S588_magic_M011_attack.info_pool[effectScript.ID].AttackDataList, S588_magic_M011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dghgjhgk = function( effectScript )
		AttachAvatarPosEffect(false, S588_magic_M011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(120, 0), 0.8, 100, "S568_3")
	end,

	dsfdgfdh = function( effectScript )
		AttachAvatarPosEffect(false, S588_magic_M011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 20), 1.5, 100, "S569_6")
	end,

	dfgfh = function( effectScript )
			DamageEffect(S588_magic_M011_attack.info_pool[effectScript.ID].Attacker, S588_magic_M011_attack.info_pool[effectScript.ID].Targeter, S588_magic_M011_attack.info_pool[effectScript.ID].AttackType, S588_magic_M011_attack.info_pool[effectScript.ID].AttackDataList, S588_magic_M011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
