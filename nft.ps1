Function Invoke-WalletNftAddUri {
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id,
        [Parameter(Mandatory=$true)]
        $nft_coin_id,
        [Parameter(Mandatory=$true)]
        $key,
        [Parameter(Mandatory=$true)]
        $uri,
        $fee,
        [swicth]
        $reuse_puzhash
    )

    $json = @{
        wallet_id = $wallet_id
        nft_coin_id = $nft_coin_id
        key = $key
        uri = $uri
    }

    if($fee){
        $json.Add('fee',$fee)
    }

    if($reuse_puzhash.IsPresent){
        $json.Add('reuse_puzhash',$true)
    } else {
        $json.Add('reuse_puzhash',$false)
    }

    $json = $json | ConvertTo-Json
    
    chia rpc wallet nft_add_uri $json | ConvertFrom-Json

}

Function Invoke-WalletNftCalculateRoyalties {
    param(
        $royalty_assets,
        $fungible_assets
    )


}

Function Invoke-WalletNftCountNfts{
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id
    )
    $json = @{
        wallet_id = $wallet_id
    } | ConvertTo-Json

    chia rpc wallet nft_count_nfts $json | ConvertFrom-Json
    
}

Function Invoke-WalletNftGetByDid{
    param(
        [Parameter(Mandatory=$true)]
        $did_id
    )

    $json = @{
        did_id=$did_id
    } | ConvertTo-Json

    chia rpc wallet nft_get_by_did $json | ConvertFrom-Json
}


Function Invoke-WalletNftGetInfo{
    param(
        [Parameter(Mandatory=$true)]
        [string]$coin_id,
        [string]$wallet_id
    )

    $json = @{
        coin_id = $coin_id
    }
    if($wallet_id){
        $json.Add('wallet_id',$wallet_id)
    }
    $json = $json | ConvertTo-Json

    chia rpc wallet nft_get_info $json | ConvertFrom-Json
}

Function Invoke-WalletNftGetNfts{
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id,
        $start_index,
        $num,
        [switch]
        $ignore_size_limit
    )

    $json = @{
        wallet_id = $wallet_id
    }
    if($start_index){
        $json.Add('start_index',$start_index)
    }
    if($num){
        $json.Add('num',$num)
    }
    if($ignore_size_limit.IsPresent){
        $json.Add('ignore_size_limit',$true)
    }
    $json = $json | ConvertTo-Json

    chia rpc wallet nft_get_nfts $json | ConvertFrom-Json
}

Function Invoke-WalletNftGetWalletsWithDids {
   chia rpc wallet nft_get_wallets_with_dids  | ConvertFrom-Json
}

Function Invoke-WalletNftGetWalletDid{
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id
    )

    $json = @{
        wallet_id = $wallet_id
    } 

    $json = $json | ConvertTo-Json

    chia rpc wallet nft_get_wallet_did $json | ConvertFrom-Json
}

Function Invoke-WalletNftMintBulk {
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id,
        [Parameter(Mandatory=$true)]
        $metadata_list,
        $royalty_percentage,
        $royalty_address,
        $target_list,
        $mint_number_start,
        $mint_total,
        $xch_coin_list,
        $xch_change_target,
        $new_innerpuzhash,
        $new_p2_puzhash,
        $did_coin_dict,
        $did_lineage_parent_hex,
        [switch]
        $mint_from_did,
        $fee,
        [switch]
        $reuse_puzhash
    )
    $json = @{
        wallet_id = $wallet_id
        metadata_list = $metadata_list
    }

    if($metadata_list){
        $json.Add('metadata_list',$metadata_list)
    }
    if($royalty_percentage){
        $json.Add('royalty_percentage',$royalty_percentage)
    }
    if($royalty_address){
        $json.Add('royalty_address',$royalty_address)
    }
    if($target_list){
        $json.Add('target_list',$target_list)
    }
    if($mint_number_start){
        $json.Add('mint_number_start',$mint_number_start)
    }
    if($mint_total){
        $json.Add('mint_total',$mint_total)
    }
    if($xch_coin_list){
        $json.Add('xch_coin_list',$xch_coin_list)
    }
    if($xch_change_target){
        $json.Add('xch_change_target',$xch_change_target)
    }
    if($new_innerpuzhash){
        $json.Add('new_innerpuzhash',$new_innerpuzhash)
    }
    if($new_p2_puzhash){
        $json.Add('new_p2_puzhash',$new_p2_puzhash)
    }
    if($did_coin_dict){
        $json.Add('did_coin_dict',$did_coin_dict)
    }
    if($did_lineage_parent_hex){
        $json.Add('did_lineage_parent_hex',$did_lineage_parent_hex)
    }
    if($mint_from_did.IsPresent){
        $json.Add('mint_from_did',$true)
    }
    if($fee){
        $json.Add('fee',$fee)
    } else{
        $json.Add('fee',0)
    }
    if($reuse_puzhash.IsPresent){
        $json.Add('reuse_puzhash',$true)
    }
    
    $json = $json | ConvertTo-Json -Depth 20

    chia rpc wallet nft_mint_bulk $json | ConvertFrom-Json


}

Function Invoke-WalletNftMintNft {
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id,
        [Parameter(Mandatory=$true)]
        $uris,
        [Parameter(Mandatory=$true)]
        $hash,
        $royalty_address,
        $target_address,
        $meta_uris,
        $license_uris,
        $edition_number,
        $edition_total,
        $fee,
        $meta_hash,
        $license_hash,
        $did_id,
        $royalty_percentage,
        $reuse_puzhash
    )

    $json = @{
        wallet_id = $wallet_id
        uris = $uris
        hash = $hash
    }

    if($royalty_address){
        $json.Add('royalty_address',$royalty_address)
    }
    if($target_address){
        $json.Add('target_address',$target_address)
    }
    if($meta_uris){
        $json.Add('meta_uris',$meta_uris)
    }
    if($license_uris){
        $json.Add('license_uris',$meta_uris)
    }
    if($edition_number){
        $json.Add('edition_number',$edition_number)
    }
    if($fee){
        $json.Add('fee',$fee)
    } else {
        $json.Add('fee',0)
    }
    if($meta_hash){
        $json.Add('meta_hash',$meta_hash)
    }
    if($license_hash){
        $json.Add('license_hash',$license_hash)
    }
    if($did_id){
        $json.Add('did_id',$did_id)
    }
    if($royalty_percentage){
        $json.Add('royalty_percentage',$royalty_percentage)
    }
    if($reuse_puzhash){
        $json.Add('reuse_puzhash',$reuse_puzhash)
    }

    $json = $json | ConvertTo-Json
    chia rpc wallet nft_mint_nft $json | ConvertFrom-Json
}