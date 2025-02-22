module chibs::bad_dudes{
    
    public struct BadDude has key, store{
        id: UID,
        name: std::ascii::String,
        hp: u64,
        atk: u64,
    }

    public fun create_bad_dude(name: std::ascii::String, hp: u64, atk: u64, ctx: &mut TxContext): BadDude{
        BadDude{
            id: object::new(ctx),
            name,
            hp,
            atk
        }
    }

    //getters
    public fun get_name(bdude: &BadDude): std::ascii::String{
        bdude.name
    }

    public fun get_hp(bdude: &BadDude): u64{
        bdude.hp
    }

    public fun get_atk(bdude: &BadDude): u64{
        bdude.atk
    }

    //Helper
    public fun destroy_bad_dude(bdude: BadDude){
        let BadDude{
            id,
            name: _,
            hp: _,
            atk: _
        } = bdude;
        object::delete(id);
    }
}