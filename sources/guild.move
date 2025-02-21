module chibs::guild{

    /* HERE IS THE GUILD STUFFS */

    public struct Guild has key, store{
        id: UID,
        guildId: u64,
        name: std::ascii::String,
        owner: address,
        victories: u64,
        rank: std::ascii::String,
        members: vector<address>
    }

    public struct GuildAdminCap has key, store{
        id: UID,
        guildId: u64
    }

    public struct GuildMember has key, store {
        id: UID,
        guildId: u64
    }

    //Public
    public fun create_guild(
        guildId: u64,
        guildName: std::ascii::String,
        ctx: &mut TxContext
    ): (Guild, GuildAdminCap, GuildMember) 
    {
        let sender = tx_context::sender(ctx);

        return (
            Guild{
                id: object::new(ctx),
                guildId: guildId,
                name: guildName,
                owner: sender,
                victories: 0,
                rank: b"Rookies".to_ascii_string(),
                members: vector[sender]
            },

            GuildAdminCap{
                id: object::new(ctx),
                guildId: guildId
            },

            GuildMember{
                id: object::new(ctx),
                guildId: guildId
            }

        )
    }

    public fun destroy_guild_emblem(
        emblem: GuildMember
    ){
        let GuildMember {
            id,
            guildId: _
        } = emblem;
        object::delete(id);
    }

    public fun destroy_guild_admin_emblem(
        emblem: GuildAdminCap
    ){
        let GuildAdminCap {
            id,
            guildId: _
        } = emblem;
        object::delete(id);
    }

    // Getters
    public fun get_guild_name(guild: &Guild): std::ascii::String
    {
        guild.name
    }

    public fun get_guild_id(guildAdminCap: &GuildAdminCap): u64{
        guildAdminCap.guildId
    }

    public fun get_address_is_member(guild: &Guild, member: &address): bool{
        guild.members.contains(member)
    }

    //Setter
    public fun set_new_owner(guild: &mut Guild, newOwner: address){
        guild.owner = newOwner;
    }
}