module chibs::guild{

    /* HERE IS THE GUILD STUFFS */

    //Errors
    #[error]
    const YOU_ARE_NOT_THE_ADMIN: u64 = 1;
    #[error]
    const YOU_ARE_NOT_MEMBER: u64 = 2;
    #[error]
    const ALREADY_A_MEMBER: u64 = 3;

    public struct Guild has key, store{
        id: UID,
        guildId: u64,
        name: std::ascii::String,
        admin: address,
        victories: u64,
        rank: std::ascii::String,
        members: vector<address>
    }


    //Public
    public fun create_guild(
        guildId: u64,
        guildName: std::ascii::String,
        ctx: &mut TxContext
    ): Guild 
    {
        let sender = tx_context::sender(ctx);

        Guild{
                id: object::new(ctx),
                guildId: guildId,
                name: guildName,
                admin: sender,
                victories: 0,
                rank: b"Rookies".to_ascii_string(),
                members: vector[sender]
        }
    }

    // Getters
    public fun get_guild_id(guild: &Guild): u64{
        guild.guildId
    }

    public fun get_guild_name(guild: &Guild): std::ascii::String
    {
        guild.name
    }

    public fun get_guild_admin(guild: &Guild): address{
        guild.admin
    }

    public fun get_guild_victories(guild: &Guild): u64{
        guild.victories
    }

    public fun get_guild_rank(guild: &Guild): std::ascii::String{
        guild.rank
    }

    public fun get_address_is_member(guild: &Guild, member: address): bool{
        guild.members.contains(&member)
    }

    //Setter
    public fun set_new_owner(guild: &mut Guild, newAdmin: address, ctx: &mut TxContext){
        is_admin(guild, ctx);
        guild.admin = newAdmin;

    }

    public fun add_new_member(guild: &mut Guild, newMember: address, ctx: &mut TxContext){
        is_member(guild, ctx);
        let valid = guild.members.contains(&newMember);
        assert!(!valid, ALREADY_A_MEMBER);
        guild.members.push_back(newMember);
    }

    //private
    fun is_admin(guild: &Guild, ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        assert!(sender == guild.admin, YOU_ARE_NOT_THE_ADMIN);
    }

    fun is_member(guild: &Guild, ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        let isMember = guild.get_address_is_member(sender);
        assert!(isMember, YOU_ARE_NOT_MEMBER);
    }

}