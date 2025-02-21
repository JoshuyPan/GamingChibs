module chibs::chib{
    
    /* HERE IS THE CHARACTER STUFFS */

    //Errors
    #[error]
    const YOU_ALREADY_HAVE_GUILD: u64 = 1;

    public struct Chib has key, store {
        id: UID,
        name: std::ascii::String,
        lvl: u64,
        hp: u64,
        mana: u64,
        energy: u64,
        victories: u64,
        rank: std::ascii::String,
        guild: option::Option<std::ascii::String>,
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
            lvl: 1,
            hp: 500,
            mana: 250,
            energy: 100,
            victories: 0,
            rank: b"Rookie".to_ascii_string(),
            guild: option::none<std::ascii::String>(),
            owner: tx_context::sender(ctx)
        }
    }

    public fun add_guild_emblem(
        chib: &mut Chib,
        emblem: chibs::guild::GuildMember
    ){
        let name = b"guild_emblem".to_ascii_string();
        let haveGuild = sui::dynamic_object_field::exists_(&mut chib.id, name);
        assert!(haveGuild == false, YOU_ALREADY_HAVE_GUILD);
        sui::dynamic_object_field::add(&mut chib.id, name, emblem);
    }

    public fun add_guild_admin_emblem(
        chib: &mut Chib,
        emblem: chibs::guild::GuildAdminCap
    ){
        let name = b"guild_admin_emblem".to_ascii_string();
        let haveGuild = sui::dynamic_object_field::exists_(&mut chib.id, name);
        assert!(haveGuild == false, YOU_ALREADY_HAVE_GUILD);
        sui::dynamic_object_field::add(&mut chib.id, name, emblem);
    }

    public fun remove_guild_admin_emblem(
        chib: &mut Chib
    ): chibs::guild::GuildAdminCap
    {
        let name = b"guild_admin_emblem".to_ascii_string();
        sui::dynamic_object_field::remove(&mut chib.id, name)
    }

    public fun destroy_guild_admin_emblem(
        chib: &mut Chib
    )
    {
        let name = b"guild_admin_emblem".to_ascii_string();
        let emblem = sui::dynamic_object_field::remove(&mut chib.id, name);
        chibs::guild::destroy_guild_admin_emblem(emblem);
    }

    public fun destroy_guild_emblem(
        chib: &mut Chib
    )
    {
        let name = b"guild_emblem".to_ascii_string();
        let emblem = sui::dynamic_object_field::remove(&mut chib.id, name);
        chibs::guild::destroy_guild_emblem(emblem);
    }

    //Setters
    public fun set_guild_name(chib: &mut Chib, name: std::ascii::String){
        chib.guild.fill(name);
    }

    //Getters
    public fun get_guild_is_member(chib: &mut Chib): bool
    {
        let name = b"guild_emblem".to_ascii_string();
        sui::dynamic_object_field::exists_(&mut chib.id, name)
    }

    public fun get_guild_is_admin(chib: &mut Chib): bool
    {
        let name = b"guild_admin_emblem".to_ascii_string();
        sui::dynamic_object_field::exists_(&mut chib.id, name)
    }
}



