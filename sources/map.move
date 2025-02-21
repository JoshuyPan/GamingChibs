module chibs::map{

    /* HERE IS THE MAP STUFFS */

    public struct Map has key, store{
        id: UID,
        name: std::ascii::String,
        owner: option::Option<chibs::guild::Guild>,
        tiles: vector<vector<Tile>>,
        isOpen: bool
    }
    
    public struct Tile has key, store{
        id: UID,
        owner: option::Option<chibs::guild::Guild>,
        attack: u64,
        team0: sui::balance::Balance<sui::sui::SUI>,
        team1: sui::balance::Balance<sui::sui::SUI>,
        funders: vector<address>,
        timeStamp: u64
    }

    public fun instantiate_map(
        ctx: &mut TxContext
    ): Map
    {
        let tile = Tile{
            id: object::new(ctx),
            owner: option::none<chibs::guild::Guild>(),
            attack: 100,
            team0: sui::balance::zero(),
            team1: sui::balance::zero(),
            funders: vector[],
            timeStamp: 100
        };
        Map{
            id: sui::object::new(ctx),
            name: b"Eurasia".to_ascii_string(),
            owner: option::none<chibs::guild::Guild>(),
            tiles: vector[vector[tile]],
            isOpen: true
        }
    }

    
}