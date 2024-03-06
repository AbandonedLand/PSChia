chia rpc wallet did_get_metadata '{"wallet_id": 4}'

chia rpc wallet did_get_info '{"coin_id":"did:chia:1uwwldm73fyd6skygpljqwy8n0zkk35pts37yhrn6y9gxqpqxwqmql4amrd"}'

$data = @{
    "projects" = @{
       'Abandoned Land'=@{
            'website'='https://abandoned.land'
        }
        'The Great Wall of Chia'=@{
            'website'='https://thegreatwallofchia.com'
        }
    }
    "conatact" = @{
        'twitter'='@MayorAbandoned'
        'discord'='abandoned_land'
    }
}

$json = @{
    "wallet_id"=4
    "reuse_puzhash"=$true
    "metadata"=$data
    "fee"= [int64](.001*1000000000000)
} | ConvertTo-Json -Depth 9

chia rpc wallet did_update_metadata $json

