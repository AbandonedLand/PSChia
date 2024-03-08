Function Invoke-WalletAddKey {
    param(
        [Parameter(Mandatory=$true)]
        [array]$mnemonic
    )

    $json = @{
        mnemonic=$mnemonic
    } | ConvertTo-Json

    chia rpc wallet add_key $json | ConvertFrom-Json
}

Function Invoke-WalletCheckDeleteKey {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$fingerprint,
        [int64]$max_ph_to_search
    )

    $json = @{
        fingerprint = $fingerprint
    }

    if($max_ph_to_search) {
        $json.Add("max_ph_to_search" , $max_ph_to_search)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet check_delete_key $json | ConvertFrom-Json

}

Function Invoke-WalletDeleteAllKeys {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$fingerprint
    )

    $json = @{
        fingerprint = $fingerprint
    } | ConvertTo-Json

    chia rpc wallet delete_all_keys $json | ConvertFrom-Json
}

Function Invoke-WalletGenerateMnemonic {

    chia rpc wallet generate_mnemonic | ConvertFrom-Json
}

Function Invoke-WalletGetLoggedInFingerprint {

    chia rpc wallet get_logged_in_fingerprint | ConvertFrom-Json
}

Function Invoke-WalletGetPrivateKey {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$fingerprint
    )

    $json = @{
        fingerprint = $fingerprint
    } | ConvertTo-Json

    chia rpc wallet get_private_key $json | ConvertFrom-Json

}

Function Invoke-WalletGetPublicKeys {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$fingerprint
    )

    $json = @{
        fingerprint = $fingerprint
    } | ConvertTo-Json

    chia rpc wallet get_public_keys $json | ConvertFrom-Json

}

Function Invoke-WalletLogIn {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$fingerprint
    )

    $json = @{
        fingerprint = $fingerprint
    } | ConvertTo-Json

    chia rpc wallet log_in $json | ConvertFrom-Json
}




Function Invoke-WalletGetAutoClaim {

    chia rpc wallet get_auto_claim | ConvertFrom-Json
}

Function Invoke-WalletGetHeightInfo {

    chia rpc wallet get_height_info | ConvertFrom-Json
}

Function Invoke-WalletGetNetworkInfo {

    chia rpc wallet get_network_info | ConvertFrom-Json
}

Function Invoke-WalletGetSyncStatus {

    chia rpc wallet get_sync_status | ConvertFrom-Json
}

Function Invoke-WalletGetTimestampForHeight{
    param(
        [Parameter(Mandatory=$true)]
        [Int64]$height
    )

    $json = @{
        height=$height
    } | ConvertTo-Json

    chia rpc wallet get_timestamp_for_height $json | ConvertFrom-Json
}

Function Invoke-WalletPushTx {
    param(
        [Parameter(Mandatory=$true)]
        [string]$spend_bundle
    )

    $json = @{
        spend_bundle = $spend_bundle
    } | ConvertTo-Json

    chia rpc wallet push_tx $json
}

Function Invoke-WalletSetWalletResyncOnStartup {

    chia rpc wallet set_wallet_resync_on_startup | ConvertFrom-Json
}



Function Set-AutoClaim{
    param(
        [Parameter(Mandatory=$true,ParameterSetName='Enable')]
        [switch]
        $enabled,
        [Parameter(Mandatory=$true,ParameterSetName='Disable')]
        [switch]
        $disabled,
        [decimal]$tx_fee,
        [decimal]$min_amount,
        [Int64]$batch_size
    )

    $json = @{} 
    if($enabled.IsPresent){
        $json.Add('enabled',$true)
    }
    if($disabled.IsPresent){
        $json.Add('enabled',$false)
    }
    if($tx_fee){
        $json.Add('tx_fee',$tx_fee)
    }
    if($min_amount){
        $json.Add('min_amount',$min_amount)
    }
    if($batch_size){
        $json.Add('batch_size',$batch_size)
    }


    $json = $json | ConvertTo-Json

    chia rpc wallet set_auto_claim $json | ConvertFrom-Json
}


Function Invoke-WalletCreateNewWallet {
    param(
        [Parameter(Mandatory=$true,ParameterSetName = 'walletType')]
        [ValidateSet("cat_wallet","did_wallet","nft_wallet","pool_wallet")]
        [string]$wallet_type,
        
        
        [Parameter(ParameterSetName='walletType')]
        [ValidateSet("new","existing")]
        [string]$mode = $(if($wallet_type -eq "cat_wallet"){Throw "-Mode must be set with wallet_type of cat_wallet"}),
        
        [string]$name,
        
        [Parameter(ParameterSetName='walletType')]
        [decimal]$amount = $(
            if($mode -eq "new") {Throw "-amount must be set if mode is set to new"}
            if($did_type -eq "new") {Throw "-amount must be set if did_type -eq new"}
            ),
        
        [Parameter(ParameterSetName='walletType')]
        [string]$asset_id = $(if($mode -eq "existing") {Throw "-asset_id must be set if mode is set to existing"}),
        
        [Parameter(ParameterSetName = 'walletType')]
        [ValidateSet("new","recovery")]
        [string]$did_type = $(if($wallet_type -eq 'did_wallet'){Throw "-did_type must be set if wallet_type is set to did_wallet"}),

        [Parameter(ParameterSetName = 'walletType')]
        [array]$backup_dids = $(if($did_type -eq "new"){Throw "-backup_dids must be set if did_type is set to new"}),

        [Parameter(ParameterSetName = 'walletType')]
        [int]$num_of_backup_ids_needed = $(if($did_type -eq "new"){Throw "-num_of_backup_ids_needed is required if did_type -eq new"}),

        [Parameter(ParameterSetName = 'walletType')]
        [string]$did_id = $(if($wallet_type -eq "nft_wallet") {Throw "-did_id must be set if wallet_type -eq nft_wallet"}),


        $metadata,
        

        [int64]$fee
    
    )
    
    $json = @{
        "wallet_type" = $wallet_type
    }
    if($wallet_type -eq "cat_wallet"){
        $json.Add("mode",$mode)
        if($mode -eq "new"){
            $json.Add("amount",$amount)
        }
        if($mode -eq "existing"){
            $json.Add("asset_id",$asset_id)
        }
        if($name){
            $json.Add("name",$name)
        }
    }

    if($wallet_type -eq "nft_wallet"){
        $json.Add("did_id",$did_id)
        if($name){
            $json.Add("name",$name)
        }
    }
    
    if($wallet_type -eq "did_wallet"){
        $json.Add('did_type',$did_type)
        if($did_type -eq 'new'){
            $json.Add("backup_dids",$backup_dids)
            $json.Add("num_of_backup_ids_needed",$num_of_backup_ids_needed)
            $json.Add("wallet_name",$name)
            $json.Add("amount",$amount)
        }
    }

    if($fee){
        $json.add("fee",$fee)
    }

    $json = $json | ConvertTo-Json
    
    chia rpc wallet create_new_wallet $json | ConvertFrom-Json
    }

Function Invoke-WalletGetWallets {
    param(
        [switch]
        $exclude_data,
        [Int16]$type
    )

    $json = @{}
    if($exclude_data.IsPresent){
        $json.Add('include_data',$false)
    }
    if($type){
        $json.Add('type',$type)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet get_wallets $json | ConvertFrom-Json -Depth 10

}

Function Invoke-WalletCreateSignedTransaction {
    param(
        [Parameter(Mandatory=$true)]
        [int]$wallet_id,
        [Parameter(Mandatory=$true)]
        $additions,
        [int64]$min_coin_amount,
        [int64]$max_coin_amount,
        $excluded_coin_amounts,
        
        $coins,
        
        $excluded_coins,
        $coin_announcements,
        $puzzle_announcements,
        [int64]$fee

    )

    $json = @{
        "wallet_id" = $wallet_id
        "additions" = $additions
        "fee" = 0
    } 

    if($coins){
        $json.Add("coins",$coins)
    }
    if($excluded_coins){
        $json.Add("excluded_coins",$excluded_coins)
    }

    $json = $json | ConvertTo-Json -Depth 10

    $json
    chia rpc wallet create_signed_transaction $json | ConvertFrom-Json
}


Function Invoke-WalletDeleteNotification {
    param(
        $ids
    )

    $json = @{}
    if($ids){
        $json.Add("ids",$ids)
    }
    $json = $json | ConvertTo-Json
    chia rpc wallet delete_notifications $json | ConvertFrom-Json
}

Function Invoke-WalletDeleteUnconfirmedTransactions {
    param(
        [Parameter(Mandatory=$true)]
        [int]$wallet_id
    )

    $json = @{
        wallet_id=$wallet_id
    } | ConvertTo-Json

    chia rpc wallet delete_unconfirmed_transactions $json | ConvertFrom-Json

}

Function Invoke-WalletExtendDerivationIndex {
    param(
        [Parameter(Mandatory=$true)]
        [int32]$index
    )

    $json = @{
        index=$index
    } | ConvertTo-Json

    chia rpc wallet extend_derivation_index $json | ConvertFrom-Json

}


Function Invoke-WalletGetCoinRecords {
    chia rpc wallet get_coin_records | ConvertFrom-Json
}



Function Invoke-WalletGetCoinRecordsByName {
    param(
        [Parameter(Mandatory=$true)]
        [array]$names,
        [int64]$start_height,
        [int64]$end_height,
        [switch]
        $include_spent_coins
    )

    $json = @{
        names = $names
    }
    if($start_height){
        $json.Add("start_height",$start_height)
    }
    if($end_height){
        $json.Add("end_height",$end_height)
    }
    if($include_spent_coins.IsPresent){
        $json.Add("include_spent_coins",$true)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet get_coin_records_by_names $json | ConvertFrom-Json

}


Function Invoke-WalletGetCurrentDerivationIndex {
    chia rpc wallet get_current_derivation_index | ConvertFrom-Json
}

Function Invoke-WalletGetFarmedAmount {
    chia rpc wallet get_farmed_amount | ConvertFrom-Json
}

Function Invoke-WalletGetNextAddress {
    param(
        [Parameter(Mandatory=$true)]
        [int]$wallet_id,
        [switch]
        $new_address
    )

    $json = @{
        wallet_id=$wallet_id
    }
    if($new_address.IsPresent){
        $json.Add("new_address",$true)
    } else {
        $json.Add("new_address",$false)
    }
    $json = $json | ConvertTo-Json
    chia rpc wallet get_next_address $json | ConvertFrom-Json
}

Function Invoke-WalletGetNotifications {
    param(
        $ids,
        [int64]$start,
        [int64]$end
    )

    $json = @{}
    if($ids){
        $json.Add("ids",$ids)
    }
    if($start){
        $json.Add("start",$start)
    }
    if($end){
        $json.Add("end",$end)
    }
    $json = $json | ConvertTo-Json

    chia rpc wallet get_notifications $json | ConvertFrom-Json

}

Function Invoke-WalletGetSpendableCoins {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$wallet_id,
        [Int64]$min_coin_amount,
        [Int64]$max_coin_amount,
        [Int64]$excluded_coin_amounts,
        [array]$excluded_coins,
        [array]$excluded_coin_ids
    )

    $json = @{
        wallet_id=$wallet_id
    }

    if($min_coin_amount){
        $json.Add("min_coin_amount",$min_coin_amount)
    }
    if($max_coin_amount){
        $json.Add("max_coin_amount",$max_coin_amount)
    }
    if($excluded_coin_amounts) {
        $json.Add("excluded_coin_amounts",$excluded_coin_amounts)
    }
    if($excluded_coins) {
        $json.Add("excluded_coins",$excluded_coins)
    }
    if($excluded_coin_ids){
        $json.Add("excluded_coin_ids",$excluded_coin_ids)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet get_spendable_coins $json | ConvertFrom-Json

}

Function Invoke-WalletGetTransaction{
    param(
        [Parameter(Mandatory=$true)]
        [string]$transaction_id
    )

    $json = @{
        transaction_id=$transaction_id
    } | ConvertTo-Json

    return chia rpc wallet get_transaction $json | ConvertFrom-Json
}




Function Invoke-WalletGetTransactionCount{
    param(
        [Parameter(Mandatory=$true)]
        [int64]$wallet_id
    )

    $json = @{
        wallet_id=$wallet_id
    } | ConvertTo-Json

    return chia rpc wallet get_transaction_count $json | ConvertFrom-Json
}

Function Invoke-WalletGetTransactions {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$wallet_id,
        [int64]$start,
        [int64]$end
    )

    $json = @{
        wallet_id=$wallet_id;
    }
    if($start){
        $json.Add("start",$start)
    }
    if($end){
        $json.Add("end",$end)
    }
    $json = $json | ConvertTo-Json

    return chia rpc wallet get_transactions $json | ConvertFrom-Json
}

Function Invoke-WalletGetTransactionMemo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$transaction_id,
        [switch]
        $readable
    )

    $json = @{
        transaction_id=$transaction_id
    } | ConvertTo-Json

    $memo = chia rpc wallet get_transaction_memo $json | ConvertFrom-Json
    if($readable.IsPresent){
        ConvertFrom-Hex -hex ((($memo | ConvertTo-Json).Split("[")[1]).split("]")[0]).Trim().Replace("`"","")
    } else {
        $memo
    }
    
}

Function Invoke-WalletGetWalletBalance {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$wallet_id 
    )
    $json = @{
        wallet_id=$wallet_id
    } | ConvertTo-Json

    chia rpc wallet get_wallet_balance $json | ConvertFrom-Json
}

Function Invoke-WalletGetWalletBalances {
    param(
        [int64]$wallet_ids
    )
    $json = @{}
    if($wallet_ids){
        $json.Add("wallet_ids",$wallet_ids)
    }
        
    $json = $json | ConvertTo-Json

    chia rpc wallet get_wallet_balances $json | ConvertFrom-Json
}

Function Invoke-WalletSelectCoins {
    param(
        [Parameter(Mandatory=$true)]
        [int64]$wallet_id,
        [Parameter(Mandatory=$true)]
        [decimal]$amount,
        [decimal]$min_coin_amount,
        [decimal]$max_coin_amount,
        $excluded_coin_amounts,
        $excluded_coins
    )

    $json = @{
        wallet_id = $wallet_id;
        amount = $amount
    }
    if($min_coin_amount){
        $json.Add("min_coin_amount",$min_coin_amount)
    }
    if($max_coin_amount){
        $json.Add("max_coin_amount",$max_coin_amount)
    }
    if($excluded_coin_amounts) {
        $json.Add("excluded_coin_amounts",$excluded_coin_amounts)
    }
    if($excluded_coins) {
        $json.Add("excluded_coins",$excluded_coins)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet select_coins $json | ConvertFrom-Json

}

Function Invoke-WalletSendNotification {
    param(
        [Parameter(Mandatory=$true)]
        [string]$target,
        [Parameter(Mandatory=$true)]
        [string]$message,
        [Parameter(Mandatory=$true)]
        [decimal]$amount,
        [decimal]$fee
    )

    $json = @{
        target=$target
        message = (ConvertTo-Hex -string $message)
        amount = $amount
    }
    if($fee){
        $json.Add("fee",$fee)
    }
    $json = $json | ConvertTo-Json

    chia rpc wallet send_notification $json | ConvertFrom-Json

}

Function Invoke-WalletSendTransaction {
    param(
        [Parameter(Mandatory=$true)]
        [int]$wallet_id,
        [Parameter(Mandatory=$true)]
        [string]$address,
        [Parameter(Mandatory=$true)]
        [decimal]$amount,
        [int64]$fee,
        [array]$memos,
        [decimal]$min_coin_amount,
        [decimal]$max_coin_amount,
        [array]$excluded_coin_amounts,
        [array]$excluded_coin_ids,
        [swith]
        $reuse_puzhash
    )

    $json = @{
        wallet_id = $wallet_id
        address = $address
        amount = $amount
    }
    if($fee) {
        $json.Add("fee",$fee)
    }
    if($memos){
        $json.Add("memos",$memos)
    }
    if($min_coin_amount){
        $json.Add("min_coin_amount",$min_coin_amount)
    }
    if($max_coin_amount){
        $json.Add("max_coin_amount",$max_coin_amount)
    }
    if($excluded_coin_amounts){
        $json.Add("excluded_coin_amounts",$excluded_coin_amounts)
    }
    if($excluded_coin_ids){
        $json.Add("excluded_coin_ids",$excluded_coin_ids)
    }
    if($reuse_puzhash.IsPresent){
        $json.Add("reuse_puzhash",$true)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet send_transaction $json | ConvertFrom-Json

}

Function Invoke-WalletSendTransactionMulti {
    param(
        [Parameter(Mandatory=$true)]
        [int]$wallet_id,
        [int64]$fee,
        [array]$additions,
        [switch]$as_file,
        [string]$path
    )
    <#
    $additions = @(
        @{
            "amount"=100
            "puzzle_hash"= '32e7a53316929bb0b7eb5e5c940602d0bfc71e41953cc8bceebe394590fa35fe'
            "memos" = @()
        },
        @{
            "amount"=100
            "puzzle_hash"= '707e56d390a48bbd7a1f52f24d76cb4bb29f72c6511ab5b12c7b0e5beae0a215'
            "memos" = @()
        }
    )
    #>

    $json = @{
        "wallet_id"=$wallet_id
    }
    if($fee){
        $json.Add("fee",$fee)
    } else {
        $json.Add("fee",0)
    }
    if($memos){
        $json.Add("memos",$memos)
    }
    if($additions){
        $json.Add("additions",$additions)
    }

   

    $json = $json | ConvertTo-Json -Depth 9

    if($as_file.IsPresent){
        if($path.Length -gt 0){
            $json | Out-File $path
            chia rpc wallet send_transaction_multi -j $path | ConvertFrom-Json
        } else {
            chia rpc wallet send_transaction_multi $json | ConvertFrom-Json
        }
        
    }
    else {
        chia rpc wallet send_transaction_multi $json | ConvertFrom-Json
    }

    

}

Function Invoke-WalletSignMessageByAddress {
    param(
        [Parameter(Mandatory=$true)]
        [decimal]$address,
        [Parameter(Mandatory=$true)]
        [string]$message
    )

    $json = @{
        address=$address
        message=$message
    } | ConvertTo-Json

    chia rpc wallet sign_message_by_address $json | ConvertFrom-Json
}

Function Invoke-WalletSignMessageById {
    param(
        [Parameter(Mandatory=$true)]
        $id,
        [Parameter(Mandatory=$true)]
        $message
    )

    $json = @{
        "id"=$id
        "message"=$message
    } | ConvertTo-Json

    chia rpc wallet sign_message_by_id $json | ConvertFrom-Json
}

Function Invoke-WalletVerifySignature {
    param(
        $signing_mode,    
        [Parameter(Mandatory=$true)]
        $pubkey,
        [Parameter(Mandatory=$true)]
        $message,
        [Parameter(Mandatory=$true)]
        $signature,
        [Parameter(Mandatory=$true)]
        $address
    )

    $json = @{
        "pubkey"=$pubkey
        "message"=$message
        "signature"=$signature
        "address"=$address
    }
    if($signing_mode){
        $json.Add("signing_mode",$signing_mode)
    }

    $json = $json | ConvertTo-Json
    
    chia rpc wallet verify_signature $json | ConvertFrom-Json
}

Function Invoke-WalletCancelOffer {
    param(
        [switch]
        $secure,
        [Parameter(Mandatory=$true)]
        $trade_id,
        $fee
    )

    $json = @{
        "trade_id"=$trade_id
    }

    if($secure.IsPresent){
        $json.Add("secure",$true)
    } else {
        $json.Add("secure",$false)
    }

    if($fee){
        $json.Add("fee",$fee)
    }

    $json = $json | ConvertTo-Json
    
    chia rpc wallet cancel_offer $json | ConvertFrom-Json
}

Function Invoke-WalletCancelOffers {
    param(
        [switch]
        $secure,
        $batch_fee,
        $batch_size,
        [switch]
        $cancel_all,
        $asset_id
    )

    $json = @{}

    if($secure.IsPresent){
        $json.Add("secure",$true)
    } else {
        $json.Add("secure",$false)
    }
    if($batch_fee) {
        $json.Add("batch_fee",$batch_fee)
    }
    if($batch_size) {
        $json.Add("batch_size",$batch_size)
    }
    if($cancel_all.IsPresent){
        $json.Add("cancel_all",$true)
    } else {
        $json.Add("cancel_all",$false)
    }
    if($asset_id){
        $json.Add("asset_id",$asset_id)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet cancel_offers $json | ConvertFrom-Json

}

Function Invoke-WalletCatAssetIdToName {
    param(
        [Parameter(Mandatory=$true)]
        $asset_id   
    )

    $json = @{
        "asset_id"=$asset_id
    } | ConvertTo-Json

    chia rpc wallet cat_asset_id_to_name $json | ConvertFrom-Json
}

Function Invoke-WalletCatGetAssetId {
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id   
    )

    $json = @{
        "wallet_id"=$wallet_id
    } | ConvertTo-Json

    chia rpc wallet cat_get_asset_id $json | ConvertFrom-Json
}

Function Invoke-WalletCatGetName {
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id   
    )

    $json = @{
        "wallet_id"=$wallet_id
    } | ConvertTo-Json

    chia rpc wallet cat_get_name $json | ConvertFrom-Json
}

Function Invoke-WalletCatSetName {
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id,
        [Parameter(Mandatory=$true)]
        $name   
    )

    $json = @{
        "wallet_id"=$wallet_id
        "name"=$name
    } | ConvertTo-Json

    chia rpc wallet cat_set_name $json | ConvertFrom-Json
}

Function Invoke-WalletCatSpend {
    param(
        [Parameter(Mandatory=$true)]
        $wallet_id,
        [Parameter(Mandatory=$true)]
        $amount,
        [Parameter(Mandatory=$true)]
        $inner_address,
        $memos,
        $coins,
        $min_coin_amount,
        $max_coin_amount,
        $excluded_coin_amounts,
        $excluded_coin_ids,
        $fee
    )
    $json = @{
        "wallet_id"=$wallet_id
        "amount"=$amount
        "inner_address"=$inner_address
    }
    if($memos){
        $json.Add("memos",$memos)
    }
    if($coins){
        $json.Add("memos",$memos)
    }
    if($min_coin_amount){
        $json.Add("min_coin_amount",$min_coin_amount)
    }
    if($max_coin_amount){
        $json.Add("max_coin_amount",$max_coin_amount)
    }
    if($excluded_coin_amounts){
        $json.Add("exclude_coin_amounts")
    }
    if($excluded_coin_ids){
        $json.Add("exclude_coin_ids",$excluded_coin_ids)
    }
    if($fee){
        $json.Add("fee",$fee)
    } else {
        $json.Add("fee",0)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet cat_spend $json | ConvertFrom-Json
}

Function Invoke-WalletCheckOfferValidity {
    param(
        [Parameter(Mandatory=$true)]
        $offer
    )
    $json = @{
        "offer"=$offer
    } | ConvertTo-Json

    chia rpc wallet check_offer_validity $json | ConvertFrom-Json

}

Function Invoke-WalletCreateOfferForIds {
    param(
        [Parameter(Mandatory=$true)]
        $offer,
        [switch]
        $validate_only,
        [Parameter(Mandatory=$true)]
        $driver_dict,
        $min_coin_amount,
        $max_coin_amount,
        $solver,
        $fee,
        [switch]
        $reuse_puzhash

    )

    $json = @{
        "offer"=$offer
        "driver_dict"=$driver_dict
    }
    if($validate_only.IsPresent){
        $json.Add("validate_only",$true)
    } else {
        $json.Add("validate_only",$false)
    }
    if($min_coin_amount){
        $json.Add("min_coin_amount",$min_coin_amount)
    }
    if($max_coin_amount){
        $json.Add("max_coin_amount",$max_coin_amount)
    }
    if($solver){
        $json.Add("solver",$solver)
    }
    if($fee){
        $json.Add("fee",$fee)
    } else {
        $json.Add("fee",0)
    }
    if($reuse_puzhash.IsPresent){
        $json.Add("reuse_puzhash",$true)
    } else {
        $json.Add("reuse_puzhash",$false)
    }

    $json = $json | ConvertTo-Json -Depth 10

    chia rpc wallet create_offer_for_ids $json | ConvertFrom-Json

}

Function Invoke-WalletGetAllOffers {
    param(
        $start,
        $end,
        [switch]
        $exclude_my_offers,
        [switch]
        $exclude_taken_offers,
        [switch]
        $include_completed,
        $sort_key,
        [switch]
        $reverse,
        [switch]
        $file_contents
    )

    $json = @{}

    if($start){
        $json.Add("start",$start)
    }
    if($end){
        $json.Add("end",$end)
    }
    if($exclude_my_offers.IsPresent){
        $json.Add("exclude_my_offers",$true)
    }
    if($exclude_taken_offers.IsPresent){
        $json.Add("exclude_taken_offers",$true)
    }
    if($include_completed){
        $json.Add("include_completed",$true)
    }
    if($sort_key){
        $json.Add("sort_key",$sort_key)
    }
    if($reverse.IsPresent){
        $json.Add("reverse",$true)
    }
    if($file_contents){
        $json.Add("file_contents",$true)
    }

    $json = $json | ConvertTo-Json

    chia rpc wallet get_all_offers $json | ConvertFrom-Json


}

Function Invoke-WalletGetCatList{
    chia rpc wallet get_cat_list | ConvertFrom-Json
}

Function Invoke-WalletGetOffer {
    param(
        [Parameter(Mandatory=$true)]
        $trade_id,
        $file_contents 
    )

    $json = @{
        "trade_id"=$trade_id
    }
    if($file_contents){
        $json.Add("file_contents",$file_contents)
    }
    $json = $json | ConvertTo-Json

    chia rpc wallet get_offer $json | ConvertFrom-Json
}

Function Invoke-WalletGetOffersCount {
    chia rpc wallet get_offers_count | ConvertFrom-Json

}

Function Invoke-WalletGetOfferSummary {
    param(
        [Parameter(Mandatory=$true)]
        $offer,
        [switch]
        $advanced
    )
    $json = @{
        "offer"=$offer
    }
    if($advanced.IsPresent){
        $json.Add("advanced",$true)
    }

    $json = $json | ConvertTo-Json
    
    chia rpc wallet get_offer_summary $json | ConvertFrom-Json
}

Function Invoke-WalletGetStrayCats {
    chia rpc wallet get_stray_cats | ConvertFrom-Json
}

Function Invoke-WalletTakeOffer {
    param(
        [Parameter(Mandatory=$true)]
        $offer,
        $min_coin_amount,
        $max_coin_amount,
        $solver,
        $fee,
        [switch]
        $reuse_puzhash
    )

    $json = @{
        offer=$offer
    }
}

Function ConvertFrom-Hex{
    param(
        [array]$hex
    )
    
    -join ($hex -split '(..)' | ? { $_ } | % { [char][convert]::ToUInt32($_,16) })

}

Function ConvertTo-Hex {
    param(
        [array]$string
    )

    $array = $string.ToCharArray()
    foreach($char in $array){
        $hex = $hex +  [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($char))
    }
    $hex
}