module chibs::chib{
    
    /* HERE IS THE CHARACTER STUFFS */

    //Errors
    #[error]
    const CHIB_IS_DEAD: u64 = 1;

    public struct Chib has key, store {
        id: UID,
        name: std::ascii::String,
        state: std::ascii::String,
        lvl: u64,
        xp: u64,
        hp: u64,
        atk: u64,
        mana: u64,
        victories: u64,
        rank: std::ascii::String,
        guild: option::Option<std::ascii::String>,
        guildId: u64,
        owner: address, 
    }

    //Public

    public fun create_chib(
        name: std::ascii::String,
        ctx: &mut TxContext
    ): Chib 
    {
        Chib{
            id: object::new(ctx),
            name: name,
            state: b"Alive".to_ascii_string(),
            lvl: 1,
            xp: 0,
            hp: 500,
            atk: 100,
            mana: 250,
            victories: 0,
            rank: b"Rookie".to_ascii_string(),
            guild: option::none<std::ascii::String>(),
            guildId: 0,
            owner: tx_context::sender(ctx)
        }
    }

    //Setters
    public fun change_name(chib: &mut Chib, newName: std::ascii::String){
        chib.name = newName;
    }

    public fun give_exp(chib: &mut Chib, amount: u64){
        check_state(chib);
        assert!(get_is_alive(chib), CHIB_IS_DEAD);
        chib.xp = chib.xp + amount;
        check_level(chib);
    }

    public fun gain_hp(chib: &mut Chib, amount: u64){
        chib.hp = chib.hp + amount;
    }

    public fun lose_hp(chib: &mut Chib, amount: u64){
        chib.hp = chib.hp - amount;
        check_state(chib);
    }

    public fun gain_mana(chib: &mut Chib, amount: u64){
        chib.mana = chib.mana + amount;
    }

    public fun lose_mana(chib: &mut Chib, amount: u64){
        chib.mana = chib.mana - amount;
        check_state(chib);
    }

    public fun set_attack(chib: &mut Chib, amount: u64){
        chib.atk = amount;
    }

    public fun add_attack(chib: &mut Chib, amount: u64){
        chib.atk = chib.atk + amount;
    }

    public fun decrease_attack(chib: &mut Chib, amount: u64){
        chib.atk = chib.atk - amount;
    }

    public fun set_guild_name(chib: &mut Chib, name: std::ascii::String){
        chib.guild.fill(name);
    }

    public fun set_guild_id(chib: &mut Chib, guildId: u64){
        chib.guildId = guildId;
    }

    public fun add_victory(chib: &mut Chib){
        chib.victories = chib.victories + 1;
        check_rank(chib);
    }

    public fun change_owner(chib: &mut Chib, newOwner: address){
        chib.owner = newOwner;
    }

    //Getters
    public fun get_name(chib: &Chib): std::ascii::String {
        chib.name
    }

    public fun get_is_alive(chib: &Chib): bool{
        chib.state != b"Dead".to_ascii_string()
    }

    public fun get_level(chib: &Chib): u64 {
        chib.lvl
    }

    public fun get_xp(chib: &Chib): u64 {
        chib.xp
    }

    public fun get_hp(chib: &Chib): u64{
        chib.xp
    }

    public fun get_mana(chib: &Chib): u64{
        chib.mana
    }

    public fun get_victories(chib: &Chib): u64{
        chib.victories
    }

    public fun get_rank(chib: &Chib): std::ascii::String{
        chib.rank
    }

    public fun get_have_guild(chib: &Chib): bool{
        // if in a guild returns true
        chib.guild.is_some()
    }

    public fun get_guild_id(chib: &Chib): u64{
        chib.guildId
    }


    //private
    fun check_level(chib: &mut Chib){
        if(chib.xp < 500){
            chib.lvl = 1;
            return
        }else if(chib.xp < 1100){
            chib.lvl = 2;
            return
        }else if(chib.xp < 2200){
            chib.lvl = 3;
            return
        }else if(chib.xp < 3300){
            chib.lvl = 4;
            return
        }else if(chib.xp < 5000){
            chib.lvl = 5;
            return
        }
    }

    fun check_state(chib: &mut Chib){
        if(chib.hp > 0 && chib.mana > 0){
            chib.state = b"Alive".to_ascii_string();
        }else if(chib.hp > 0 && chib.mana == 0){
            chib.state = b"Exhausted".to_ascii_string();
        }else{
            chib.state = b"Dead".to_ascii_string();
        }
    }

    fun check_rank(chib: &mut Chib){
        if(chib.victories < 3){
            chib.rank = b"Rookie".to_ascii_string();
            return
        }else if(chib.victories < 10) {
            chib.rank = b"Soldier".to_ascii_string();
            return
        }else if(chib.victories < 20){
            chib.rank = b"General".to_ascii_string();
            return
        }
    }
}



