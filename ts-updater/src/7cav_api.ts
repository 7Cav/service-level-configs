// api.7cav.us/v1/users/active
export interface CavActive {
    data: Data;
    type: Type;
}

export interface Data {
    users: User[];
}

export interface User {
    user_id:             number;
    roster_id:           number;
    discord_id:          null | string;
    milpac_id:           number;
    real_name:           string;
    username:            string;
    uniform_url:         string;
    rank:                string;
    rank_id:             number;
    rank_image_url:      string;
    rank_shorthand:      string;
    status:              Type;
    primary_position:    string;
    secondary_positions: SecondaryPosition[];
    bio:                 string;
    join_date:           string;
    promotion_date:      string;
}

export interface SecondaryPosition {
    position_id:        number;
    position_title:     string;
    possible_secondary: number;
}

export enum Type {
    Active = "active",
}
