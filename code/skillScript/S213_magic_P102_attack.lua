S213_magic_P102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S213_magic_P102_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S213_magic_P102_attack.info_pool[effectScript.ID].Attacker)
       	if S213_magic_P102_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S213_magic_P102_attack.info_pool[effectScript.ID].Effect1);S213_magic_P102_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		S213_magic_P102_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0171")
		PreLoadAvatar("S212_3")
		PreLoadAvatar("S212_1")
		PreLoadAvatar("S212_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "dsfdsf" )
		effectScript:RegisterEvent( 18, "adsad" )
		effectScript:RegisterEvent( 19, "dsfd" )
		effectScript:RegisterEvent( 20, "sfdf" )
		effectScript:RegisterEvent( 21, "s" )
	end,

	a = function( effectScript )
		SetAnimation(S213_magic_P102_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0171")
	end,

	dsfdsf = function( effectScript )
		AttachAvatarPosEffect(false, S213_magic_P102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 80), 1.5, 100, "S212_3")
	end,

	adsad = function( effectScript )
		S213_magic_P102_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S213_magic_P102_attack.info_pool[effectScript.ID].Attacker, Vector2(130, -30), 3, 1000, 300, 1.5, S213_magic_P102_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "S212_1", effectScript)
	end,

	dsfd = function( effectScript )
		if S213_magic_P102_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S213_magic_P102_attack.info_pool[effectScript.ID].Effect1);S213_magic_P102_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	sfdf = function( effectScript )
		AttachAvatarPosEffect(false, S213_magic_P102_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.5, 100, "S212_2")
	end,

	s = function( effectScript )
			DamageEffect(S213_magic_P102_attack.info_pool[effectScript.ID].Attacker, S213_magic_P102_attack.info_pool[effectScript.ID].Targeter, S213_magic_P102_attack.info_pool[effectScript.ID].AttackType, S213_magic_P102_attack.info_pool[effectScript.ID].AttackDataList, S213_magic_P102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
